import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/compras/modal_filtro_categorias.dart';
import 'package:frontend/componentes/administrador/entrenar/category_chip.dart';
import 'package:frontend/componentes/administrador/entrenar/modal_seleccion_multiples_categorias.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/componentes/cliente/entrenar/barra_busqueda_cliente.dart';
import 'package:frontend/componentes/cliente/entrenar/tarjeta_ejercicio_cliente.dart';
import 'package:frontend/pantallas/cliente/detalle_ejercicio_cliente.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';

class EntrenarClienteScreen extends StatefulWidget {
  final String categoriaInicial;

  const EntrenarClienteScreen({
    super.key,
    this.categoriaInicial = 'Todos',
  });

  @override
  State<EntrenarClienteScreen> createState() => _EntrenarClienteScreenState();
}

class _EntrenarClienteScreenState extends State<EntrenarClienteScreen> {
  late String categoriaSeleccionada;
  List<String> categoriasFiltroAvanzado = []; 
  final TextEditingController _searchController = TextEditingController();

  List<String> listaCategoriasEntrenamiento = ['Cardio', 'Tren superior', 'Piernas', 'Glúteos', 'Resistencia'];

  // Lista simulada de ejercicios
  final List<Map<String, dynamic>> _todosLosEjercicios = [
    {
      'title': 'Crunch',
      'category': 'Tren superior',
      'description': 'Sirve específicamente para aislar y fortalecer el recto abdominal...',
      'imagePath': 'assets/images/3.jpg',
    },
    {
      'title': 'Press militar',
      'category': 'Tren superior',
      'description': 'Ejercicio fundamental para el desarrollo del hombro...',
      'imagePath': 'assets/images/4.jpg',
    },
    {
      'title': 'Salto de cuerda',
      'category': 'Cardio',
      'description': 'Excelente ejercicio aeróbico para mejorar la resistencia cardiovascular...',
      'imagePath': 'assets/images/3.jpg',
    },
  ];

  // Lógica de filtrado combinada (Buscador + Chips simples + Filtro avanzado)
  List<Map<String, dynamic>> get ejerciciosFiltrados {
    String textoBusqueda = _searchController.text.toLowerCase().trim();

    return _todosLosEjercicios.where((ejercicio) {
      bool coincideTexto = textoBusqueda.isEmpty ||
          ejercicio['title']!.toLowerCase().contains(textoBusqueda) || 
          ejercicio['description']!.toLowerCase().contains(textoBusqueda);
         
      bool coincideCategoriaSimple = categoriaSeleccionada.toLowerCase() == 'todos' || 
          ejercicio['category']!.toLowerCase() == categoriaSeleccionada.toLowerCase();

      bool coincideFiltroAvanzado = categoriasFiltroAvanzado.isEmpty || 
          categoriasFiltroAvanzado.map((c) => c.toLowerCase()).contains(ejercicio['category']!.toLowerCase());

      return coincideTexto && (categoriasFiltroAvanzado.isNotEmpty ? coincideFiltroAvanzado : coincideCategoriaSimple);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    categoriaSeleccionada = widget.categoriaInicial;

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _abrirModalFiltros() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filtro',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              top: 135,
              right: 16,
              left: 60,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 380),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.9),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ModalSeleccionMultiplesCategorias(
                      categoriasDisponibles: listaCategoriasEntrenamiento,
                      categoriasSeleccionadasIniciales: categoriasFiltroAvanzado,
                      tituloModal: 'FILTRAR CATEGORÍAS',
                      onCategoriasGuardadas: (nuevasSeleccionadas) {
                        setState(() {
                          categoriasFiltroAvanzado = nuevasSeleccionadas;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listaActual = ejerciciosFiltrados;

    final categoriasVisibles = categoriasFiltroAvanzado.isNotEmpty 
        ? categoriasFiltroAvanzado 
        : ['Todos', ...listaCategoriasEntrenamiento];

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ENTRENAMIENTO Y EJERCICIOS',
          style: EstiloTexto.bienvenida.copyWith(
            fontFamily: 'Oswald',
            fontSize: 16,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: FondoApp(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de búsqueda y filtros modularizada
              BarraBusquedaCliente(
                searchController: _searchController,
                onOpenFilters: _abrirModalFiltros,
              ),
              const SizedBox(height: 12),

              // Título de Categorías con su icono idéntico al de Compras
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.category, color: AppColors.verdePrimario, size: 16),
                    const SizedBox(width: 6),
                    Text('CATEGORÍAS', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Chips de categorías horizontales
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: categoriasVisibles.map((cat) {
                    bool estaSeleccionado = categoriasFiltroAvanzado.isNotEmpty 
                        ? categoriasFiltroAvanzado.contains(cat) 
                        : categoriaSeleccionada.toLowerCase() == cat.toLowerCase();

                    return CategoryChip(
                      label: cat,
                      isSelected: estaSeleccionado,
                      onTap: () {
                        setState(() {
                          if (categoriasFiltroAvanzado.isNotEmpty) {
                            if (categoriasFiltroAvanzado.contains(cat)) {
                              categoriasFiltroAvanzado.remove(cat);
                            } else {
                              categoriasFiltroAvanzado.add(cat);
                            }
                          } else {
                            categoriaSeleccionada = cat;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('EJERCICIOS DISPONIBLES', style: EstiloTexto.enlaceNegritaRoboto.copyWith(letterSpacing: 1.1)),
                    Text('${listaActual.length} en total', style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Listado de ejercicios
              Expanded(
                child: listaActual.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron ejercicios.',
                          style: TextStyle(color: AppColors.grisClaro, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: listaActual.length,
                        itemBuilder: (context, index) {
                          final ej = listaActual[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TarjetaEjercicioCliente(
                              category: ej['category']!,
                              title: ej['title']!,
                              description: ej['description']!,
                              imagePath: ej['imagePath']!,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetalleEjercicioClienteScreen(
                                      ejercicio: ej,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const BurbujaMiniChatModal(),
    );
  }
}