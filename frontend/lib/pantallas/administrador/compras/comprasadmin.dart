import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/compras/acciones_producto.dart';
import 'package:frontend/componentes/administrador/compras/admin_producto_card.dart';
import 'package:frontend/componentes/administrador/compras/modal_filtro_categorias.dart';
import 'package:frontend/componentes/administrador/compras/modal_gestion_categorias_productos.dart';
import 'package:frontend/componentes/administrador/entrenar/category_chip.dart';
import 'package:frontend/componentes/cliente/entrenar/barra_busqueda_cliente.dart'; // 👈 Barra de búsqueda modular unificada
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/core/formato.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/administrador/compras/detalle_producto_admin_screen.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart'; // 👈 Importación de la burbuja de la IA
import 'package:frontend/services/producto_service.dart';

class ComprasAdminScreen extends StatefulWidget {
  const ComprasAdminScreen({super.key});

  @override
  State<ComprasAdminScreen> createState() => _ComprasAdminScreenState();
}

class _ComprasAdminScreenState extends State<ComprasAdminScreen> {
  String _categoriaSeleccionada = 'Todos';
  List<String> categoriasFiltroAvanzado = [];
  final TextEditingController _searchController = TextEditingController();

  // Datos que vienen del servidor
  List<dynamic> _categoriasObj = [];
  List<Map<String, dynamic>> _todosLosProductos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _cargarDatosDesdeServidor();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosDesdeServidor() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final productosRemotos = await ProductoService.obtenerProductos();
      final categoriasRemotas = await ProductoService.obtenerCategorias();

      if (!mounted) return;
      setState(() {
        _todosLosProductos = productosRemotos
            .whereType<Map>()
            .map((p) => Map<String, dynamic>.from(p))
            .toList();
        _categoriasObj = categoriasRemotas;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar la tienda: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Nombres de las categorías (para chips y filtros)
  List<String> get _nombresCategorias {
    return _categoriasObj
        .whereType<Map>()
        .map((c) => (c['nombre'] ?? '').toString())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  // El producto solo trae id_categoria; aquí se traduce al nombre.
  String _nombreCategoria(Map<String, dynamic> producto) {
    final id = int.tryParse(producto['id_categoria'].toString());
    for (final c in _categoriasObj) {
      if (c is Map && int.tryParse(c['id_categoria'].toString()) == id) {
        return c['nombre'].toString();
      }
    }
    return 'Sin categoría';
  }

  // Lógica de filtrado combinada
  List<Map<String, dynamic>> get productosFiltrados {
    final textoBusqueda = _searchController.text.toLowerCase().trim();

    return _todosLosProductos.where((producto) {
      final nombreProd = (producto['nombre'] ?? '').toString().toLowerCase();
      final marcaProd = (producto['marca'] ?? '').toString().toLowerCase();
      final nombreCat = _nombreCategoria(producto).toLowerCase();

      final coincideTexto = textoBusqueda.isEmpty ||
          nombreProd.contains(textoBusqueda) ||
          marcaProd.contains(textoBusqueda);

      final coincideCategoriaPrincipal = _categoriaSeleccionada == 'Todos' ||
          nombreCat == _categoriaSeleccionada.toLowerCase();

      final coincideFiltroAvanzado = categoriasFiltroAvanzado.isEmpty ||
          categoriasFiltroAvanzado
              .map((c) => c.toLowerCase())
              .contains(nombreCat);

      return coincideTexto &&
          (categoriasFiltroAvanzado.isNotEmpty
              ? coincideFiltroAvanzado
              : coincideCategoriaPrincipal);
    }).toList();
  }

  Future<void> _crearProducto() async {
    final creado = await AccionesProducto.crear(
      context,
      categorias: _categoriasObj,
    );
    if (creado) await _cargarDatosDesdeServidor();
  }

  Future<void> _editarProducto(Map<String, dynamic> producto) async {
    final actualizado = await AccionesProducto.editar(
      context,
      producto: producto,
      categorias: _categoriasObj,
    );
    if (actualizado != null) await _cargarDatosDesdeServidor();
  }

  Future<void> _eliminarProducto(Map<String, dynamic> producto) async {
    final eliminado = await AccionesProducto.eliminar(context, producto);
    if (eliminado) await _cargarDatosDesdeServidor();
  }

  void _abrirModalGestionCategorias() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondoNegro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ModalGestionCategoriasProductos(
        initialCategories: _categoriasObj,
        onCategoriesUpdated: _cargarDatosDesdeServidor,
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
                      categoriasDisponibles: _nombresCategorias,
                      categoriasSeleccionadasIniciales: categoriasFiltroAvanzado,
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
    final listaActual = productosFiltrados;
    final categoriasVisibles = categoriasFiltroAvanzado.isNotEmpty
        ? categoriasFiltroAvanzado
        : ['Todos', ..._nombresCategorias];

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
          'GESTIÓN DE TIENDA (ADMIN)',
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
            icon: const Icon(Icons.category_outlined, color: AppColors.blancoPuro, size: 22),
            tooltip: 'Administrar Categorías',
            onPressed: _abrirModalGestionCategorias,
          ),
        ],
      ),
      // 🌟 Usamos un Stack dentro del body para alojar el contenido y la burbuja de la IA flotando libremente
      body: FondoApp(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de Búsqueda modular unificada
                  BarraBusquedaCliente(
                    searchController: _searchController,
                    onOpenFilters: _abrirModalFiltros,
                    tieneFiltrosActivos: categoriasFiltroAvanzado.isNotEmpty,
                  ),
                  const SizedBox(height: 12),

                  // Título de Categorías con icono idéntico al de Clientes
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
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categoriasVisibles.length,
                      itemBuilder: (context, index) {
                        final cat = categoriasVisibles[index];
                        final bool estaSeleccionado = categoriasFiltroAvanzado.isNotEmpty
                            ? categoriasFiltroAvanzado.contains(cat)
                            : _categoriaSeleccionada.toLowerCase() == cat.toLowerCase();

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
                                _categoriaSeleccionada = cat;
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
                        Text('PRODUCTOS REGISTRADOS', style: EstiloTexto.enlaceNegritaRoboto.copyWith(letterSpacing: 1.1)),
                        Text('${listaActual.length} en total', style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Listado de productos con acceso al Detalle como Administrador
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.verdePrimario),
                          )
                        : listaActual.isEmpty
                            ? const Center(
                                child: Text(
                                  'No se encontraron productos.',
                                  style: TextStyle(color: AppColors.grisClaro, fontSize: 13),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                itemCount: listaActual.length,
                                itemBuilder: (context, index) {
                                  final prod = listaActual[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetalleProductoAdminScreen(
                                              producto: prod,
                                              categoriasDisponibles: _categoriasObj,
                                              onCambio: _cargarDatosDesdeServidor,
                                            ),
                                          ),
                                        );
                                      },
                                      child: AdminProductoCard(
                                        name: (prod['nombre'] ?? '').toString(),
                                        brand: (prod['marca'] ?? '').toString().isEmpty
                                            ? 'Sin marca'
                                            : prod['marca'].toString(),
                                        price: Formato.precio(prod['precio']),
                                        stock: Formato.entero(prod['stock']),
                                        imagePath: (prod['imagen_url'] ?? '').toString(),
                                        onEdit: () => _editarProducto(prod),
                                        onDelete: () => _eliminarProducto(prod),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),

              // 🌟 Burbuja de la IA interactiva y arrastrable por toda la pantalla
              const Positioned.fill(
                child: BurbujaMiniChatModal(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearProducto,
        backgroundColor: AppColors.verdePrimario,
        icon: const Icon(Icons.add, color: AppColors.fondoNegro),
        label: Text(
          'NUEVO PRODUCTO',
          style: EstiloTexto.botonPrincipal.copyWith(color: AppColors.fondoNegro, fontSize: 16),
        ),
      ),
    );
  }
}
