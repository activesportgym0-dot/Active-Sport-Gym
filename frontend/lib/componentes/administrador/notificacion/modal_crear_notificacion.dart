import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/usuario_service.dart';

class ModalCrearNotificacion extends StatefulWidget {
  final Function(Map<String, dynamic> nuevaNoti) onCrear;
  const ModalCrearNotificacion({super.key, required this.onCrear});
  @override
  State<ModalCrearNotificacion> createState() => _ModalCrearNotificacionState();
}
class _ModalCrearNotificacionState extends State<ModalCrearNotificacion> {
  final tituloController = TextEditingController();
  final mensajeController = TextEditingController();
  final busquedaController = TextEditingController();
  String tipoSeleccionado = 'stock';
  bool enviarATodos = true;
  String? errorMensaje;

  // Destinatario: el administrador busca al cliente por nombre (no necesita saber su ID)
  List<UserModel> _clientes = [];
  bool _cargandoClientes = false;
  bool _clientesCargados = false;
  String? _errorClientes;
  UserModel? _clienteSeleccionado;

  // Imagen opcional de la notificación (el backend la sube a Cloudinary)
  XFile? _imagen;
  Uint8List? _vistaPrevia;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    tituloController.dispose();
    mensajeController.dispose();
    busquedaController.dispose();
    super.dispose();
  }

  // ───────────── Buscador de clientes ─────────────

  // Quita tildes y mayúsculas para que "perez" encuentre "Pérez"
  String _normalizar(String texto) {
    const conTilde = 'áàäâéèëêíìïîóòöôúùüûñÁÀÄÂÉÈËÊÍÌÏÎÓÒÖÔÚÙÜÛÑ';
    const sinTilde = 'aaaaeeeeiiiioooouuuunAAAAEEEEIIIIOOOOUUUUN';
    var resultado = texto;
    for (var i = 0; i < conTilde.length; i++) {
      resultado = resultado.replaceAll(conTilde[i], sinTilde[i]);
    }
    return resultado.toLowerCase().trim();
  }

  String _nombreCompleto(UserModel u) => '${u.nombre} ${u.apellido}'.trim();

  Future<void> _cargarClientes() async {
    setState(() {
      _cargandoClientes = true;
      _errorClientes = null;
    });

    final resultado = await UsuarioService.listarUsuarios();
    if (!mounted) return;

    if (resultado['success'] == true) {
      final todos = resultado['usuarios'] as List<UserModel>;
      // Solo clientes con la cuenta activa, ordenados por nombre
      final clientes = todos.where((u) => u.rol == 'cliente' && u.isActive && u.idUsuario != null).toList()
        ..sort((a, b) => _normalizar(_nombreCompleto(a)).compareTo(_normalizar(_nombreCompleto(b))));
      setState(() {
        _clientes = clientes;
        _clientesCargados = true;
        _cargandoClientes = false;
      });
    } else {
      setState(() {
        _errorClientes = (resultado['message'] ?? 'No se pudieron cargar los clientes').toString();
        _cargandoClientes = false;
      });
    }
  }

  // Coincide si TODAS las palabras escritas aparecen en el nombre, apellido, correo o cédula
  List<UserModel> get _resultados {
    final palabras = _normalizar(busquedaController.text).split(' ').where((p) => p.isNotEmpty).toList();
    if (palabras.isEmpty) return [];
    return _clientes.where((u) {
      final texto = _normalizar('${u.nombre} ${u.apellido} ${u.correo} ${u.cedula ?? ''}');
      return palabras.every(texto.contains);
    }).take(6).toList();
  }

  void _seleccionarCliente(UserModel cliente) {
    FocusScope.of(context).unfocus();
    setState(() {
      _clienteSeleccionado = cliente;
      busquedaController.clear();
      errorMensaje = null;
    });
  }

  Widget _buscadorDeCliente() {
    // Ya eligió a alguien: se muestra su tarjeta con una X para cambiarlo
    final elegido = _clienteSeleccionado;
    if (elegido != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.verdePrimario.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.verdePrimario),
        ),
        child: Row(
          children: [
            const Icon(Icons.person, color: AppColors.verdePrimario, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nombreCompleto(elegido),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: EstiloTexto.enlaceNegritaRoboto.copyWith(fontSize: 13),
                  ),
                  Text(
                    elegido.correo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11, color: AppColors.grisClaro),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Cambiar cliente',
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close, color: AppColors.verdePrimario, size: 20),
              onPressed: () => setState(() => _clienteSeleccionado = null),
            ),
          ],
        ),
      );
    }

    final resultados = _resultados;
    final hayTexto = busquedaController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: busquedaController,
          style: EstiloTexto.campoTexto,
          onChanged: (_) => setState(() => errorMensaje = null),
          decoration: InputDecoration(
            labelText: 'Buscar cliente por nombre',
            labelStyle: EstiloTexto.hintTexto,
            prefixIcon: const Icon(Icons.search, color: AppColors.verdePrimario),
            suffixIcon: hayTexto
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grisMedio, size: 18),
                    onPressed: () => setState(() => busquedaController.clear()),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.verdePrimario),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_cargandoClientes)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: AppColors.verdePrimario, strokeWidth: 2),
              ),
            ),
          )
        else if (_errorClientes != null)
          Row(
            children: [
              Expanded(
                child: Text(_errorClientes!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
              TextButton(
                onPressed: _cargarClientes,
                child: Text('REINTENTAR', style: EstiloTexto.enlaceNegritaRoboto.copyWith(fontSize: 11)),
              ),
            ],
          )
        else if (!hayTexto)
          Text(
            _clientesCargados
                ? 'Escribe el nombre o apellido del cliente (${_clientes.length} clientes activos).'
                : '',
            style: EstiloTexto.hintTexto.copyWith(fontSize: 11),
          )
        else if (resultados.isEmpty)
          Text('No se encontró ningún cliente con ese nombre.', style: EstiloTexto.hintTexto.copyWith(fontSize: 12))
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.grisOscuro,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grisMedio.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < resultados.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                  InkWell(
                    onTap: () => _seleccionarCliente(resultados[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.verdePrimario.withOpacity(0.2),
                            child: Text(
                              _nombreCompleto(resultados[i]).isEmpty
                                  ? '?'
                                  : _nombreCompleto(resultados[i])[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nombreCompleto(resultados[i]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: EstiloTexto.textoNormalRoboto.copyWith(color: Colors.white, fontSize: 13),
                                ),
                                Text(
                                  resultados[i].correo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11, color: AppColors.grisMedio),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // ───────────── Imagen ─────────────

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? archivo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (archivo == null) return;
      final bytes = await archivo.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imagen = archivo;
        _vistaPrevia = bytes;
        errorMensaje = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => errorMensaje = 'No se pudo seleccionar la imagen: $e');
    }
  }

  void _quitarImagen() {
    setState(() {
      _imagen = null;
      _vistaPrevia = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENVIAR NUEVA NOTIFICACIÓN',
            style: EstiloTexto.tituloBienvenida.copyWith(fontSize: 18, color: AppColors.verdePrimario),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView(
              children: [
                TextField(
                  controller: tituloController,
                  style: EstiloTexto.campoTexto,
                  decoration: InputDecoration(
                    labelText: 'Título de la notificación',
                    labelStyle: EstiloTexto.hintTexto,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.verdePrimario),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mensajeController,
                  maxLines: 3,
                  style: EstiloTexto.campoTexto,
                  decoration: InputDecoration(
                    labelText: 'Mensaje detallado',
                    labelStyle: EstiloTexto.hintTexto,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.verdePrimario),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  dropdownColor: AppColors.grisOscuro,
                  style: EstiloTexto.campoTexto,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Notificación',
                    labelStyle: EstiloTexto.hintTexto,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.verdePrimario),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'stock', child: Text('Stock')),
                    DropdownMenuItem(value: 'evento', child: Text('Evento')),
                    DropdownMenuItem(value: 'membresia', child: Text('Membresía')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        tipoSeleccionado = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Enviar a todos los clientes', style: EstiloTexto.textoNormalRoboto),
                  value: enviarATodos,
                  activeColor: AppColors.verdePrimario,
                  onChanged: (val) {
                    setState(() {
                      enviarATodos = val;
                      errorMensaje = null;
                    });
                    // Al elegir "un cliente específico" se cargan los clientes (una sola vez)
                    if (!val && !_clientesCargados && !_cargandoClientes) _cargarClientes();
                  },
                ),
                if (!enviarATodos) ...[
                  const SizedBox(height: 8),
                  _buscadorDeCliente(),
                ],
                const SizedBox(height: 12),
                Text(
                  'IMAGEN (Opcional)',
                  style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                    color: AppColors.verdePrimario,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (_vistaPrevia == null)
                  InkWell(
                    onTap: _seleccionarImagen,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 90,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.grisMedio.withOpacity(0.5)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined, color: AppColors.verdePrimario, size: 26),
                          const SizedBox(height: 6),
                          Text('Agregar imagen', style: EstiloTexto.hintTexto),
                        ],
                      ),
                    ),
                  )
                else
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _vistaPrevia!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Row(
                          children: [
                            _botonImagen(Icons.edit, _seleccionarImagen),
                            const SizedBox(width: 6),
                            _botonImagen(Icons.close, _quitarImagen),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (errorMensaje != null) ...[
            Text(
              errorMensaje!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.verdePrimario),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCELAR', style: EstiloTexto.botonPrincipal.copyWith(fontSize: 14, color: AppColors.verdePrimario)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrimario,
                    foregroundColor: AppColors.fondoNegro,
                  ),
                  onPressed: () {
                    final titulo = tituloController.text.trim();
                    final mensaje = mensajeController.text.trim();

                    if (titulo.isEmpty || mensaje.isEmpty) {
                      setState(() => errorMensaje = 'El título y el mensaje son obligatorios.');
                      return;
                    }

                    int? idUsuario;
                    if (!enviarATodos) {
                      idUsuario = _clienteSeleccionado?.idUsuario;
                      if (idUsuario == null) {
                        setState(() => errorMensaje = 'Busca y selecciona un cliente de la lista.');
                        return;
                      }
                    }

                    // idUsuario null = notificación global para todos los clientes
                    widget.onCrear({
                      'titulo': titulo,
                      'mensaje': mensaje,
                      'tipo': tipoSeleccionado,
                      'id_usuario': idUsuario,
                      'imagen': _imagen, // XFile? (null = sin imagen)
                    });
                    Navigator.pop(context);
                  },
                  child: Text('ENVIAR', style: EstiloTexto.botonPrincipal.copyWith(fontSize: 14, color: AppColors.fondoNegro)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonImagen(IconData icono, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icono, color: AppColors.verdePrimario, size: 18),
      ),
    );
  }
}