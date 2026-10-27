import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/home/menu_lateral.dart';
import 'package:frontend/componentes/cliente/home/barra_categorias_home.dart';
import 'package:frontend/componentes/cliente/home/lista_ejercicios_cliente.dart';
import 'package:frontend/pantallas/cliente/asistente_ia_screen.dart';
import 'package:frontend/pantallas/cliente/compras/compras_screen.dart';
import 'package:frontend/pantallas/cliente/entrenar.dart';
import 'package:frontend/pantallas/cliente/notificaciones_Cliente.dart';
import 'package:frontend/pantallas/cliente/rutina/diaria/crear_rutina_diaria_screen.dart';
import 'package:frontend/pantallas/perfil.dart';

class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({super.key});

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _categoriaSeleccionada = 'Resistencia';
  final List<String> _categorias = ['Cardio', 'Tren superior', 'Piernas', 'Glúteos', 'Resistencia'];

  final List<Map<String, String>> _todosLosEjercicios = [
    {
      'category': 'Resistencia',
      'title': 'Remo horizontal con mancuernas',
      'description': 'Mantén la espalda recta y trata de llevar los codos al techo y las mancuernas hacia la cadera.',
      'imagePath': 'assets/images/3.jpg',
    },
    {
      'category': 'Resistencia',
      'title': 'Press militar',
      'description': 'Ejercicio fundamental para el desarrollo del hombro. Se trata de un ejercicio base en cualquier rutina de hombro.',
      'imagePath': 'assets/images/4.jpg',
    },
    {
      'category': 'Tren superior',
      'title': 'Flexiones',
      'description': 'De la misma forma que hemos comentado anteriormente, los codos realizarán un movimiento en diagonal hacia atrás.',
      'imagePath': 'assets/images/5.jpg',
    },
  ];

  List<Map<String, String>> get _ejerciciosFiltrados {
    return _todosLosEjercicios.where((ejercicio) {
      return ejercicio['category']!.toLowerCase() == _categoriaSeleccionada.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ejerciciosMostrados = _ejerciciosFiltrados;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.fondoNegro,
      drawer: const MenuLateral(),
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.verdePrimario, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'ACTIVE SPORT GYM',
          style: EstiloTexto.bienvenida.copyWith(
            fontSize: 14,
            color: AppColors.blancoPuro,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.person_outline, color: AppColors.blancoPuro, size: 22), onPressed: () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PerfilScreen(                    
                                ),
                              ),
                            );
          }),
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.blancoPuro, size: 22), onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificacionesClienteScreen(                    
                                ),
                              ),
                            );            
          }),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 22)),
                    Text(
                      'Hola,\n(Nombre)',
                      style: EstiloTexto.tituloPrincipalPrimerPantalla.copyWith(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.blancoTransparente.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text('⭐ ', style: TextStyle(fontSize: 16)),
                          Text(
                            'RUTINA DE HOY',
                            style: TextStyle(color: AppColors.blancoPuro, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No tienes una rutina asignada crea una.',
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
                                builder: (context) => CrearRutinaDiariaScreen(                    
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verdePrimario,
                            foregroundColor: AppColors.fondoNegro,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('CREAR RUTINA', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Text('🗂️ ', style: TextStyle(fontSize: 16)),
                        Text(
                          'CATEGORÍAS',
                          style: TextStyle(color: AppColors.blancoPuro, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Barra de categorías modular con actualización de estado
                BarraCategoriasHome(
                  categorias: _categorias,
                  categoriaSeleccionada: _categoriaSeleccionada,
                  onCategoriaSelected: (cat) {
                    setState(() {
                      _categoriaSeleccionada = cat;
                    });
                  },
                ),
                const SizedBox(height: 25),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EJERCICIOS',
                      style: TextStyle(color: AppColors.blancoPuro, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${ejerciciosMostrados.length} encontrados',
                      style: const TextStyle(color: AppColors.grisClaro, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                ejerciciosMostrados.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        child: const Text('No hay ejercicios en esta categoría', style: TextStyle(color: AppColors.grisClaro, fontSize: 13)),
                      )
                    : ListaEjerciciosCliente(ejercicios: ejerciciosMostrados),
                
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntrenarClienteScreen(
                            categoriaInicial: _categoriaSeleccionada,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'ver mas ejercicios...',
                      style: TextStyle(color: AppColors.grisClaro, fontSize: 13, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EntrenarClienteScreen(
                      categoriaInicial: _categoriaSeleccionada,
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.fondoNegro,
              ),
              child: IconButton(
                icon: const Icon(Icons.add_box, color: AppColors.verdePrimario, size: 36),
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CrearRutinaDiariaScreen(
                      
                    ),
                  ),
                );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.grisMedio, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AsistenteIAScreen(                    
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.grisMedio, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComprasScreen(                    
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        
      ),
    );
  }
}