import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/models/pedido_model.dart';
import 'package:frontend/services/pedido_service.dart';
class ResumenCompraScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalPagar;
  const ResumenCompraScreen({
    super.key,
    required this.items,
    required this.totalPagar,
  });
  @override
  State<ResumenCompraScreen> createState() => _ResumenCompraScreenState();
}
class _ResumenCompraScreenState extends State<ResumenCompraScreen> {
  bool _procesando = false; // evita confirmar el pedido dos veces
  String _formatearPrecio(num valor) {
    String precioStr = valor.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '\$${precioStr.replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }
  // Confirma el pedido en el backend (POST /pedidos/confirmar): el servidor toma el
  // carrito del cliente, descuenta el stock, lo vacía y devuelve el enlace de WhatsApp.
  Future<void> _procesarPedido() async {
    if (_procesando) return;
    setState(() => _procesando = true);

    final resultado = await PedidoService.confirmarPedido();
    if (!mounted) return;
    setState(() => _procesando = false);

    if (resultado['success'] != true) {
      // Por ejemplo: "Sin stock suficiente para ...", "El carrito está vacío."
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message'].toString()),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final PedidoModel? pedido = resultado['pedido'] as PedidoModel?;
    final String? urlWhatsapp = resultado['url_whatsapp'] as String?;
    final num totalConfirmado = pedido?.total ?? widget.totalPagar;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¡PEDIDO CONFIRMADO!',
          style: EstiloTexto.tekoSubtituloSeccion.copyWith(
            color: AppColors.verdePrimario,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu pedido ${pedido != null ? '#${pedido.idPedido} ' : ''}ha sido registrado exitosamente en estado "Pendiente".',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Text(
              'Total: ${_formatearPrecio(totalConfirmado)}',
              style: const TextStyle(
                color: AppColors.verdePrimario,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A continuación, se abrirá WhatsApp para coordinar el pago y la entrega con el gimnasio.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.verdePrimario,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); // Cierra el modal
              await _abrirWhatsApp(urlWhatsapp);
              if (mounted) {
                Navigator.pop(context, true); // Regresa al carrito notificando éxito
              }
            },
            child: const Text(
              'IR A WHATSAPP',
              style: TextStyle(
                color: AppColors.fondoNegro,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Abre el enlace wa.me que devolvió el backend. El pedido ya quedó registrado,
  // así que si WhatsApp no se puede abrir solo se avisa.
  Future<void> _abrirWhatsApp(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final abierto = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!abierto && mounted) _avisarSinWhatsApp();
    } catch (_) {
      if (mounted) _avisarSinWhatsApp();
    }
  }

  void _avisarSinWhatsApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo abrir WhatsApp. Tu pedido ya quedó registrado.'),
        backgroundColor: Colors.orange,
      ),
    );
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
          'RESUMEN DE COMPRA',
          style: EstiloTexto.tekoTituloSeccion.copyWith(fontSize: 18),
        ),
      ),
      body: FondoApp(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 1. Sección: Productos solicitados
                    Text(
                      'PRODUCTOS SELECCIONADOS',
                      style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.grisOscuro.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: widget.items.map((item) {
                          final num precio = item['precio'] ?? 0;
                          final int cantidad = item['cantidad'] ?? 1;
                          final num subtotal = precio * cantidad;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item['nombre']} (x$cantidad)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatearPrecio(subtotal),
                                  style: const TextStyle(
                                    color: AppColors.verdePrimario,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 2. Sección: Método de Entrega
                    Text(
                      'MÉTODO DE CONFIRMACIÓN Y ENTREGA',
                      style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.grisOscuro.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_chat_read_outlined, color: AppColors.verdePrimario, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Coordinación por WhatsApp',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Al confirmar, se enviará el detalle de tu orden al número oficial de Active Sport Gym.',
                                  style: TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 3. Tarjeta Inferior de Pago
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grisOscuro,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL A PAGAR:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatearPrecio(widget.totalPagar),
                          style: const TextStyle(
                            fontFamily: 'Teko',
                            color: AppColors.verdePrimario,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
                        onPressed: _procesando ? null : _procesarPedido,
                        child: _procesando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: AppColors.fondoNegro,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'FINALIZAR COMPRA',
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
    );
  }
}
