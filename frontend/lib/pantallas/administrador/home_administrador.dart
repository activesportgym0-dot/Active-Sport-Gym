import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/administrador/Home/menu_lateral_administrador.dart';
import 'package:frontend/componentes/administrador/Home/activity_card.dart';
import 'package:frontend/componentes/administrador/Home/admin_stat_card.dart';
import 'package:frontend/componentes/administrador/Home/admin_consejos_home.dart';
import 'package:frontend/componentes/cliente/home/carrusel_home.dart';
import 'package:frontend/componentes/cliente/home/slides_gimnasio.dart';
import 'package:frontend/pantallas/administrador/Gestionusuariosadmin.dart';
import 'package:frontend/pantallas/administrador/asistente_ia_admin_screen.dart';
import 'package:frontend/pantallas/administrador/compras/comprasadmin.dart';
import 'package:frontend/pantallas/administrador/compras/pedidos_admin_screen.dart';
import 'package:frontend/pantallas/administrador/entrenaradmin.dart';
import 'package:frontend/pantallas/administrador/notificacionesadmin.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/models/resumen_admin_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/dashboard_service.dart';

class HomeAdministradorScreen extends StatefulWidget {
  const HomeAdministradorScreen({super.key});

  @override
  State<HomeAdministradorScreen> createState() => _HomeAdministradorScreenState();
}

class _HomeAdministradorScreenState extends State<HomeAdministradorScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Datos reales que vienen del backend (GET /dashboard/resumen)
  ResumenAdminModel _resumen = const ResumenAdminModel();
  bool _isLoading = true;

  // Primer nombre de quien inició sesión: "luisa maría" -> "Luisa"
  String get _nombreSaludo {
    final primero = SessionService.nombreUsuario.trim().split(RegExp(r'\s+')).first;
    if (primero.isEmpty) return '';
    return primero[0].toUpperCase() + primero.substring(1).toLowerCase();
  }

  // "Buenos días", "Buenas tardes" o "Buenas noches" según la hora del teléfono
  String get _saludoHora {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final resumen = await DashboardService.obtenerResumen();
      if (!mounted) return;
      setState(() {
        _resumen = resumen;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar el resumen: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Mientras llegan los datos se muestra "..." en lugar de un número falso.
  String _n(int valor) => _isLoading ? '...' : '$valor';

  // Abre una pantalla y, al volver, refresca los números y las últimas acciones
  // (por ejemplo, después de crear un ejercicio o un producto).
  Future<void> _irA(Widget pantalla) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pantalla),
    );
    if (mounted) _cargarResumen();
  }

  Widget _tituloSeccion(String emoji, String texto) {
    return Row(
      children: [
        Text('$emoji ', style: const TextStyle(fontSize: 16)),
        Text(
          texto,
          style: const TextStyle(
            color: AppColors.blancoPuro,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final actividad = _resumen.actividad;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.fondoNegro,
      drawer: const MenuLateralAdministrador(),
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.verdePrimario, size: 28),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'ACTIVE SPORT - ADMIN',
          style: EstiloTexto.bienvenida.copyWith(
            fontSize: 14,
            color: AppColors.blancoPuro,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.blancoPuro, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.blancoPuro, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificacionesAdminScreen()),
              );
            },
          ),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          // Desliza hacia abajo para refrescar los datos
          child: RefreshIndicator(
            color: AppColors.verdePrimario,
            onRefresh: _cargarResumen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo (igual que en el home del cliente)
                  Row(
                    children: [
                      const Text('🔥 ', style: TextStyle(fontSize: 22)),
                      Text(
                        'Hola,\n$_nombreSaludo',
                        style: EstiloTexto.tituloPrincipalPrimerPantalla.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_saludoHora • ¿Listo para entrenar?',
                    style: const TextStyle(color: AppColors.grisClaro, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Carrusel con fotos del gimnasio (el mismo del cliente: se edita en slides_gimnasio.dart)
                  const CarruselHome(slides: slidesGimnasio, altura: 190),
                  const SizedBox(height: 22),

                  const AdminConsejosHome(cada: Duration(seconds: 15)),
                  const SizedBox(height: 25),

                  // Tarjeta principal de control de usuarios
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.verdePrimario.withOpacity(0.2), AppColors.grisOscuro],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.verdePrimario.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppColors.verdePrimario.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.people_alt_rounded, color: AppColors.verdePrimario, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'GESTIÓN DE USUARIOS',
                                style: TextStyle(
                                  color: AppColors.blancoPuro,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.verdePrimario.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_n(_resumen.usuarios)} Totales',
                                style: const TextStyle(
                                  color: AppColors.verdePrimario,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Acepta nuevos registros, revisa los perfiles activos y administra la eliminación de usuarios de la aplicación.',
                          style: TextStyle(color: AppColors.grisClaro, fontSize: 13, height: 1.3),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton.icon(
                            onPressed: () => _irA(const GestionUsuariosAdminScreen()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdePrimario,
                              foregroundColor: AppColors.fondoNegro,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                            label: const Text(
                              'ADMINISTRAR USUARIOS',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Sección de Accesos Rápidos: las mismas 4 opciones de siempre, con el diseño de colores
                  _tituloSeccion('🛠️', 'GESTIÓN RÁPIDA'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.85,
                    children: [
                      AdminStatCard(
                        icono: Icons.fitness_center,
                        valor: _n(_resumen.ejercicios),
                        titulo: 'Ejercicios',
                        detalle: 'registrados',
                        color: const Color(0xFF4FC3F7),
                        onTap: () => _irA(const EntrenarAdminScreen()),
                      ),
                      AdminStatCard(
                        icono: Icons.shopping_bag_rounded,
                        valor: _n(_resumen.productosConStock),
                        titulo: 'Productos / Tienda',
                        detalle: _isLoading ? '' : 'en stock (de ${_resumen.productos})',
                        color: const Color(0xFFFFB74D),
                        onTap: () => _irA(const ComprasAdminScreen()),
                      ),
                      AdminStatCard(
                        icono: Icons.card_membership,
                        valor: _n(_resumen.membresiasActivas),
                        titulo: 'Membresías',
                        detalle: _isLoading ? '' : 'activas (de ${_resumen.membresias})',
                        color: const Color(0xFFBA68C8),
                        onTap: () => _irA(const GestionUsuariosAdminScreen()),
                      ),
                      // Este es solo un botón: no tiene número
                      AdminStatCard(
                        icono: Icons.receipt_long_rounded,
                        valor: '',
                        titulo: 'Control de pedidos',
                        detalle: 'Cambia el estado',
                        color: AppColors.verdePrimario,
                        onTap: () => _irA(const PedidosAdminScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Encabezado de Últimas Acciones con indicador en vivo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ÚLTIMAS ACCIONES REGISTRADAS',
                        style: TextStyle(
                          color: AppColors.blancoPuro,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.verdePrimario,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Nuevo',
                            style: TextStyle(
                              color: AppColors.verdePrimario,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Lista dinámica: últimos ejercicios y productos registrados
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.verdePrimario),
                      ),
                    )
                  else if (actividad.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Aún no hay actividad reciente.',
                          style: TextStyle(color: AppColors.grisClaro, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: actividad.length,
                      itemBuilder: (context, index) {
                        final accion = actividad[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ActivityCard(
                            action: accion.titulo,
                            detail: accion.detalle,
                            time: accion.tiempoRelativo,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.fondoNegro,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: AppColors.verdePrimario, size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.fitness_center, color: AppColors.grisMedio, size: 28),
              onPressed: () => _irA(const EntrenarAdminScreen()),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.grisMedio, size: 28),
              onPressed: () => _irA(const AsistenteIAAdminScreen()),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.grisMedio, size: 28),
              onPressed: () => _irA(const ComprasAdminScreen()),
            ),
          ],
        ),
      ),
    );
  }
}