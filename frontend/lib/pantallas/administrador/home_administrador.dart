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

class HomeAdministradorScreen extends StatefulWidget {
  const HomeAdministradorScreen({super.key});

  @override
  State<HomeAdministradorScreen> createState() => _HomeAdministradorScreenState();
}

class _HomeAdministradorScreenState extends State<HomeAdministradorScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Variables de estado preparadas para conectar con el Backend (API / Tiempo Real)
  int _totalEjercicios = 42;
  int _totalProductos = 15;
  int _totalCategorias = 8;
  int _totalUsuarios = 128;

  // Lista reactiva de últimas acciones lista para escuchar actualizaciones del backend
  final List<Map<String, String>> _ultimasAcciones = [
    {
      'action': 'Nuevo suplemento agregado',
      'detail': 'Proteína Whey en polvo - Stock: 15 unidades',
      'time': 'Hace 2 horas',
    },
    {
      'action': 'Ejercicio añadido al catálogo',
      'detail': 'Se añadió "Remo horizontal con mancuernas"',
      'time': 'Hace 5 horas',
    },
  ];

  // Método auxiliar para insertar nuevas acciones en tiempo real
  void _agregarAccionReciente(String accion, String detalle, String tiempo) {
    setState(() {
      _ultimasAcciones.insert(0, {
        'action': accion,
        'detail': detalle,
        'time': tiempo,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
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
                              '$_totalUsuarios Totales',
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GestionUsuariosAdminScreen(),
                              ),
                            );
                          },
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
                      title: 'Ejercicios\n($_totalEjercicios registrados)',
                      icon: Icons.fitness_center,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EntrenarAdminScreen()), // 👈 Ya limpio sin parámetros
                        );
                      },
                    ),
                    AdminCard(
                      title: 'Productos / Tienda\n($_totalProductos en stock)',
                      icon: Icons.shopping_bag_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ComprasAdminScreen()),
                        );
                      },
                    ),
                    AdminCard(
                      title: 'Categorías\n($_totalCategorias activas)',
                      icon: Icons.category_outlined,
                      onTap: () {},
                    ),
                    AdminCard(
                      title: 'Control de pedidos \n(Cambia el estado del pedido)',
                      icon: Icons.receipt_long_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PedidosAdminScreen(),
                          ),
                        );
                      },
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
                
                // Lista dinámica conectada a la lista de estado
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ultimasAcciones.length,
                  itemBuilder: (context, index) {
                    final accion = _ultimasAcciones[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ActivityCard(
                        action: accion['action']!,
                        detail: accion['detail']!,
                        time: accion['time']!,
                      ),
                    );
                  },
                ),
              ],
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EntrenarAdminScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.grisMedio, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComprasAdminScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}