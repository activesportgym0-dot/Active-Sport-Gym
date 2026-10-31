import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/componentes/cliente/entrenar/barra_busqueda_cliente.dart';
import 'package:frontend/componentes/administrador/entrenar/category_chip.dart';
import 'package:frontend/componentes/administrador/entrenar/modal_seleccion_multiples_categorias.dart';
import 'package:frontend/componentes/cliente/compras/tarjeta_producto_cliente.dart';
import 'package:frontend/pantallas/cliente/compras/carrito_screen.dart';
import 'package:frontend/pantallas/cliente/compras/detalle_producto_cliente_screen.dart';
import 'package:frontend/models/producto_model.dart';
import 'package:frontend/services/producto_service.dart';
class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});
  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}
class _ComprasScreenState extends State<ComprasScreen> {
  String _categoriaSeleccionada = 'Todos';
  final TextEditingController _searchController = TextEditingController();
  List<String> _categoriasSeleccionadasFiltro = [];

  // Datos reales que vienen del backend (GET /producto y GET /categorias-productos)
  List<ProductoModel> _productos = [];
  List<dynamic> _categoriasObj = [];
  bool _isLoading = true;

  // Nombres de las categorías (para los chips y el filtro avanzado)
  List<String> get _nombresCategorias {
    return _categoriasObj
        .whereType<Map>()
        .map((c) => (c['nombre'] ?? '').toString())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  // El producto solo trae id_categoria; aquí se traduce al nombre
  String _nombreCategoria(int idCategoria) {
    for (final c in _categoriasObj) {
      if (c is Map && int.tryParse(c['id_categoria'].toString()) == idCategoria) {
        return c['nombre'].toString();
      }
    }
    return 'Sin categoría';
  }

  Future<void> _cargarDatos() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final productosRemotos = await ProductoService.obtenerProductos();
      final categoriasRemotas = await ProductoService.obtenerCategorias();

      if (!mounted) return;
      setState(() {
        _productos = productosRemotos
            .whereType<Map>()
            .map((p) => ProductoModel.fromJson(Map<String, dynamic>.from(p)))
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

  List<Map<String, dynamic>> get _productosFiltrados {
    String textoBusqueda = _searchController.text.toLowerCase().trim();

    // Cada producto se convierte al mapa que ya usan la tarjeta y el detalle
    final lista = _productos
        .map((p) => p.toMapaCliente(nombreCategoria: _nombreCategoria(p.idCategoria)))
        .toList();

    return lista.where((p) {
      final String nombre = p['nombre'].toString().toLowerCase();
      final String marca = p['marca'].toString().toLowerCase();
      final String categoria = p['categoria'].toString();

      bool coincideTexto = textoBusqueda.isEmpty ||
          nombre.contains(textoBusqueda) ||
          marca.contains(textoBusqueda);

      bool coincideCategoriaPrincipal =
          _categoriaSeleccionada == 'Todos' || categoria == _categoriaSeleccionada;

      bool coincideFiltroAvanzado = _categoriasSeleccionadasFiltro.isEmpty ||
          _categoriasSeleccionadasFiltro.map((c) => c.toLowerCase()).contains(categoria.toLowerCase());

      return coincideTexto &&
          (_categoriasSeleccionadasFiltro.isNotEmpty ? coincideFiltroAvanzado : coincideCategoriaPrincipal);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    _cargarDatos();
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void _mostrarFiltroDesplegable(BuildContext context) {
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
                      categoriasDisponibles: _nombresCategorias,
                      categoriasSeleccionadasIniciales: _categoriasSeleccionadasFiltro,
                      tituloModal: 'FILTRAR CATEGORÍAS',
                      onCategoriasGuardadas: (nuevasSeleccionadas) {
                        setState(() {
                          _categoriasSeleccionadasFiltro = nuevasSeleccionadas;
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
    final listaActual = _productosFiltrados;
    final categoriasVisibles = _categoriasSeleccionadasFiltro.isNotEmpty
        ? _categoriasSeleccionadasFiltro
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
        title: Text('COMPRAS', style: EstiloTexto.tekoTituloSeccion),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: AppColors.verdePrimario),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarritoScreen()
                ),
              );
              // Al volver del carrito se recarga: si hubo una compra, el stock cambió
              if (mounted) _cargarDatos();
            },
          ),
        ],
      ),
      body: FondoApp(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Encuentra los mejores suplementos y productos para tu entrenamiento.',
                    style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[400], fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
                // 👈 Barra de Búsqueda correctamente instanciada con sus parámetros requeridos
                BarraBusquedaCliente(
                  searchController: _searchController,
                  onOpenFilters: () => _mostrarFiltroDesplegable(context),
                  tieneFiltrosActivos: _categoriasSeleccionadasFiltro.isNotEmpty,
                ),
                const SizedBox(height: 12),
                // Título de Categorías con icono
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
               
                // Chips horizontales
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categoriasVisibles.length,
                    itemBuilder: (context, index) {
                      final categoria = categoriasVisibles[index];
                      final estaSeleccionada = _categoriasSeleccionadasFiltro.isNotEmpty
                          ? _categoriasSeleccionadasFiltro.contains(categoria)
                          : _categoriaSeleccionada == categoria;
                     
                      return CategoryChip(
                        label: categoria,
                        isSelected: estaSeleccionada,
                        onTap: () {
                          setState(() {
                            if (_categoriasSeleccionadasFiltro.isNotEmpty) {
                              if (_categoriasSeleccionadasFiltro.contains(categoria)) {
                                _categoriasSeleccionadasFiltro.remove(categoria);
                              } else {
                                _categoriasSeleccionadasFiltro.add(categoria);
                              }
                            } else {
                              _categoriaSeleccionada = categoria;
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Listado de Productos (desliza hacia abajo para refrescar)
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.verdePrimario),
                        )
                      : RefreshIndicator(
                          color: AppColors.verdePrimario,
                          onRefresh: _cargarDatos,
                          child: listaActual.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    const SizedBox(height: 120),
                                    Center(
                                      child: Text(
                                        'No se encontraron productos.',
                                        style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[500], fontSize: 13),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  itemCount: listaActual.length,
                                  itemBuilder: (context, index) {
                                    final producto = listaActual[index];
                                    return TarjetaProductoCliente(
                                      producto: producto,
                                      onVerMas: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetalleProductoClienteScreen(
                                              producto: producto,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
            const BurbujaMiniChatModal(),
          ],
        ),
      ),
    );
  }
}
