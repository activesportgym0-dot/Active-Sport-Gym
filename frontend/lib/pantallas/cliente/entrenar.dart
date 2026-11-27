
import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/entrenar/category_chip.dart';
import 'package:frontend/componentes/administrador/entrenar/modal_seleccion_multiples_categorias.dart';
import 'package:frontend/componentes/cliente/burbuja_mini_chat_modal.dart';
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
  State<EntrenarClienteScreen> createState() =>
      _EntrenarClienteScreenState();
}

class _EntrenarClienteScreenState extends State<EntrenarClienteScreen> {
  late String categoriaSeleccionada;

  List<String> categoriasFiltroAvanzado = [];

  final TextEditingController _searchController =
      TextEditingController();

  List<String> listaCategoriasEntrenamiento = [];

  List<Map<String, dynamic>> _todosLosEjercicios = [];

  bool _cargando = true;

  @override
  void initState() {
    super.initState();

    categoriaSeleccionada = widget.categoriaInicial;

    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _cargarDatosDesdeBackend();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARGAR EJERCICIOS Y CATEGORÍAS DESDE EL BACKEND
  // ============================================================

  Future<void> _cargarDatosDesdeBackend() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
    });

    try {
      final respuestas = await Future.wait([
        EjercicioService.obtenerEjerciciosCliente(),
        EjercicioService.obtenerNombresCategoriasCliente(),
      ]);

      if (!mounted) return;

      final ejercicios = List<Map<String, dynamic>>.from(
        respuestas[0] as List,
      );

      final categoriasSet = <String>{};

      // Obtener las categorías devueltas por el servicio.
      final categoriasRemotas = respuestas[1] as List;

      for (final categoria in categoriasRemotas) {
        final nombre = categoria.toString().trim();

        if (nombre.isNotEmpty) {
          categoriasSet.add(nombre);
        }
      }

      // Obtener TODAS las categorías relacionadas con cada ejercicio.
      for (final ejercicio in ejercicios) {
        final categorias = _obtenerTodasLasCategorias(ejercicio);

        for (final categoria in categorias) {
          categoriasSet.add(categoria);
        }
      }

      final categoriasOrdenadas = categoriasSet.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      setState(() {
        _todosLosEjercicios = ejercicios;
        listaCategoriasEntrenamiento = categoriasOrdenadas;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error cargando ejercicios del cliente: $e');

      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudieron cargar los ejercicios. Revisa tu conexión.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // OBTENER TODAS LAS CATEGORÍAS DE UN EJERCICIO
  // ============================================================

  List<String> _obtenerTodasLasCategorias(
    Map<String, dynamic> ejercicio,
  ) {
    final List<String> categorias = [];

    final dynamic relaciones = ejercicio['ejercicio_categoria'];

    if (relaciones is! List) {
      return categorias;
    }

    for (final relacion in relaciones) {
      if (relacion is! Map) continue;

      final dynamic categoria = relacion['categoria_ejercicios'];

      if (categoria is! Map) continue;

      final nombre = categoria['nombre']?.toString().trim() ?? '';

      if (nombre.isNotEmpty &&
          !categorias.any(
            (elemento) =>
                elemento.toLowerCase() == nombre.toLowerCase(),
          )) {
        categorias.add(nombre);
      }
    }

    return categorias;
  }

  // ============================================================
  // FILTRAR EJERCICIOS POR TEXTO Y POR TODAS SUS CATEGORÍAS
  // ============================================================

  List<Map<String, dynamic>> get ejerciciosFiltrados {
    final textoBusqueda =
        _searchController.text.toLowerCase().trim();

    return _todosLosEjercicios.where((ejercicio) {
      final titulo =
          (ejercicio['nombre'] ?? '').toString().toLowerCase();

      final descripcion =
          (ejercicio['descripcion'] ?? '').toString().toLowerCase();

      // IMPORTANTE:
      // Se obtienen todas las categorías, no solamente la primera.
      final categoriasEjercicio =
          _obtenerTodasLasCategorias(ejercicio);

      final categoriasNormalizadas = categoriasEjercicio
          .map((categoria) => categoria.toLowerCase())
          .toList();

      // BUSCADOR.
      final coincideTexto = textoBusqueda.isEmpty ||
          titulo.contains(textoBusqueda) ||
          descripcion.contains(textoBusqueda);

      // CATEGORÍA SIMPLE.
      final coincideCategoriaSimple =
          categoriaSeleccionada.toLowerCase() == 'todos' ||
              categoriasNormalizadas.contains(
                categoriaSeleccionada.toLowerCase(),
              );

      // FILTRO AVANZADO: permite coincidencia con cualquiera
      // de las categorías seleccionadas.
      final coincideFiltroAvanzado =
          categoriasFiltroAvanzado.isEmpty ||
              categoriasFiltroAvanzado.any(
                (categoria) => categoriasNormalizadas.contains(
                  categoria.toLowerCase(),
                ),
              );

      return coincideTexto &&
          (categoriasFiltroAvanzado.isNotEmpty
              ? coincideFiltroAvanzado
              : coincideCategoriaSimple);
    }).toList();
  }

  // ============================================================
  // ABRIR FILTROS AVANZADOS
  // ============================================================

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
                  constraints: const BoxConstraints(
                    maxHeight: 380,
                  ),
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
                      categoriasDisponibles:
                          listaCategoriasEntrenamiento,
                      categoriasSeleccionadasIniciales:
                          categoriasFiltroAvanzado,
                      tituloModal: 'FILTRAR CATEGORÍAS',
                      onCategoriasGuardadas: (nuevasSeleccionadas) {
                        setState(() {
                          categoriasFiltroAvanzado =
                              List<String>.from(nuevasSeleccionadas);
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

  // ============================================================
  // CONSTRUIR PANTALLA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final listaActual = ejerciciosFiltrados;

    final categoriasVisibles =
        categoriasFiltroAvanzado.isNotEmpty
            ? categoriasFiltroAvanzado
            : ['Todos', ...listaCategoriasEntrenamiento];

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,

      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.verdePrimario,
            size: 20,
          ),
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
              // BUSCADOR Y FILTROS.
              BarraBusquedaCliente(
                searchController: _searchController,
                onOpenFilters: _abrirModalFiltros,
              ),

              const SizedBox(height: 12),

              // TÍTULO DE CATEGORÍAS.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.category,
                      color: AppColors.verdePrimario,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'CATEGORÍAS',
                      style: EstiloTexto.tekoSubtituloSeccion.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // CHIPS DE CATEGORÍAS.
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  children: categoriasVisibles.map((categoria) {
                    final estaSeleccionado =
                        categoriasFiltroAvanzado.isNotEmpty
                            ? categoriasFiltroAvanzado.any(
                                (c) =>
                                    c.toLowerCase() ==
                                    categoria.toLowerCase(),
                              )
                            : categoriaSeleccionada.toLowerCase() ==
                                categoria.toLowerCase();

                    return CategoryChip(
                      label: categoria,
                      isSelected: estaSeleccionado,
                      onTap: () {
                        setState(() {
                          if (categoriasFiltroAvanzado.isNotEmpty) {
                            final existe =
                                categoriasFiltroAvanzado.any(
                              (c) =>
                                  c.toLowerCase() ==
                                  categoria.toLowerCase(),
                            );

                            if (existe) {
                              categoriasFiltroAvanzado.removeWhere(
                                (c) =>
                                    c.toLowerCase() ==
                                    categoria.toLowerCase(),
                              );
                            } else {
                              categoriasFiltroAvanzado.add(categoria);
                            }
                          } else {
                            categoriaSeleccionada = categoria;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // TÍTULO Y CANTIDAD DE EJERCICIOS.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EJERCICIOS DISPONIBLES',
                      style:
                          EstiloTexto.enlaceNegritaRoboto.copyWith(
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      '${listaActual.length} en total',
                      style:
                          EstiloTexto.textoNormalRoboto.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // LISTADO DE EJERCICIOS.
              Expanded(
                child: _cargando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.verdePrimario,
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.verdePrimario,
                        onRefresh: _cargarDatosDesdeBackend,
                        child: listaActual.isEmpty
                            ? ListView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 100),
                                  Center(
                                    child: Text(
                                      'No se encontraron ejercicios registrados.',
                                      style: TextStyle(
                                        color: AppColors.grisClaro,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: listaActual.length,
                                itemBuilder: (context, index) {
                                  final ejercicio =
                                      listaActual[index];

                                  final String titulo =
                                      (ejercicio['nombre'] ??
                                              'Ejercicio')
                                          .toString();

                                  final String descripcion =
                                      (ejercicio['descripcion'] ??
                                              'Sin descripción')
                                          .toString();

                                  final String imagen =
                                      (ejercicio['imagen'] ?? '')
                                          .toString();

                                  // Se muestran todas las categorías
                                  // asociadas al ejercicio.
                                  final categorias =
                                      _obtenerTodasLasCategorias(
                                    ejercicio,
                                  );

                                  final String categoria =
                                      categorias.isEmpty
                                          ? 'General'
                                          : categorias.join(' • ');

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    child: TarjetaEjercicioCliente(
                                      category: categoria,
                                      title: titulo,
                                      description: descripcion,
                                      imagePath: imagen,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetalleEjercicioClienteScreen(
                                              ejercicio: ejercicio,
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

      floatingActionButton:
          const BurbujaMiniChatModal(),
    );
  }
}
