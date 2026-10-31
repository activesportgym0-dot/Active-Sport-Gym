import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/entrenar/category_chip.dart';
import 'package:frontend/componentes/administrador/entrenar/modal_seleccion_multiples_categorias.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/componentes/cliente/entrenar/barra_busqueda_cliente.dart';
import 'package:frontend/componentes/cliente/entrenar/tarjeta_ejercicio_cliente.dart';
import 'package:frontend/pantallas/cliente/detalle_ejercicio_cliente.dart';
import 'package:frontend/services/ejercicio_service.dart';
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

  List<String> listaCategoriasEntrenamiento = [];
  List<Map<String, dynamic>> _todosLosEjercicios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    categoriaSeleccionada = widget.categoriaInicial;
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _cargarDatosDesdeBackend();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga ejercicios y categorías reales directamente desde el Backend
  Future<void> _cargarDatosDesdeBackend() async {
    if (!mounted) return;
    setState(() => _cargando = true);

    try {
      final respuestas = await Future.wait([
        EjercicioService.obtenerEjerciciosCliente(),
        EjercicioService.obtenerNombresCategoriasCliente(),
      ]);

      if (!mounted) return;

      setState(() {
        _todosLosEjercicios = respuestas[0] as List<Map<String, dynamic>>;
        listaCategoriasEntrenamiento = respuestas[1] as List<String>;
        _cargando = false;
      });
    } catch (e) {
      print('Error cargando datos de entrenamiento: $e');
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  /// Extrae el nombre de la categoría del objeto de ejercicio devuelto por el Backend
  String _obtenerCategoriaEjercicio(Map<String, dynamic> ej) {
    var relaciones = ej['ejercicio_categoria'] as List? ?? [];
    if (relaciones.isNotEmpty) {
      var cat = relaciones.first['categoria_ejercicios'];
      if (cat != null && cat['nombre'] != null) {
        return cat['nombre'].toString();
      }
    }
    return 'General';
  }

  /// Lógica de filtrado en tiempo real (Buscador + Chips simples + Filtro avanzado)
  List<Map<String, dynamic>> get ejerciciosFiltrados {
    String textoBusqueda = _searchController.text.toLowerCase().trim();

    return _todosLosEjercicios.where((ejercicio) {
      String titulo = (ejercicio['nombre'] ?? '').toString();
      String descripcion = (ejercicio['descripcion'] ?? '').toString();
      String categoriaEjercicio = _obtenerCategoriaEjercicio(ejercicio);

      bool coincideTexto = textoBusqueda.isEmpty ||
          titulo.toLowerCase().contains(textoBusqueda) ||
          descripcion.toLowerCase().contains(textoBusqueda);

      bool coincideCategoriaSimple = categoriaSeleccionada.toLowerCase() == 'todos' ||
          categoriaEjercicio.toLowerCase() == categoriaSeleccionada.toLowerCase();

      bool coincideFiltroAvanzado = categoriasFiltroAvanzado.isEmpty ||
          categoriasFiltroAvanzado
              .map((c) => c.toLowerCase())
              .contains(categoriaEjercicio.toLowerCase());

      return coincideTexto &&
          (categoriasFiltroAvanzado.isNotEmpty ? coincideFiltroAvanzado : coincideCategoriaSimple);
    }).toList();
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
              // Barra de búsqueda y filtros
              BarraBusquedaCliente(
                searchController: _searchController,
                onOpenFilters: _abrirModalFiltros,
              ),
              const SizedBox(height: 12),

              // Título de Categorías
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
                    Text('EJERCICIOS DISPONIBLES',
                        style: EstiloTexto.enlaceNegritaRoboto.copyWith(letterSpacing: 1.1)),
                    Text('${listaActual.length} en total',
                        style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Listado de ejercicios
              Expanded(
                child: _cargando
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.verdePrimario),
                      )
                    : RefreshIndicator(
                        color: AppColors.verdePrimario,
                        onRefresh: _cargarDatosDesdeBackend,
                        child: listaActual.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 100),
                                  Center(
                                    child: Text(
                                      'No se encontraron ejercicios registrados.',
                                      style: TextStyle(color: AppColors.grisClaro, fontSize: 13),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: listaActual.length,
                                itemBuilder: (context, index) {
                                  final ej = listaActual[index];
                                  final String titulo = ej['nombre'] ?? 'Ejercicio';
                                  final String descripcion =
                                      ej['descripcion'] ?? 'Sin descripción';
                                  final String imagen = ej['imagen'] ?? '';
                                  final String categoria = _obtenerCategoriaEjercicio(ej);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: TarjetaEjercicioCliente(
                                      category: categoria,
                                      title: titulo,
                                      description: descripcion,
                                      imagePath: imagen,
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const BurbujaMiniChatModal(),
    );
  }
}
