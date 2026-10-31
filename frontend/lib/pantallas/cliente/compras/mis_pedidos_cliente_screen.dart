import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/models/pedido_model.dart';
import 'package:frontend/services/pedido_service.dart';
class MisPedidosClienteScreen extends StatefulWidget {
  const MisPedidosClienteScreen({super.key});
  @override
  State<MisPedidosClienteScreen> createState() => _MisPedidosClienteScreenState();
}
class _MisPedidosClienteScreenState extends State<MisPedidosClienteScreen> {
  // Pedidos reales del cliente que llegan de GET /pedidos/mis-pedidos
  List<PedidoModel> _misPedidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  void _mostrarMensaje(String mensaje, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _cargarPedidos() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final pedidos = await PedidoService.obtenerMisPedidos();
      if (!mounted) return;
      setState(() {
        _misPedidos = pedidos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarMensaje(
        'Error al cargar tus pedidos: ${e.toString().replaceFirst('Exception: ', '')}',
        exito: false,
      );
    }
  }

  // PUT /pedidos/mis-pedidos/:id/cancelar (el backend devuelve las unidades al stock)
  Future<void> _cancelarPedido(int idPedido) async {
    final resultado = await PedidoService.cancelarMiPedido(idPedido);
    if (!mounted) return;

    final exito = resultado['success'] == true;
    _mostrarMensaje(
      exito ? 'Pedido #$idPedido cancelado exitosamente.' : resultado['message'].toString(),
      exito: exito,
    );
    await _cargarPedidos();
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.orangeAccent;
      case 'Aceptado':
        return Colors.blueAccent;
      case 'Completado':
        return AppColors.verdePrimario;
      case 'Cancelado':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
  void _confirmarCancelacion(int idPedido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'CANCELAR PEDIDO #$idPedido',
          style: EstiloTexto.tekoSubtituloSeccion.copyWith(color: Colors.redAccent, fontSize: 18),
        ),
        content: const Text(
          '¿Estás seguro de que deseas cancelar este pedido? Las unidades volverán al inventario.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('VOLVER', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              _cancelarPedido(idPedido);
            },
            child: const Text('SÍ, CANCELAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  String _formatearPrecio(num valor) {
    String precioStr = valor.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '\$${precioStr.replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
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
          'MIS PEDIDOS',
          style: EstiloTexto.tekoTituloSeccion.copyWith(fontSize: 18),
        ),
      ),
      body: FondoApp(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.verdePrimario),
                )
              : RefreshIndicator(
                  color: AppColors.verdePrimario,
                  onRefresh: _cargarPedidos,
                  child: _misPedidos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      Text(
                        'Aún no has realizado ningún pedido.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 15),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _misPedidos.length,
                  itemBuilder: (context, index) {
                    final PedidoModel p = _misPedidos[index];
                    final int idPedido = p.idPedido;
                    final String estado = p.estado;
                    final Color colorEstado = _obtenerColorEstado(estado);
                    final List<DetallePedidoModel> detalles = p.detalles;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.grisOscuro.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.verdePrimario.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Encabezado: Número de pedido y Badge de Estado
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PEDIDO #$idPedido',
                                style: const TextStyle(
                                  fontFamily: 'Teko',
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorEstado.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colorEstado),
                                ),
                                child: Text(
                                  estado.toUpperCase(),
                                  style: TextStyle(color: colorEstado, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha: ${p.fechaFormateada}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 11),
                          ),
                          const Divider(color: Colors.white12, height: 16),
                          // Productos incluidos en la orden
                          ...detalles.map((d) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '• ${d.nombreProducto} x${d.cantidad}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  Text(
                                    _formatearPrecio(d.subtotal),
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(color: Colors.white12, height: 16),
                          // Pie de Tarjeta: Total y Botón Cancelar (si está Pendiente)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL PAGADO', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                                  Text(
                                    _formatearPrecio(p.total),
                                    style: const TextStyle(
                                      fontFamily: 'Teko',
                                      color: AppColors.verdePrimario,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              // Botón condicional según controlador: Solo cancela si es "Pendiente"
                              if (estado == 'Pendiente')
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.redAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _confirmarCancelacion(idPedido),
                                  child: const Text(
                                    'CANCELAR',
                                    style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }
}
