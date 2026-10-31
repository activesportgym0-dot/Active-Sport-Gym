import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/cliente/compras/carrito_screen.dart';
import 'package:frontend/services/carrito_service.dart';
import 'package:frontend/services/producto_service.dart';

/// Detalle de un producto para el cliente.
/// Recibe el mismo mapa que arma ProductoModel.toMapaCliente() y ComprasScreen.
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
  int _cantidad = 1;
  bool _procesando = false; // evita taps repetidos mientras el servidor responde

  Map<String, dynamic> get _p => widget.producto;

  int get _idProducto => int.tryParse(_p['id_producto'].toString()) ?? 0;
  int get _stock => int.tryParse(_p['stock_int'].toString()) ?? 0;
  bool get _esConsumible => (_p['tipo_producto'] ?? 'consumible').toString() == 'consumible';

  // Texto de un campo, o el texto por defecto si viene vacío o null
  String _texto(String clave, String porDefecto) {
    final valor = _p[clave]?.toString().trim() ?? '';
    return valor.isEmpty ? porDefecto : valor;
  }

  void _mostrarMensaje(String mensaje, {required bool exito, SnackBarAction? accion}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
        action: accion,
      ),
    );
  }

  // POST /carrito/agregar (el backend valida el stock y suma si ya estaba en el carrito)
  Future<void> _agregarAlCarrito() async {
    if (_procesando) return;
    setState(() => _procesando = true);

    final resultado = await CarritoService.agregarProducto(
      idProducto: _idProducto,
      cantidad: _cantidad,
    );
    if (!mounted) return;
    setState(() => _procesando = false);

    final exito = resultado['success'] == true;
    _mostrarMensaje(
      resultado['message']?.toString() ?? 'Operación finalizada',
      exito: exito,
      accion: exito
          ? SnackBarAction(
              label: 'VER CARRITO',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CarritoScreen()),
                );
              },
            )
          : null,
    );
  }

  // POST /producto/:id/solicitar-aviso (cuando el producto está agotado)
  Future<void> _solicitarAviso() async {
    if (_procesando) return;
    setState(() => _procesando = true);

    final resultado = await ProductoService.solicitarAvisoStock(_idProducto);
    if (!mounted) return;
    setState(() => _procesando = false);

    _mostrarMensaje(
      resultado['message']?.toString() ?? 'Operación finalizada',
      exito: resultado['success'] == true,
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
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (c, e, s) => const Center(child: iconoVacio),
      );
    }
    return Image.network(
      pathStr,
      fit: BoxFit.cover,
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

  Widget _badge(String texto, {Color? color}) {
    final Color c = color ?? Colors.grey[300]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color != null ? color.withOpacity(0.15) : AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color ?? Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontFamily: 'Roboto',
          color: c,
          fontSize: 12,
          fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSelectorCantidad() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.verdePrimario.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                '-',
                style: TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: Colors.black26,
            child: Text(
              '$_cantidad',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          InkWell(
            onTap: () {
              if (_cantidad < _stock) {
                setState(() => _cantidad++);
              } else {
                _mostrarMensaje('Máximo stock disponible: $_stock', exito: false);
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                '+',
                style: TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String marca = _texto('marca', '');
    final String servicios = _texto('servicios', '');
    final bool agotado = _stock <= 0;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: AppColors.verdePrimario),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CarritoScreen()),
              );
            },
          ),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Imagen principal del producto
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.grisOscuro.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _construirImagen(_p['imagen']),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. Marca, nombre y precio
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
                                  _texto('nombre', 'Producto'),
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
                            _texto('precio', ''),
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

                      // 3. Disponibilidad, tipo y categoría
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _badge(
                            agotado ? 'Agotado' : 'Disponibles: $_stock',
                            color: agotado ? Colors.redAccent : AppColors.verdePrimario,
                          ),
                          _badge(_esConsumible ? 'Suplemento / Consumible' : 'Material / Accesorio'),
                          if (_texto('categoria', '').isNotEmpty) _badge(_texto('categoria', '')),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 4. Especificaciones (solo consumibles)
                      if (_esConsumible) ...[
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

                      // 5. Descripción
                      Text('DESCRIPCIÓN', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(
                        _texto('descripcion', 'Sin descripción registrada.'),
                        style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[300], fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 20),

                      // 6. Beneficios y modo de uso (solo consumibles)
                      if (_esConsumible) ...[
                        Text('BENEFICIOS', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(
                          _texto('beneficios', 'Sin beneficios registrados.'),
                          style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[300], fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        Text('MODO DE USO', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(
                          _texto('modo_uso', 'Sin modo de uso registrado.'),
                          style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[300], fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),

              // 7. Barra inferior: cantidad y agregar al carrito (o aviso si está agotado)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grisOscuro,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                ),
                child: agotado
                    ? SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.verdePrimario, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _procesando ? null : _solicitarAviso,
                          icon: const Icon(Icons.notifications_active_outlined, color: AppColors.verdePrimario, size: 20),
                          label: const Text(
                            'AVISARME CUANDO HAYA STOCK',
                            style: TextStyle(
                              color: AppColors.verdePrimario,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          _buildSelectorCantidad(),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.verdePrimario,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _procesando ? null : _agregarAlCarrito,
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
                                        'AGREGAR AL CARRITO',
                                        style: TextStyle(
                                          color: AppColors.fondoNegro,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
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
