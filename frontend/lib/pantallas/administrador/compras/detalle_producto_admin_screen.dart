import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/compras/acciones_producto.dart';
import 'package:frontend/componentes/administrador/compras/campos_producto.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/core/formato.dart';
import 'package:frontend/componentes/fondo.dart';

class DetalleProductoAdminScreen extends StatefulWidget {
  final Map<String, dynamic> producto;
  final List<dynamic> categoriasDisponibles;
  final VoidCallback onCambio;

  const DetalleProductoAdminScreen({
    super.key,
    required this.producto,
    required this.categoriasDisponibles,
    required this.onCambio,
  });

  @override
  State<DetalleProductoAdminScreen> createState() => _DetalleProductoAdminScreenState();
}

class _DetalleProductoAdminScreenState extends State<DetalleProductoAdminScreen> {
  late Map<String, dynamic> _producto;

  @override
  void initState() {
    super.initState();
    _producto = Map<String, dynamic>.from(widget.producto);
  }

  int _obtenerStockSeguro(dynamic valor) {
    if (valor == null) return 0;
    if (valor is int) return valor;
    String soloNumeros = valor.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(soloNumeros) ?? 0;
  }

  String _texto(String clave, String porDefecto) {
    final valor = _producto[clave]?.toString().trim() ?? '';
    return valor.isEmpty ? porDefecto : valor;
  }

  String get _nombreCategoria {
    final id = int.tryParse(_producto['id_categoria'].toString());
    for (final c in widget.categoriasDisponibles) {
      if (c is Map && idDeCategoria(c) == id) return c['nombre'].toString();
    }
    return 'Sin categoría';
  }

  Future<void> _editar() async {
    final actualizado = await AccionesProducto.editar(
      context,
      producto: _producto,
      categorias: widget.categoriasDisponibles,
    );
    if (actualizado == null || !mounted) return;
    setState(() => _producto = {..._producto, ...actualizado});
    widget.onCambio();
  }

  Future<void> _eliminar() async {
    final eliminado = await AccionesProducto.eliminar(context, _producto);
    if (!eliminado || !mounted) return;
    Navigator.pop(context);
    widget.onCambio();
  }

  @override
  Widget build(BuildContext context) {
    final String tipoProducto = _producto['tipo_producto']?.toString() ?? 'consumible';
    final bool esConsumible = tipoProducto == 'consumible';
    final int stock = _obtenerStockSeguro(_producto['stock']);
    final String marca = _texto('marca', '');
    final String servicios = _texto('servicios', '');

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
          'GESTIÓN DE PRODUCTO (ADMIN)',
          style: EstiloTexto.tekoTituloSeccion.copyWith(fontSize: 18),
        ),
      ),
      body: FondoApp(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Imagen Principal del Producto (Ampliada de 220 a 320 de altura)
              Center(
                child: Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Material(
                      color: Colors.transparent,
                      child: _construirImagen(_producto['imagen_url']),
                    ),
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
                        if (marca.isNotEmpty)
                          Text(
                            marca.toUpperCase(),
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
                          _texto('nombre', 'Sin nombre'),
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
                    Formato.precio(_producto['precio']),
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

              // 3. Badges de Stock, Tipo de Producto y Categoría
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.verdePrimario.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.verdePrimario),
                    ),
                    child: Text(
                      'Stock en almacén: $stock',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.verdePrimario,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grisOscuro,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Text(
                      _nombreCategoria,
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
                      _buildInfoItem(icon: Icons.local_drink, titulo: 'Sabor', valor: _texto('sabor', 'General')),
                      _buildDividerVertical(),
                      _buildInfoItem(icon: Icons.scale, titulo: 'Peso Neto', valor: _texto('peso_neto', 'N/A')),
                      _buildDividerVertical(),
                      _buildInfoItem(
                        icon: Icons.flash_on,
                        titulo: 'Servicios',
                        valor: servicios.isNotEmpty ? '$servicios serv.' : 'N/A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 5. Descripción General
              Text('DESCRIPCIÓN', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                _texto('descripcion', 'Sin descripción registrada.'),
                style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[300], fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),

              // 6. Beneficios (Si es Consumible)
              if (esConsumible) ...[
                Text('BENEFICIOS', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  _texto('beneficios', 'Sin beneficios registrados.'),
                  style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[300], fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
              ],

              // 7. Modo de Uso (Si es Consumible)
              if (esConsumible) ...[
                Text('MODO DE USO', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  _texto('modo_uso', 'Sin modo de uso registrado.'),
                  style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[300], fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 30),
              ],

              // 8. Botones exclusivos de Administrador (Eliminar y Editar)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _eliminar,
                        child: const Text(
                          'ELIMINAR',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdePrimario,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _editar,
                        child: const Text(
                          'EDITAR',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirImagen(dynamic rutaImagen) {
    const iconoVacio = Icon(Icons.image, color: Colors.white54, size: 60);

    if (rutaImagen == null || rutaImagen.toString().isEmpty) {
      return const Center(child: iconoVacio);
    }

    final String pathStr = rutaImagen.toString();
    if (pathStr.startsWith('assets/')) {
      return Image.asset(
        pathStr,
        fit: BoxFit.contain, // Usamos contain para que se vea completa y nítida sin recortarse
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (c, e, s) => const Center(child: iconoVacio),
      );
    }
    return Image.network(
      pathStr,
      fit: BoxFit.contain, // Usamos contain para que la imagen del tarro de proteína luzca completa
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (c, e, s) => const Center(child: iconoVacio),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String titulo, required String valor}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.verdePrimario, size: 20),
        const SizedBox(height: 4),
        Text(titulo, style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[400], fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            fontFamily: 'RobotoCondensed',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDividerVertical() {
    return Container(height: 35, width: 1, color: Colors.grey.withOpacity(0.3));
  }
}