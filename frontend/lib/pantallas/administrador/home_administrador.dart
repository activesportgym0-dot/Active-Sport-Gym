import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/administrador/Home/menu_lateral_administrador.dart';
import 'package:frontend/componentes/administrador/Home/admin_card.dart';
import 'package:frontend/componentes/administrador/Home/activity_card.dart';
import 'package:frontend/pantallas/administrador/Gestionusuariosadmin.dart';
import 'package:frontend/pantallas/administrador/compras/comprasadmin.dart';
import 'package:frontend/pantallas/administrador/compras/pedidos_admin_screen.dart';
import 'package:frontend/pantallas/administrador/entrenaradmin.dart';
import 'package:frontend/pantallas/administrador/notificacionesadmin.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/models/resumen_admin_model.dart';
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
                  Row(
                    children: [
                      const Text('⚡ ', style: TextStyle(fontSize: 22)),
                      Text(
                        'Panel de Control,\nAdministrador',
                        style: EstiloTexto.tituloPrincipalPrimerPantalla.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tarjeta principal de control de usuarios
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grisOscuro,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text('👥 ', style: TextStyle(fontSize: 16)),
                                Text(
                                  'GESTIÓN DE USUARIOS',
                                  style: TextStyle(
                                    color: AppColors.blancoPuro,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.verdePrimario.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
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
                        const SizedBox(height: 8),
                        const Text(
                          'Acepta nuevos registros, revisa los perfiles activos y administra la eliminación de usuarios de la aplicación.',
                          style: TextStyle(color: AppColors.grisClaro, fontSize: 13),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => _irA(const GestionUsuariosAdminScreen()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdePrimario,
                              foregroundColor: AppColors.fondoNegro,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'ADMINISTRAR USUARIOS',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Sección de Accesos Rápidos
                  const Row(
                    children: [
                      Text('🛠️ ', style: TextStyle(fontSize: 16)),
                      Text(
                        'GESTIÓN RÁPIDA',
                        style: TextStyle(
                          color: AppColors.blancoPuro,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Grid de opciones con los resúmenes actualizados
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      AdminCard(
                        title: 'Ejercicios\n(${_n(_resumen.ejercicios)} registrados)',
                        icon: Icons.fitness_center,
                        onTap: () => _irA(const EntrenarAdminScreen()),
                      ),
                      AdminCard(
                        title: 'Productos / Tienda\n(${_n(_resumen.productosConStock)} en stock)',
                        icon: Icons.shopping_bag_outlined,
                        onTap: () => _irA(const ComprasAdminScreen()),
                      ),
                      AdminCard(
                        title: 'Membresías\n(${_n(_resumen.membresiasActivas)} activas)',
                        icon: Icons.card_membership,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GestionUsuariosAdminScreen(),
                            ),
                          );
                        },
                      ),
                      AdminCard(
                        title: 'Control de pedidos \n(Cambia el estado del pedido)',
                        icon: Icons.receipt_long_outlined,
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
      floatingActionButton: const BurbujaMiniChatModal(),
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
              onPressed: () => _irA(const ComprasAdminScreen()),
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
