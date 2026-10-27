import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/componentes/administrador/entrenar/admin_text_field.dart';
import 'package:frontend/componentes/administrador/entrenar/modal_seleccion_multiples_categorias.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class ModalEditarEjercicio extends StatefulWidget {
  final Map<String, dynamic> ejercicioAEditar;
  final List<dynamic> categoriasDisponibles;
  final Function(
    int idEjercicio,
    List<int> categoriasIds,
    XFile? imagen,
    XFile? gif,
    Map<String, String> textos,
  ) onEditar;

  const ModalEditarEjercicio({
    super.key,
    required this.ejercicioAEditar,
    required this.categoriasDisponibles,
    required this.onEditar,
  });

  @override
  State<ModalEditarEjercicio> createState() => _ModalEditarEjercicioState();
}

class _ModalEditarEjercicioState extends State<ModalEditarEjercicio> {
  late TextEditingController _nombreController;
  late TextEditingController _maquinaController;
  late TextEditingController _descripcionController;
  late TextEditingController _pasosController;
  late TextEditingController _beneficiosController;
  late TextEditingController _rangoMovimientoController;
  late TextEditingController _respiracionController;
  late TextEditingController _ritmoController;

  List<int> _idsCategoriasSeleccionadas = [];
  XFile? _imagenFile;
  XFile? _gifFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final ej = widget.ejercicioAEditar;

    _nombreController = TextEditingController(text: ej['nombre']?.toString() ?? '');
    _maquinaController = TextEditingController(text: ej['maquina']?.toString() ?? '');
    _descripcionController = TextEditingController(text: ej['descripcion']?.toString() ?? '');
    _pasosController = TextEditingController(text: ej['instrucciones']?.toString() ?? '');
    _beneficiosController = TextEditingController(text: ej['beneficios']?.toString() ?? '');
    _rangoMovimientoController = TextEditingController(text: ej['rango_movimiento']?.toString() ?? '');
    _respiracionController = TextEditingController(text: ej['respiracion']?.toString() ?? '');
    _ritmoController = TextEditingController(text: ej['ritmo_movimiento']?.toString() ?? '');

    // Admite las dos estructuras de categorías que puede devolver la API.
    final categoriasActuales = ej['categorias'] is List
        ? ej['categorias'] as List
        : ej['ejercicio_categoria'] is List
            ? ej['ejercicio_categoria'] as List
            : <dynamic>[];

    for (final item in categoriasActuales) {
      dynamic id;
      if (item is Map) {
        id = item['id_categoria'];
        if (id == null && item['categoria_ejercicios'] is Map) {
          id = item['categoria_ejercicios']['id_categoria'];
        }
      } else {
        id = item;
      }

      final idNumero = int.tryParse(id.toString());
      if (idNumero != null && !_idsCategoriasSeleccionadas.contains(idNumero)) {
        _idsCategoriasSeleccionadas.add(idNumero);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _maquinaController.dispose();
    _descripcionController.dispose();
    _pasosController.dispose();
    _beneficiosController.dispose();
    _rangoMovimientoController.dispose();
    _respiracionController.dispose();
    _ritmoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? archivo = await _picker.pickImage(source: ImageSource.gallery);
      if (!mounted || archivo == null) return;
      setState(() => _imagenFile = archivo);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar la imagen: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _seleccionarGif() async {
    try {
      final XFile? archivo = await _picker.pickMedia();
      if (!mounted || archivo == null) return;

      final nombre = archivo.name.toLowerCase();
      final esGif = nombre.endsWith('.gif');
      final esVideo = ['.mp4', '.webm', '.avi', '.mov', '.m4v']
          .any(nombre.endsWith);

      if (!esGif && !esVideo) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona un GIF o un video compatible.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      setState(() => _gifFile = archivo);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar el GIF o video: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _abrirModalSeleccionCategorias() {
    final nombresDisponibles = widget.categoriasDisponibles
        .map((c) => (c is Map ? c['nombre'] : c).toString())
        .toList();

    final nombresIniciales = widget.categoriasDisponibles
        .where((c) =>
            c is Map &&
            _idsCategoriasSeleccionadas.contains(
              int.tryParse(c['id_categoria'].toString()),
            ))
        .map((c) => c['nombre'].toString())
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalSeleccionMultiplesCategorias(
        categoriasDisponibles: nombresDisponibles,
        categoriasSeleccionadasIniciales: nombresIniciales,
        onCategoriasGuardadas: (nombresNuevos) {
          final idsNuevos = <int>[];
          for (final nombre in nombresNuevos) {
            for (final categoria in widget.categoriasDisponibles) {
              if (categoria is Map && categoria['nombre'] == nombre) {
                final id = int.tryParse(categoria['id_categoria'].toString());
                if (id != null) idsNuevos.add(id);
                break;
              }
            }
          }
          setState(() => _idsCategoriasSeleccionadas = idsNuevos);
        },
      ),
    );
  }

  void _validarYEditar() {
    if (_nombreController.text.trim().isEmpty ||
        _maquinaController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty ||
        _pasosController.text.trim().isEmpty ||
        _beneficiosController.text.trim().isEmpty ||
        _rangoMovimientoController.text.trim().isEmpty ||
        _respiracionController.text.trim().isEmpty ||
        _ritmoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos de texto.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_idsCategoriasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una categoría'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final textos = <String, String>{
      'nombre': _nombreController.text.trim(),
      'maquina': _maquinaController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'instrucciones': _pasosController.text.trim(),
      'beneficios': _beneficiosController.text.trim(),
      'rango_movimiento': _rangoMovimientoController.text.trim(),
      'respiracion': _respiracionController.text.trim(),
      'ritmo_movimiento': _ritmoController.text.trim(),
    };

    final idEjercicio = int.tryParse(
      widget.ejercicioAEditar['id_ejercicio'].toString(),
    );

    if (idEjercicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró un ID válido para el ejercicio.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    widget.onEditar(
      idEjercicio,
      _idsCategoriasSeleccionadas,
      _imagenFile,
      _gifFile,
      textos,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textoCategoriasSeleccionadas = widget.categoriasDisponibles
        .where((c) =>
            c is Map &&
            _idsCategoriasSeleccionadas.contains(
              int.tryParse(c['id_categoria'].toString()),
            ))
        .map((c) => c['nombre'].toString())
        .join(', ');

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
            'EDITAR EJERCICIO',
            style: EstiloTexto.tituloBienvenida.copyWith(
              fontSize: 20,
              color: AppColors.verdePrimario,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView(
              children: [
                AdminTextField(label: 'Nombre del Ejercicio', controller: _nombreController),
                const SizedBox(height: 12),
                AdminTextField(label: 'Máquina o Equipo', controller: _maquinaController),
                const SizedBox(height: 12),
                Text(
                  'ARCHIVOS MULTIMEDIA (Opcionales si no deseas cambiarlos)',
                  style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                    color: AppColors.verdePrimario,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _seleccionarImagen,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.grisOscuro,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _imagenFile != null
                                  ? AppColors.verdePrimario
                                  : AppColors.verdePrimario.withOpacity(0.4),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _imagenFile != null ? Icons.check_circle : Icons.add_a_photo_outlined,
                                color: AppColors.verdePrimario,
                                size: 22,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _imagenFile != null ? 'Nueva Foto OK' : 'Cambiar Foto',
                                style: const TextStyle(
                                  color: AppColors.blancoPuro,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _seleccionarGif,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.grisOscuro,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _gifFile != null
                                  ? AppColors.verdePrimario
                                  : AppColors.verdePrimario.withOpacity(0.4),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _gifFile != null ? Icons.check_circle : Icons.video_library_outlined,
                                color: AppColors.verdePrimario,
                                size: 22,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _gifFile != null ? 'Nuevo archivo OK' : 'Cambiar GIF / Video',
                                style: const TextStyle(
                                  color: AppColors.blancoPuro,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _abrirModalSeleccionCategorias,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.grisOscuro,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Categorías del ejercicio (Máx. 3)', style: EstiloTexto.hintTexto),
                              const SizedBox(height: 4),
                              Text(
                                textoCategoriasSeleccionadas.isEmpty
                                    ? 'Seleccionar categorías...'
                                    : textoCategoriasSeleccionadas,
                                style: EstiloTexto.textoNormalRoboto.copyWith(
                                  color: textoCategoriasSeleccionadas.isEmpty
                                      ? AppColors.grisMedio
                                      : AppColors.blancoPuro,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: AppColors.verdePrimario, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AdminTextField(label: 'Descripción general...', maxLines: 3, controller: _descripcionController),
                const SizedBox(height: 12),
                AdminTextField(label: '¿Cómo se hace? (Pasos numerados)...', maxLines: 4, controller: _pasosController),
                const SizedBox(height: 12),
                AdminTextField(label: 'Beneficios...', maxLines: 3, controller: _beneficiosController),
                const SizedBox(height: 12),
                AdminTextField(label: 'Rango de movimiento ideal...', maxLines: 2, controller: _rangoMovimientoController),
                const SizedBox(height: 12),
                AdminTextField(label: 'El papel de la respiración...', maxLines: 2, controller: _respiracionController),
                const SizedBox(height: 12),
                AdminTextField(label: 'Ritmo del movimiento...', maxLines: 2, controller: _ritmoController),
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
                  onPressed: _validarYEditar,
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
