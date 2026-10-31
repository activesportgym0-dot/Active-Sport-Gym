import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/cliente/compras/mis_pedidos_cliente_screen.dart';
import 'package:frontend/pantallas/cliente/compras/resumen_compra_screen.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/services/carrito_service.dart';
class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});
  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}
class _CarritoScreenState extends State<CarritoScreen> {
  // Estructura sincronizada con el controlador: id_carrito, id_producto, nombre, precio, imagen_url, cantidad, stock_disponible, subtotal
  // Los datos reales llegan de GET /carrito
  List<Map<String, dynamic>> _itemsCarrito = [];
  bool _isLoading = true;
  bool _actualizando = false; // evita taps repetidos mientras el servidor responde

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  void _mostrarMensaje(String mensaje, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _cargarCarrito() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final carrito = await CarritoService.obtenerCarrito();
      if (!mounted) return;
      setState(() {
        _itemsCarrito = carrito.items.map((i) => i.toMapaPantalla()).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarMensaje(
        'Error al cargar el carrito: ${e.toString().replaceFirst('Exception: ', '')}',
        exito: false,
      );
    }
  }

  // Recalcular el total general tal cual lo entrega el endpoint verCarrito (total_pagar)
  double get _totalPagar {
    double total = 0;
    for (var item in _itemsCarrito) {
      double precio = (item['precio'] is num) ? (item['precio'] as num).toDouble() : 0.0;
      int cant = (item['cantidad'] is int) ? item['cantidad'] as int : 1;
      total += precio * cant;
    }
    return total;
  }
  // Fija la cantidad en el servidor (PUT /carrito/item/:id) y, si lo acepta, en pantalla
  Future<void> _cambiarCantidad(int index, int nuevaCantidad) async {
    if (_actualizando) return;
    setState(() => _actualizando = true);

    final resultado = await CarritoService.cambiarCantidad(
      idCarrito: _itemsCarrito[index]['id_carrito'] as int,
      cantidad: nuevaCantidad,
    );
    if (!mounted) return;

    setState(() {
      _actualizando = false;
      if (resultado['success'] == true) {
        _itemsCarrito[index]['cantidad'] = nuevaCantidad;
      }
    });
    if (resultado['success'] != true) {
      _mostrarMensaje(resultado['message'].toString(), exito: false);
    }
  }

  void _incrementarCantidad(int index) {
    final item = _itemsCarrito[index];
    int stock = (item['stock_disponible'] is int) ? item['stock_disponible'] : 99;
    int cantidadActual = item['cantidad'] as int;

    if (cantidadActual < stock) {
      _cambiarCantidad(index, cantidadActual + 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No puedes agregar más. Máximo stock disponible: $stock'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _decrementarCantidad(int index) {
    int cantidadActual = _itemsCarrito[index]['cantidad'] as int;
    if (cantidadActual > 1) {
      _cambiarCantidad(index, cantidadActual - 1);
    }
  }

  // DELETE /carrito/item/:id
  Future<void> _eliminarItem(int index) async {
    if (_actualizando) return;
    setState(() => _actualizando = true);

    final resultado = await CarritoService.eliminarItem(
      _itemsCarrito[index]['id_carrito'] as int,
    );
    if (!mounted) return;

    setState(() {
      _actualizando = false;
      if (resultado['success'] == true) {
        _itemsCarrito.removeAt(index);
      }
    });
    if (resultado['success'] != true) {
      _mostrarMensaje(resultado['message'].toString(), exito: false);
    }
  }

  String _formatearPrecio(num valor) {
    String precioStr = valor.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '\$${precioStr.replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }
  Widget _construirImagen(dynamic rutaImagen) {
    if (rutaImagen == null || rutaImagen.toString().isEmpty) {
      return const Icon(Icons.shopping_bag, color: Colors.white54, size: 40);
    }
    String pathStr = rutaImagen.toString();
    if (pathStr.startsWith('assets/')) {
      return Image.asset(pathStr, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag, color: Colors.white54, size: 40));
    } else {
      return Image.network(pathStr, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag, color: Colors.white54, size: 40));
    }
  }
  @override
  Widget build(BuildContext context) {
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
          'MI CARRITO',
          style: EstiloTexto.tekoTituloSeccion.copyWith(fontSize: 18),
        ),
        actions: [
          // 👈 Botón para ver el historial de Mis Pedidos
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: AppColors.verdePrimario, size: 22),
            tooltip: 'Mis Pedidos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MisPedidosClienteScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Listado de Productos
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.verdePrimario),
                      )
                    : _itemsCarrito.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.remove_shopping_cart_outlined, size: 64, color: Colors.grey[600]),
                            const SizedBox(height: 12),
                            Text(
                              'Tu carrito está vacío',
                              style: TextStyle(color: Colors.grey[400], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _itemsCarrito.length,
                        itemBuilder: (context, index) {
                          final item = _itemsCarrito[index];
                          final num precioUnitario = item['precio'] ?? 0;
                          final int cant = item['cantidad'] ?? 1;
                          final num subtotal = precioUnitario * cant;
                          final int stock = item['stock_disponible'] ?? 0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.grisOscuro.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                // Imagen
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _construirImagen(item['imagen_url']),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Info del Producto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nombre'] ?? 'Producto',
                                        style: const TextStyle(
                                          fontFamily: 'RobotoCondensed',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Stock disponible: $stock',
                                        style: TextStyle(
                                          color: stock < 3 ? Colors.orangeAccent : Colors.grey[400],
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatearPrecio(subtotal),
                                        style: const TextStyle(
                                          fontFamily: 'Teko',
                                          color: AppColors.verdePrimario,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Controles (+ / - y Eliminar)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                      onPressed: () => _eliminarItem(index),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.verdePrimario.withOpacity(0.5)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () => _decrementarCantidad(index),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              child: Text('-', style: TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 16)),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            color: Colors.black26,
                                            child: Text(
                                              '$cant',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => _incrementarCantidad(index),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              child: Text('+', style: TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 16)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              // 2. Tarjeta de Resumen y Confirmación
              if (_itemsCarrito.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:', style: TextStyle(color: Colors.grey[300], fontSize: 14)),
                          Text(_formatearPrecio(_totalPagar), style: TextStyle(color: Colors.grey[300], fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Envío:', style: TextStyle(color: Colors.grey[300], fontSize: 14)),
                          const Text('Por medio de WhatsApp', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Colors.white24, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL:',
                            style: TextStyle(
                              color: AppColors.verdePrimario,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _formatearPrecio(_totalPagar),
                            style: const TextStyle(
                              fontFamily: 'Teko',
                              color: AppColors.verdePrimario,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verdePrimario,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            // 👈 Navegación hacia la pantalla de Resumen de Compra
                            final compraExitoso = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResumenCompraScreen(
                                  items: _itemsCarrito,
                                  totalPagar: _totalPagar,
                                ),
                              ),
                            );
                            // Si se completó el pedido, el backend ya vació el carrito: se recarga
                            if (compraExitoso == true) {
                              _cargarCarrito();
                            }
                          },
                          child: const Text(
                            'CONTINUAR COMPRA',
                            style: TextStyle(
                              color: AppColors.fondoNegro,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
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
