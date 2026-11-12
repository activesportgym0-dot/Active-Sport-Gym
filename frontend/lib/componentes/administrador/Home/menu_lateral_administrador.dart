import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/administrador/Gestionusuariosadmin.dart';
import 'package:frontend/pantallas/historia_gym.dart';
import 'package:frontend/pantallas/administrador/horarios_y_reglas.dart';
import 'package:frontend/registro-recuperar/Login.dart';
import 'package:frontend/models/perfil_model.dart';
import 'package:frontend/services/auth_service.dart'; // SessionService
import 'package:frontend/services/perfil_cache.dart';
import 'package:frontend/services/perfil_service.dart';

class MenuLateralAdministrador extends StatefulWidget {
  const MenuLateralAdministrador({super.key});

  /// Carga el perfil en segundo plano. Llámalo desde el home del administrador
  /// (por ejemplo en su initState) para que, cuando se abra el menú, ya esté todo listo.
  static Future<void> precargar() async {
    final id = SessionService.idUsuario;
    if (id == null) return;
    try {
      final r = await PerfilService.obtenerPerfil(id);
      if (r['success'] == true) PerfilCache.guardar(r['perfil'] as PerfilModel);
    } catch (_) {
      // Sin conexión: el menú se queda con el nombre de la sesión
    }
  }

  @override
  State<MenuLateralAdministrador> createState() => _MenuLateralAdministradorState();
}

class _MenuLateralAdministradorState extends State<MenuLateralAdministrador> {
  // Perfil del administrador (nombre completo y foto, vienen del backend y se guardan en memoria
  // para que el menú salga de una vez cada vez que se abre)
  PerfilModel? get _perfil => PerfilCache.perfil;

  // Estado real del servidor: null mientras se consulta, true si respondió, false si no
  bool? _servidorActivo;

  @override
  void initState() {
    super.initState();
    _refrescar();
  }

  // El menú se muestra de una vez con lo que haya guardado y se actualiza cuando llegan los datos nuevos
  Future<void> _refrescar() async {
    final id = SessionService.idUsuario;
    if (id == null) {
      if (mounted) setState(() => _servidorActivo = false);
      return;
    }

    bool respondio = false;
    try {
      final r = await PerfilService.obtenerPerfil(id);
      respondio = r['success'] == true;
      if (respondio) PerfilCache.guardar(r['perfil'] as PerfilModel);
    } catch (_) {
      respondio = false;
    }

    if (!mounted) return;
    setState(() => _servidorActivo = respondio);
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

  // Nombre y apellido del administrador (mientras carga el perfil, el nombre de la sesión)
  String get _nombreUsuario {
    final completo = _perfil?.nombreCompleto ?? '';
    if (completo.isNotEmpty) return completo;
    final nombre = SessionService.nombreUsuario.trim();
    return nombre.isEmpty ? 'Administrador' : nombre;
  }

  // Foto de perfil (null si no tiene)
  String? get _fotoPerfil => _perfil?.fotoPerfil;

  // Etiqueta pequeña sobre el nombre: la cuenta principal se distingue de los demás administradores
  String get _etiquetaRol =>
      SessionService.esAdminPrincipal ? 'Administrador principal' : 'Modo Administrador';

  // Estado del sistema: título, detalle y color del puntico
  String get _tituloServidor {
    if (_servidorActivo == null) return 'Consultando...';
    return _servidorActivo! ? 'Servidor Activo' : 'Sin conexión';
  }

  String get _detalleServidor {
    if (_servidorActivo == null) return 'Revisando el servidor';
    return _servidorActivo! ? 'Sincronizado con BD' : 'No se pudo consultar el servidor';
  }

  Color? get _colorPuntoServidor {
    if (_servidorActivo == null) return null;
    return _servidorActivo! ? Colors.green : Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final colorPunto = _colorPuntoServidor;

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
                          Icons.admin_panel_settings,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ACTIVE SPORT - ADMIN',
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

            // 2. Tarjeta del administrador con borde verde (foto de perfil y nombre)
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
                          ? const Icon(Icons.admin_panel_settings, color: AppColors.blancoPuro, size: 24)
                          : ClipOval(
                              child: Image.network(
                                _fotoPerfil!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                // Si la imagen no carga, se queda el ícono de siempre
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.admin_panel_settings,
                                  color: AppColors.blancoPuro,
                                  size: 24,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _etiquetaRol,
                          style: const TextStyle(
                            color: AppColors.verdePrimario,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _nombreUsuario,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.blancoPuro,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECCIÓN: CONTROL DE USUARIOS
            const Text(
              'CONTROL DE ACCESOS',
              style: TextStyle(
                color: AppColors.grisMedio,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            _buildMenuItem(Icons.manage_accounts_outlined, 'Gestión de Usuarios', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GestionUsuariosAdminScreen()),
              );
            }),

            const Divider(color: AppColors.grisMedio, height: 25, thickness: 0.5),

            // SECCIÓN: INFORMACIÓN DEL GYM
            const Text(
              'ACERCA DEL GYM',
              style: TextStyle(
                color: AppColors.grisMedio,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            _buildMenuItem(Icons.history_edu_outlined, 'Historia del Gimnasio', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoriaGymScreen()),
              );
            }),
            _buildMenuItem(Icons.schedule_outlined, 'Horarios y Reglas', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HorariosYReglasScreen()),
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
              PerfilCache.limpiar();
              // Borra la sesión (también la que guardó "Recuérdame") y vuelve al login sin dejar pantallas atrás
              SessionService.limpiarSesion();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }, isRed: true),
            const SizedBox(height: 20),

            // 3. Tarjeta de Estado del Sistema (ahora refleja si el servidor responde de verdad)
            Container(
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
                    child: const Icon(Icons.security, color: AppColors.verdePrimario, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ESTADO DEL SISTEMA',
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
                              _tituloServidor,
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
                          _detalleServidor,
                          style: const TextStyle(
                            color: AppColors.grisClaro,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Pie de página
            Center(
              child: Column(
                children: const [
                  Text(
                    'CONTROL TOTAL ACTIVE SPORT',
                    style: TextStyle(
                      color: AppColors.verdePrimario,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Versión Admin 1.0.0',
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