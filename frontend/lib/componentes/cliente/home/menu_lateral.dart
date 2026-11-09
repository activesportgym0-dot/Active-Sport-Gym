import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/historia_gym.dart';
import 'package:frontend/pantallas/cliente/menuLateral/progreso/progreso.dart';
import 'package:frontend/pantallas/cliente/menuLateral/reglas_y_horarios.dart';
import 'package:frontend/pantallas/cliente/menuLateral/mis_membresias.dart';
import 'package:frontend/registro-recuperar/Login.dart';
import 'package:frontend/models/membresia_model.dart';
import 'package:frontend/models/perfil_model.dart';
import 'package:frontend/services/auth_service.dart'; // SessionService
import 'package:frontend/services/membresia_service.dart';
import 'package:frontend/services/perfil_cache.dart';
import 'package:frontend/services/perfil_service.dart';
import '../../../pantallas/cliente/menuLateral/entrenamiento_screen.dart';

/// Datos del menú guardados en memoria.
/// Flutter construye el menú de nuevo cada vez que se abre; sin esto, cada apertura volvía a
/// pedir el perfil y la membresía al servidor y se veía vacío hasta que llegaba la respuesta.
class _CacheMenu {
  static int? idUsuario;
  static MembresiaModel? membresia;
  static bool membresiaCargada = false;
  static bool errorMembresia = false;
  static Future<void>? _enCurso;

  static void limpiar() {
    idUsuario = null;
    PerfilCache.limpiar();
    membresia = null;
    membresiaCargada = false;
    errorMembresia = false;
  }

  /// Pide perfil y membresía al servidor y actualiza lo guardado.
  /// Si ya hay una carga en curso no lanza otra. Si cambió el usuario, descarta lo del anterior.
  static Future<void> actualizar() {
    final actual = SessionService.idUsuario;
    if (idUsuario != actual) {
      limpiar();
      idUsuario = actual;
    }
    return _enCurso ??= _cargar().whenComplete(() => _enCurso = null);
  }

  static Future<void> _cargar() async {
    final id = SessionService.idUsuario;

    await Future.wait([
      () async {
        if (id == null) return;
        try {
          final r = await PerfilService.obtenerPerfil(id);
          if (idUsuario != id) return; // cambió la sesión mientras cargaba
          if (r['success'] == true) PerfilCache.guardar(r['perfil'] as PerfilModel);
        } catch (_) {
          // Sin conexión: el menú se queda con el nombre de la sesión y el ícono
        }
      }(),
      () async {
        try {
          final m = await MembresiaService.obtenerMiMembresia();
          if (idUsuario != id) return;
          membresia = m;
          errorMembresia = false;
        } catch (_) {
          if (idUsuario != id) return;
          // Si ya había datos guardados se siguen mostrando; el error solo se marca si no hay nada
          if (membresia == null) errorMembresia = true;
        }
        membresiaCargada = true;
      }(),
    ]);
  }
}

class MenuLateral extends StatefulWidget {
  const MenuLateral({super.key});

  /// Carga perfil y membresía en segundo plano. Llámalo desde el home del cliente
  /// (por ejemplo en su initState) para que, cuando se abra el menú, ya esté todo listo.
  static Future<void> precargar() => _CacheMenu.actualizar().catchError((_) {});

  /// Borra lo guardado. Se llama al cerrar sesión para que otro usuario no vea datos del anterior.
  static void limpiarCache() => _CacheMenu.limpiar();

  @override
  State<MenuLateral> createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  // Perfil del usuario (nombre completo y foto, vienen del backend)
  PerfilModel? get _perfil => PerfilCache.perfil;

  // Membresía real del cliente (viene del backend)
  MembresiaModel? get _membresia => _CacheMenu.membresia;
  bool get _cargandoMembresia => !_CacheMenu.membresiaCargada;
  bool get _errorMembresia => _CacheMenu.errorMembresia;

  @override
  void initState() {
    super.initState();
    _refrescar();
  }

  // El menú se muestra de una vez con lo que haya guardado y se actualiza cuando llegan los datos nuevos
  Future<void> _refrescar() async {
    await _CacheMenu.actualizar();
    if (mounted) setState(() {});
  }

  // Abre la foto de perfil en pantalla completa; se puede hacer zoom con dos dedos
  void _verFotoAmpliada() {
    final foto = _fotoPerfil;
    if (foto == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Tocar fuera de la foto cierra el visor
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(dialogContext),
              ),
            ),
            Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Image.network(
                  foto,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progreso) {
                    if (progreso == null) return child;
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.verdePrimario),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.grisClaro,
                    size: 60,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.blancoPuro, size: 28),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nombre y apellido del usuario (mientras carga el perfil, el nombre de la sesión)
  String get _nombreUsuario {
    final completo = _perfil?.nombreCompleto ?? '';
    if (completo.isNotEmpty) return completo;
    final nombre = SessionService.nombreUsuario.trim();
    return nombre.isEmpty ? 'Usuario' : nombre;
  }

  // Foto de perfil (null si no tiene)
  String? get _fotoPerfil => _perfil?.fotoPerfil;

  // Texto principal de la tarjeta: Activa / Vencida / Inactiva / Sin membresía
  String get _tituloMembresia {
    if (_cargandoMembresia) return 'Cargando...';
    if (_errorMembresia) return 'No disponible';
    final m = _membresia;
    if (m == null || m.estado.isEmpty) return 'Sin membresía';
    return m.estado[0].toUpperCase() + m.estado.substring(1);
  }

  // Línea de abajo: fechas si está activa, o aviso si no tiene
  String get _detalleMembresia {
    if (_cargandoMembresia) return 'Consultando tu membresía';
    if (_errorMembresia) return 'Toca para ver tu membresía';
    final m = _membresia;
    if (m == null) return 'No tienes una membresía registrada';
    if (m.estado == 'activa') {
      return 'Del ${m.fechaInicioFormateada} al ${m.fechaFinFormateada}';
    }
    return 'No tienes una membresía activa';
  }

  // Puntico de color: verde activa, rojo vencida/inactiva, gris sin membresía
  Color? get _colorPuntoMembresia {
    if (_cargandoMembresia || _errorMembresia) return null;
    final m = _membresia;
    if (m == null) return AppColors.grisMedio;
    return m.estado == 'activa' ? Colors.green : Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final colorPunto = _colorPuntoMembresia;

    return Drawer(
      backgroundColor: AppColors.fondoNegro,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Logo superior
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.verdePrimario,
                    AppColors.fondoNegro,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.fondoNegro,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.fitness_center,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ACTIVE SPORT GYM',
                    style: TextStyle(
                      color: AppColors.blancoPuro,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 2. Tarjeta del usuario con borde verde (foto de perfil y nombre)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grisOscuro,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.verdePrimario, width: 1),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _fotoPerfil == null ? null : _verFotoAmpliada,
                    child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.grisMedio,
                    child: _fotoPerfil == null
                        ? const Icon(Icons.person, color: AppColors.blancoPuro, size: 24)
                        : ClipOval(
                            child: Image.network(
                              _fotoPerfil!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              // Si la imagen no carga, se queda el ícono de siempre
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person,
                                color: AppColors.blancoPuro,
                                size: 24,
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _nombreUsuario,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.blancoPuro,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECCIÓN: PRINCIPAL
            const Text(
              'PRINCIPAL',
              style: TextStyle(
                color: AppColors.grisMedio,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            _buildMenuItem(Icons.fitness_center, 'Entrenamiento', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  EntrenamientoScreen()),
              );
            }),
            _buildMenuItem(Icons.trending_up, 'Progreso', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProgresoScreen()),
              );
            }),
            const Divider(color: AppColors.grisMedio, height: 25, thickness: 0.5),

            // SECCIÓN: INFORMACIÓN
            const Text(
              'INFORMACIÓN',
              style: TextStyle(
                color: AppColors.grisMedio,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            _buildMenuItem(Icons.info_outline, 'Historia del Gym', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  HistoriaGymScreen()),
              );
            }),
            _buildMenuItem(Icons.access_time, 'Reglas y horarios', () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  HorariosYReglasClienteScreen()),
              );

            }),

            const Divider(color: AppColors.grisMedio, height: 25, thickness: 0.5),

            // SECCIÓN: CONFIGURACIÓN
            const Text(
              'CONFIGURACIÓN',
              style: TextStyle(
                color: AppColors.grisMedio,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            _buildMenuItem(Icons.logout, 'Cerrar sesión', () {
              // Se borra lo guardado para que el siguiente usuario no vea datos de este
              MenuLateral.limpiarCache();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context)=> const LoginScreen()));
            }, isRed: true),
            const SizedBox(height: 20),
           // 3. Tarjeta de Membresía (Interactiva, con datos reales del backend)
            InkWell(
              borderRadius: BorderRadius.circular(10), // Para que el efecto de toque respete los bordes redondeados
              onTap: () {
                // Navegación hacia la pantalla de Historial de Membresías
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MisMembresiasScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.grisOscuro,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.verdePrimario, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.verdePrimario.withOpacity(0.2),
                      ),
                      child: const Icon(Icons.card_membership, color: AppColors.verdePrimario, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TU MEMBRESÍA',
                            style: TextStyle(
                              color: AppColors.verdePrimario,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                _tituloMembresia,
                                style: const TextStyle(
                                  color: AppColors.blancoPuro,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (colorPunto != null) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.circle, color: colorPunto, size: 10),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _detalleMembresia,
                            style: const TextStyle(
                              color: AppColors.grisClaro,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.verdePrimario, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Pie de página del menú
            Center(
              child: Column(
                children: const [
                  Text(
                    'SUPERA TUS LÍMITES',
                    style: TextStyle(
                      color: AppColors.verdePrimario,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Versión 1.0.0',
                    style: TextStyle(
                      color: AppColors.grisMedio,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isRed = false}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isRed ? Colors.redAccent : AppColors.blancoPuro,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isRed ? Colors.redAccent : AppColors.blancoPuro,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}