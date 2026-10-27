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

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  String _categoriaSeleccionada = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categoriasPrincipales = [
    'Todos',
    'Proteínas',
    'Creatinas',
    'Accesorios',
    'Snacks Fitness'
  ];

  final List<String> _todasLasCategoriasFiltro = [
    'Aminoácidos / BCAAs',
    'Pre-Entrenos',
    'Quemadores de Grasa',
    'Colágeno y Salud',
    'Bebidas / Hidratación',
    'Accesorios de Entrenamiento',
    'Termos y Shakers',
    'Suplementos en Sachet',
    'Aumentar Masa Muscular',
  ];

  List<String> _categoriasSeleccionadasFiltro = [];

  final List<Map<String, dynamic>> _productos = [
    {
      'nombre': 'Proteína Whey - 5lb',
      'marca': 'ON OPTIMUM NUTRITION',
      'stock': 'Stock: 12',
      'stock_int': 12,
      'precio': '\$120.000',
      'imagen': 'assets/images/3.jpg',
      'categoria': 'Proteínas',
      'tipo_producto': 'consumible',
      'sabor': 'Vainilla Gourmet',
      'peso_neto': '5 lbs',
      'servicios': '74',
      'descripcion': 'Proteína aislada y concentrada de alta pureza para maximizar el crecimiento muscular.',
      'beneficios': 'Promueve la síntesis de proteínas y acelera la recuperación post-entrenamiento.',
      'modo_uso': 'Mezclar un scoop con 300ml de agua o leche después de entrenar.'
    },
    {
      'nombre': 'Smart Gainer - 3.25lb',
      'marca': 'ProScience',
      'stock': 'Stock: 5',
      'stock_int': 5,
      'precio': '\$98.900',
      'imagen': 'assets/images/4.jpg',
      'categoria': 'Proteínas',
      'tipo_producto': 'consumible',
      'sabor': 'Chocolate',
      'peso_neto': '3.25 lbs',
      'servicios': '15',
      'descripcion': 'Ganador de peso avanzado con aporte calórico limpio.',
      'beneficios': 'Ideal para personas con metabolismo acelerado que buscan volumen muscular.',
      'modo_uso': 'Tomar un servicio diario repartido en las comidas principales.'
    },
    {
      'nombre': 'Legend Creatina Creapure',
      'marca': 'ProScience',
      'stock': 'Stock: 12',
      'stock_int': 12,
      'precio': '\$80.000',
      'imagen': 'assets/images/5.jpg',
      'categoria': 'Creatinas',
      'tipo_producto': 'consumible',
      'sabor': 'Sin sabor',
      'peso_neto': '300g',
      'servicios': '60',
      'descripcion': 'Creatina monohidratada de máxima pureza alemana Creapure.',
      'beneficios': 'Aumenta la fuerza, la potencia y el rendimiento físico en series de alta intensidad.',
      'modo_uso': 'Consumir 5g diarios disueltos en agua.'
    },
    {
      'nombre': 'Shaker Mezclador Pro',
      'marca': 'Marca Genérica',
      'stock': 'Stock: 20',
      'stock_int': 20,
      'precio': '\$25.000',
      'imagen': 'assets/images/loguito.png',
      'categoria': 'Accesorios',
      'tipo_producto': 'material',
      'descripcion': 'Vaso mezclador hermético con rejilla de alta resistencia.',
      'beneficios': 'Evita los grumos y permite un transporte fácil de tus suplementos.'
    },
  ];

  List<Map<String, dynamic>> get _productosFiltrados {
    String textoBusqueda = _searchController.text.toLowerCase().trim();

    return _productos.where((p) {
      bool coincideTexto = textoBusqueda.isEmpty ||
          p['nombre']!.toLowerCase().contains(textoBusqueda) ||
          p['marca']!.toLowerCase().contains(textoBusqueda);

      bool coincideCategoriaPrincipal = _categoriaSeleccionada == 'Todos' || p['categoria'] == _categoriaSeleccionada;

      bool coincideFiltroAvanzado = _categoriasSeleccionadasFiltro.isEmpty ||
          _categoriasSeleccionadasFiltro.map((c) => c.toLowerCase()).contains(p['categoria']!.toLowerCase());

      return coincideTexto && (_categoriasSeleccionadasFiltro.isNotEmpty ? coincideFiltroAvanzado : coincideCategoriaPrincipal);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
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
                      categoriasDisponibles: _todasLasCategoriasFiltro,
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
        : _categoriasPrincipales;

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarritoScreen()
                ),
              );
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

                // Listado de Productos
                Expanded(
                  child: listaActual.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron productos.',
                            style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[500], fontSize: 13),
                          ),
                        )
                      : ListView.builder(
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
              ],
            ),
            const BurbujaMiniChatModal(),
          ],
        ),
      ),
    );
  }
}