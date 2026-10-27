import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

class ResumenCompraScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double totalPagar;

  const ResumenCompraScreen({
    super.key,
    required this.items,
    required this.totalPagar,
  });

  String _formatearPrecio(num valor) {
    String precioStr = valor.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '\$${precioStr.replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  void _procesarPedido(BuildContext context) {
    // Simulación de respuesta exitosa del backend (confirmarPedido -> url_whatsapp)
    int idPedidoFicticio = 1050;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
              'Tu pedido #$idPedidoFicticio ha sido registrado exitosamente en estado "Pendiente".',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Text(
              'Total: ${_formatearPrecio(totalPagar)}',
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
            onPressed: () {
              Navigator.pop(context); // Cierra modal
              Navigator.pop(context, true); // Regresa al carrito notificando éxito para vaciarlo
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
                        children: items.map((item) {
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
                          _formatearPrecio(totalPagar),
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
                        onPressed: () => _procesarPedido(context),
                        child: const Text(
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