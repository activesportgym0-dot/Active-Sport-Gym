import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/componentes/administrador/compras/campos_producto.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class ModalCrearProducto extends StatefulWidget {
  final List<dynamic> categoriasDisponibles;
  final void Function(
    int idCategoria,
    String tipoProducto,
    XFile imagen,
    Map<String, String> textos,
  ) onCrear;

  const ModalCrearProducto({
    super.key,
    required this.categoriasDisponibles,
    required this.onCrear,
  });

  @override
  State<ModalCrearProducto> createState() => _ModalCrearProductoState();
}

class _ModalCrearProductoState extends State<ModalCrearProducto> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _saborController = TextEditingController();
  final TextEditingController _pesoNetoController = TextEditingController();
  final TextEditingController _serviciosController = TextEditingController();
  final TextEditingController _beneficiosController = TextEditingController();
  final TextEditingController _modoUsoController = TextEditingController();

  String _tipoProducto = 'consumible';
  int? _idCategoria;
  XFile? _imagenFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Por defecto queda marcada la primera categoría disponible.
    if (widget.categoriasDisponibles.isNotEmpty) {
      _idCategoria = idDeCategoria(widget.categoriasDisponibles.first);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _descripcionController.dispose();
    _saborController.dispose();
    _pesoNetoController.dispose();
    _serviciosController.dispose();
    _beneficiosController.dispose();
    _modoUsoController.dispose();
    super.dispose();
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? archivo = await _picker.pickImage(source: ImageSource.gallery);
      if (!mounted || archivo == null) return;
      setState(() => _imagenFile = archivo);
    } catch (e) {
      if (!mounted) return;
      _mostrarError('No se pudo seleccionar la imagen: $e');
    }
  }

  void _validarYCrear() {
    if (_nombreController.text.trim().isEmpty) {
      _mostrarError('El nombre del producto es obligatorio.');
      return;
    }
    final precio = int.tryParse(_precioController.text.trim());
    if (precio == null || precio <= 0) {
      _mostrarError('Ingresa un precio válido mayor a 0.');
      return;
    }
    if (int.tryParse(_stockController.text.trim()) == null) {
      _mostrarError('Ingresa el stock inicial.');
      return;
    }
    if (_idCategoria == null) {
      _mostrarError('Selecciona una categoría');
      return;
    }
    if (_imagenFile == null) {
      _mostrarError('La foto del producto es obligatoria');
      return;
    }

    final esConsumible = _tipoProducto == 'consumible';
    final textos = <String, String>{
      'nombre': _nombreController.text.trim(),
      'marca': _marcaController.text.trim(),
      'precio': _precioController.text.trim(),
      'stock': _stockController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      // Los campos de consumible solo se envían si el producto es consumible.
      'sabor': esConsumible ? _saborController.text.trim() : '',
      'peso_neto': esConsumible ? _pesoNetoController.text.trim() : '',
      'servicios': esConsumible ? _serviciosController.text.trim() : '',
      'beneficios': esConsumible ? _beneficiosController.text.trim() : '',
      'modo_uso': esConsumible ? _modoUsoController.text.trim() : '',
    };

    widget.onCrear(_idCategoria!, _tipoProducto, _imagenFile!, textos);
  }

  @override
  Widget build(BuildContext context) {
    final esConsumible = _tipoProducto == 'consumible';

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.fondoNegro,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NUEVO PRODUCTO',
            style: EstiloTexto.tituloBienvenida.copyWith(
              fontSize: 20,
              color: AppColors.verdePrimario,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView(
              children: [
                SelectorTipoProducto(
                  tipo: _tipoProducto,
                  onChanged: (nuevo) => setState(() => _tipoProducto = nuevo),
                ),
                const SizedBox(height: 16),
                DropdownCategoriaProducto(
                  categorias: widget.categoriasDisponibles,
                  idSeleccionada: _idCategoria,
                  onChanged: (id) => setState(() => _idCategoria = id),
                ),
                const SizedBox(height: 16),
                Text(
                  'FOTO DEL PRODUCTO (Obligatoria)',
                  style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                    color: AppColors.verdePrimario,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                SelectorImagenProducto(
                  imagen: _imagenFile,
                  onTap: _seleccionarImagen,
                ),
                const SizedBox(height: 16),
                CampoProducto(
                  controller: _nombreController,
                  label: 'Nombre del Producto *',
                  icono: Icons.shopping_cart,
                ),
                const SizedBox(height: 12),
                CampoProducto(
                  controller: _marcaController,
                  label: 'Marca',
                  icono: Icons.business,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CampoProducto(
                        controller: _precioController,
                        label: 'Precio (\$)*',
                        icono: Icons.attach_money,
                        esNumero: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CampoProducto(
                        controller: _stockController,
                        label: 'Stock Inicial *',
                        icono: Icons.inventory,
                        esNumero: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (esConsumible) ...[
                  const Divider(color: AppColors.verdePrimario, height: 24),
                  const Text(
                    'ESPECIFICACIONES NUTRICIONALES',
                    style: TextStyle(
                      color: AppColors.verdePrimario,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CampoProducto(
                    controller: _saborController,
                    label: 'Sabor (Ej. Vainilla, Chocolate)',
                    icono: Icons.local_drink,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CampoProducto(
                          controller: _pesoNetoController,
                          label: 'Peso Neto (Ej. 900 g)',
                          icono: Icons.scale,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CampoProducto(
                          controller: _serviciosController,
                          label: 'Servicios / Porciones',
                          icono: Icons.countertops,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CampoProducto(
                    controller: _beneficiosController,
                    label: 'Beneficios',
                    icono: Icons.thumb_up,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  CampoProducto(
                    controller: _modoUsoController,
                    label: 'Modo de Uso',
                    icono: Icons.help_outline,
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 12),
                CampoProducto(
                  controller: _descripcionController,
                  label: 'Descripción general',
                  icono: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.verdePrimario),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCELAR',
                    style: EstiloTexto.botonPrincipal.copyWith(
                      fontSize: 14,
                      color: AppColors.verdePrimario,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrimario,
                    foregroundColor: AppColors.fondoNegro,
                  ),
                  onPressed: _validarYCrear,
                  child: Text(
                    'GUARDAR',
                    style: EstiloTexto.botonPrincipal.copyWith(
                      fontSize: 14,
                      color: AppColors.fondoNegro,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
