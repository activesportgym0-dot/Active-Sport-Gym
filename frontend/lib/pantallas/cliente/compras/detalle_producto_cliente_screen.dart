import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

class DetalleProductoClienteScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  const DetalleProductoClienteScreen({
    super.key,
    required this.producto,
  });

  @override
  State<DetalleProductoClienteScreen> createState() => _DetalleProductoClienteScreenState();
}

class _DetalleProductoClienteScreenState extends State<DetalleProductoClienteScreen> {
  // Método seguro para parsear el stock
  int _obtenerStockSeguro(dynamic valor) {
    if (valor == null) return 0;
    if (valor is int) return valor;
    String soloNumeros = valor.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(soloNumeros) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Usamos widget.producto para acceder a las propiedades desde el State
    final String tipoProducto = widget.producto['tipo_producto'] ?? 'consumible';
    final bool esConsumible = tipoProducto == 'consumible';
    
    final int stock = _obtenerStockSeguro(widget.producto['stock_int'] ?? widget.producto['stock']);
    final bool hayStock = stock > 0;

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
          'DETALLE DEL PRODUCTO',
          style: EstiloTexto.tekoTituloSeccion.copyWith(fontSize: 18),
        ),
      ),
      body: FondoApp(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Imagen Principal
              Center(
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _construirImagen(widget.producto['imagen'] ?? widget.producto['imagePath']),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Nombre, Marca y Precio
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.producto['marca'] != null || widget.producto['brand'] != null)
                          Text(
                            (widget.producto['marca'] ?? widget.producto['brand']).toString().toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'RobotoCondensed',
                              color: AppColors.verdePrimario,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          widget.producto['nombre'] ?? widget.producto['name'] ?? 'Sin nombre',
                          style: const TextStyle(
                            fontFamily: 'RobotoCondensed',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.producto['precio'] ?? widget.producto['price'] ?? '\$0',
                    style: const TextStyle(
                      fontFamily: 'Teko',
                      color: AppColors.verdePrimario,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Badges de Stock y Tipo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: hayStock ? AppColors.verdePrimario.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: hayStock ? AppColors.verdePrimario : Colors.redAccent),
                    ),
                    child: Text(
                      hayStock ? 'Stock disponible ($stock)' : 'Agotado (Sin stock)',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: hayStock ? AppColors.verdePrimario : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grisOscuro,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Text(
                      esConsumible ? 'Suplemento / Consumible' : 'Material / Accesorio',
                      style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[300], fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Especificaciones Técnicas (Si es Consumible)
              if (esConsumible) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(icon: Icons.local_drink, titulo: 'Sabor', valor: widget.producto['sabor'] ?? 'General'),
                      _buildDividerVertical(),
                      _buildInfoItem(icon: Icons.scale, titulo: 'Peso Neto', valor: widget.producto['peso_neto'] ?? 'N/A'),
                      _buildDividerVertical(),
                      _buildInfoItem(icon: Icons.flash_on, titulo: 'Servicios', valor: widget.producto['servicios'] != null ? '${widget.producto['servicios']} serv.' : 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 5. Descripción General
              Text('DESCRIPCIÓN', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                widget.producto['descripcion'] ?? 'Este producto no cuenta con una descripción detallada en este momento.',
                style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[300], fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),

              // 6. Beneficios (Si es Consumible)
              if (esConsumible) ...[
                Text('BENEFICIOS', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  widget.producto['beneficios'] ?? 'Ayuda a mejorar la recuperación muscular y potencia tus entrenamientos.',
                  style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[300], fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
              ],

              // 7. Modo de Uso (Si es Consumible)
              if (esConsumible) ...[
                Text('MODO DE USO', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  widget.producto['modo_uso'] ?? 'Mezclar una porción con agua o tu bebida preferida.',
                  style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[300], fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 30),
              ],

              // 8. Botón Exclusivo de Cliente (Agregar al Carrito / Alerta de Stock)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hayStock ? AppColors.verdePrimario : AppColors.grisOscuro,
                    foregroundColor: hayStock ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: hayStock ? Colors.transparent : Colors.grey.withOpacity(0.4)),
                    ),
                  ),
                  onPressed: () {
                    // Aquí conectarás la lógica del carrito más adelante
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(hayStock ? '¡Producto agregado al carrito!' : 'Te avisaremos cuando haya stock disponible.'),
                        backgroundColor: Colors.black87,
                      ),
                    );
                  },
                  child: Text(
                    hayStock ? 'Agregar al Carrito' : 'Solicitar aviso de stock',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: const BurbujaMiniChatModal(),
    );
  }

  Widget _construirImagen(dynamic rutaImagen) {
    if (rutaImagen == null || rutaImagen.toString().isEmpty) {
      return const Icon(Icons.image, color: Colors.white54, size: 60);
    }
    String pathStr = rutaImagen.toString();
    if (pathStr.startsWith('assets/')) {
      return Image.asset(pathStr, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.white54, size: 60));
    } else {
      return Image.network(pathStr, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.white54, size: 60));
    }
  }

  Widget _buildInfoItem({required IconData icon, required String titulo, required String valor}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.verdePrimario, size: 20),
        const SizedBox(height: 4),
        Text(titulo, style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[400], fontSize: 10)),
        const SizedBox(height: 2),
        Text(valor, style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildDividerVertical() {
    return Container(height: 35, width: 1, color: Colors.grey.withOpacity(0.3));
  }
}