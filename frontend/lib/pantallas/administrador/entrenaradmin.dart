import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/compras/modal_filtro_categorias.dart';
import 'package:frontend/componentes/administrador/entrenar/admin_exercise_card.dart';
import 'package:frontend/componentes/administrador/entrenar/category_chip.dart';
import 'package:frontend/componentes/administrador/entrenar/modal_formulario_crear.dart';
import 'package:frontend/componentes/administrador/entrenar/modal_formulario_ejercicio.dart';
import 'package:frontend/componentes/administrador/entrenar/modal_gestion_categorias.dart';
import 'package:frontend/componentes/cliente/entrenar/barra_busqueda_cliente.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/administrador/detalle_ejercicio_admin_screen.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/services/ejercicio_service.dart';

class EntrenarAdminScreen extends StatefulWidget {
  const EntrenarAdminScreen({super.key});

  @override
  State<EntrenarAdminScreen> createState() => _EntrenarAdminScreenState();
}

class _EntrenarAdminScreenState extends State<EntrenarAdminScreen> {
  String categoriaSeleccionada = 'Todos';
  List<String> categoriasFiltroAvanzado = [];
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> listaCategoriasRemotasObj = [];
  List<String> listaCategoriasEntrenamiento = [];
  List<Map<String, dynamic>> _todosLosEjercicios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _cargarDatosDesdeServidor();
  }

  Future<void> _cargarDatosDesdeServidor() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final ejerciciosRemotos = await EjercicioService.obtenerEjercicios();
      final categoriasRemotas = await EjercicioService.obtenerCategorias();

      final Set<String> categoriasSet = {};
      for (final cat in categoriasRemotas) {
        final nombreCat = cat['nombre']?.toString() ?? '';
        if (nombreCat.isNotEmpty) categoriasSet.add(nombreCat);
      }

      for (final ej in ejerciciosRemotos) {
        final rawCats = ej['ejercicio_categoria'] as List? ?? [];
        for (final c in rawCats) {
          final nombreCat =
              c['categoria_ejercicios']?['nombre']?.toString() ?? '';
          if (nombreCat.isNotEmpty) categoriasSet.add(nombreCat);
        }
      }

      if (!mounted) return;
      setState(() {
        _todosLosEjercicios =
            List<Map<String, dynamic>>.from(ejerciciosRemotos);
        listaCategoriasRemotasObj = categoriasRemotas;
        listaCategoriasEntrenamiento = categoriasSet.toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al conectar con el servidor: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get ejerciciosFiltrados {
    final textoBusqueda = _searchController.text.toLowerCase().trim();

    return _todosLosEjercicios.where((ejercicio) {
      final titulo = (ejercicio['nombre'] ?? '').toString().toLowerCase();
      final desc =
          (ejercicio['descripcion'] ?? '').toString().toLowerCase();

      final List rawCats = ejercicio['ejercicio_categoria'] ?? [];
      final nombresCats = rawCats
          .map((r) => (r['categoria_ejercicios']?['nombre'] ?? '')
              .toString()
              .toLowerCase())
          .toList();

      final coincideTexto = textoBusqueda.isEmpty ||
          titulo.contains(textoBusqueda) ||
          desc.contains(textoBusqueda);

      final coincideCategoriaSimple = categoriaSeleccionada == 'Todos' ||
          nombresCats.contains(categoriaSeleccionada.toLowerCase());

      final coincideFiltroAvanzado = categoriasFiltroAvanzado.isEmpty ||
          categoriasFiltroAvanzado
              .any((c) => nombresCats.contains(c.toLowerCase()));

      return coincideTexto &&
          (categoriasFiltroAvanzado.isNotEmpty
              ? coincideFiltroAvanzado
              : coincideCategoriaSimple);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _abrirModalCrear() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalCrearEjercicio(
        categoriasDisponibles: listaCategoriasRemotasObj,
        onCrear: (categoriasIds, imagenFile, gifFile, textos) async {
          Navigator.pop(context);

          final resultado = await EjercicioService.crearEjercicio(
            nombre: textos['nombre']!,
            maquina: textos['maquina']!,
            descripcion: textos['descripcion']!,
            instrucciones: textos['instrucciones']!,
            beneficios: textos['beneficios']!,
            rangoMovimiento: textos['rango_movimiento']!,
            respiracion: textos['respiracion']!,
            ritmoMovimiento: textos['ritmo_movimiento']!,
            imagenFile: imagenFile,
            gifFile: gifFile,
            categoriasIds: categoriasIds,
          );

          if (!mounted) return;
          if (resultado['success'] == true) {
            await _cargarDatosDesdeServidor();
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resultado['message']?.toString() ?? 'Operación finalizada',
              ),
              backgroundColor: resultado['success'] == true
                  ? Colors.green
                  : Colors.redAccent,
            ),
          );
        },
      ),
    );
  }

  void _abrirModalEditar({required Map<String, dynamic> ejercicioAEditar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalEditarEjercicio(
        ejercicioAEditar: ejercicioAEditar,
        categoriasDisponibles: listaCategoriasRemotasObj,
        onEditar: (
          idEjercicio,
          categoriasIds,
          imagenFile,
          gifFile,
          textos,
        ) async {
          Navigator.pop(context);

          final resultado = await EjercicioService.actualizarEjercicio(
            idEjercicio: idEjercicio,
            nombre: textos['nombre']!,
            maquina: textos['maquina']!,
            descripcion: textos['descripcion']!,
            instrucciones: textos['instrucciones']!,
            beneficios: textos['beneficios']!,
            rangoMovimiento: textos['rango_movimiento']!,
            respiracion: textos['respiracion']!,
            ritmoMovimiento: textos['ritmo_movimiento']!,
            imagenFile: imagenFile,
            gifFile: gifFile,
            categoriasIds: categoriasIds,
          );

          if (!mounted) return;
          if (resultado['success'] == true) {
            await _cargarDatosDesdeServidor();
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resultado['message']?.toString() ?? 'Operación finalizada',
              ),
              backgroundColor: resultado['success'] == true
                  ? Colors.green
                  : Colors.redAccent,
            ),
          );
        },
      ),
    );
  }

  void _abrirModalGestionCategorias() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondoNegro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ModalGestionCategorias(
        initialCategories: listaCategoriasRemotasObj,
        onCategoriesUpdated: (nuevasCategorias) {
          _cargarDatosDesdeServidor();
        },
      ),
    );
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
                    child: ModalFiltroCategorias(
                      categoriasDisponibles: listaCategoriasEntrenamiento,
                      categoriasSeleccionadasIniciales:
                          categoriasFiltroAvanzado,
                      onAplicarFiltros: (nuevasSeleccionadas) {
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.verdePrimario,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'GESTIÓN DE EJERCICIOS (ADMIN)',
          style: EstiloTexto.bienvenida.copyWith(
            fontFamily: 'Oswald',
            fontSize: 16,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.category_outlined,
              color: AppColors.blancoPuro,
              size: 22,
            ),
            tooltip: 'Administrar Categorías',
            onPressed: _abrirModalGestionCategorias,
          ),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BarraBusquedaCliente(
                    searchController: _searchController,
                    onOpenFilters: _abrirModalFiltros,
                    tieneFiltrosActivos:
                        categoriasFiltroAvanzado.isNotEmpty,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categoriasVisibles.length,
                      itemBuilder: (context, index) {
                        final cat = categoriasVisibles[index];
                        final estaSeleccionado =
                            categoriasFiltroAvanzado.isNotEmpty
                                ? categoriasFiltroAvanzado.contains(cat)
                                : categoriaSeleccionada.toLowerCase() ==
                                    cat.toLowerCase();

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
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EJERCICIOS REGISTRADOS',
                          style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          '${listaActual.length} en total',
                          style: EstiloTexto.textoNormalRoboto.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.verdePrimario,
                            ),
                          )
                        : listaActual.isEmpty
                            ? const Center(
                                child: Text(
                                  'No se encontraron ejercicios.',
                                  style: TextStyle(
                                    color: AppColors.grisClaro,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                itemCount: listaActual.length,
                                itemBuilder: (context, index) {
                                  final ej = listaActual[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: GestureContainerCard(
                                      ejercicio: ej,
                                      onEdit: () => _abrirModalEditar(
                                        ejercicioAEditar: ej,
                                      ),
                                      onDeleted: _cargarDatosDesdeServidor,
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
              const Positioned.fill(
                child: BurbujaMiniChatModal(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirModalCrear,
        backgroundColor: AppColors.verdePrimario,
        icon: const Icon(Icons.add, color: AppColors.fondoNegro),
        label: Text(
          'NUEVO EJERCICIO',
          style: EstiloTexto.botonPrincipal.copyWith(
            color: AppColors.fondoNegro,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class GestureContainerCard extends StatelessWidget {
  final Map<String, dynamic> ejercicio;
  final VoidCallback onEdit;
  final VoidCallback onDeleted;

  const GestureContainerCard({
    super.key,
    required this.ejercicio,
    required this.onEdit,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final List rawCats = ejercicio['ejercicio_categoria'] ?? [];
    final String nombreCat = rawCats.isNotEmpty
        ? (rawCats.first['categoria_ejercicios']?['nombre'] ?? 'General')
            .toString()
        : 'General';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleEjercicioAdminScreen(
              ejercicio: ejercicio,
              onEditar: onEdit,
              onEliminar: () async {
                final id = int.tryParse(
                      ejercicio['id_ejercicio'].toString(),
                    ) ??
                    0;
                final eliminado =
                    await EjercicioService.eliminarEjercicio(id);
                if (eliminado) {
                  onDeleted();
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ),
        );
      },
      child: AdminExerciseCard(
        category: nombreCat,
        title: ejercicio['nombre'] ?? '',
        description: ejercicio['descripcion'] ?? '',
        imagePath: ejercicio['imagen'] ?? 'assets/images/3.jpg',
        onEdit: onEdit,
        onDelete: () async {
          final confirmar = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.grisOscuro,
              title: const Text(
                'Eliminar Ejercicio',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                '¿Estás segura de que deseas eliminar este ejercicio?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          );

          if (confirmar == true) {
            final id =
                int.tryParse(ejercicio['id_ejercicio'].toString()) ?? 0;
            final eliminado = await EjercicioService.eliminarEjercicio(id);

            if (eliminado) {
              onDeleted();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ejercicio eliminado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo eliminar el ejercicio'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
