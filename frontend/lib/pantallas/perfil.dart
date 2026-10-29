import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/models/perfil_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/perfil_service.dart';
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}
class _PerfilScreenState extends State<PerfilScreen> {
  // Datos reales basados exactamente en tu base de datos de Supabase
  bool _isEditing = false;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
 
  // Estos datos llegan del backend (GET /perfil/:id_usuario)
  String _rol = 'cliente';
  String? _fotoPerfil; // Viene de la tabla perfil (NULL por defecto)
  bool _isLoading = true;
  bool _guardando = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _cedulaController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String mensaje, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _cargarPerfil() async {
    final id = SessionService.idUsuario;
    if (id == null) {
      _isLoading = false;
      return;
    }

    final resultado = await PerfilService.obtenerPerfil(id);
    if (!mounted) return;

    if (resultado['success'] == true) {
      final perfil = resultado['perfil'] as PerfilModel;
      setState(() {
        _nombreController.text = perfil.nombre;
        _apellidoController.text = perfil.apellido;
        _correoController.text = perfil.correo;
        _telefonoController.text = perfil.telefono;
        _cedulaController.text = perfil.cedula;
        _edadController.text = perfil.edad?.toString() ?? '';
        _pesoController.text = perfil.peso?.toString() ?? '';
        _alturaController.text = perfil.altura?.toString() ?? '';
        _rol = perfil.rol;
        _fotoPerfil = perfil.fotoPerfil;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _mostrarMensaje('Error al cargar el perfil: ${resultado['message']}', exito: false);
    }
  }

  // Guarda los datos de texto (PUT /perfil/:id_usuario)
  Future<void> _guardarCambios() async {
    final id = SessionService.idUsuario;
    if (id == null) {
      _mostrarMensaje('No hay una sesión activa. Inicia sesión de nuevo.', exito: false);
      return;
    }

    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final correo = _correoController.text.trim();
    if (nombre.isEmpty || apellido.isEmpty || correo.isEmpty) {
      _mostrarMensaje('Nombre, apellido y correo son obligatorios.', exito: false);
      return;
    }

    final campos = <String, dynamic>{
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
    };
    if (_telefonoController.text.trim().isNotEmpty) {
      campos['telefono'] = _telefonoController.text.trim();
    }
    if (_cedulaController.text.trim().isNotEmpty) {
      campos['cedula'] = _cedulaController.text.trim();
    }

    if (_edadController.text.trim().isNotEmpty) {
      final edad = int.tryParse(_edadController.text.trim());
      if (edad == null) {
        _mostrarMensaje('La edad debe ser un número entero.', exito: false);
        return;
      }
      campos['edad'] = edad;
    }
    if (_pesoController.text.trim().isNotEmpty) {
      final peso = double.tryParse(_pesoController.text.trim().replaceAll(',', '.'));
      if (peso == null) {
        _mostrarMensaje('El peso debe ser un número (ej. 60.5).', exito: false);
        return;
      }
      campos['peso'] = peso;
    }
    if (_alturaController.text.trim().isNotEmpty) {
      final altura = double.tryParse(_alturaController.text.trim().replaceAll(',', '.'));
      if (altura == null) {
        _mostrarMensaje('La altura debe ser un número (ej. 1.65).', exito: false);
        return;
      }
      campos['altura'] = altura;
    }

    setState(() => _guardando = true);
    final resultado = await PerfilService.editarPerfil(id, campos);
    if (!mounted) return;
    setState(() => _guardando = false);

    if (resultado['success'] == true) {
      SessionService.nombreUsuario = nombre; // mantiene el nombre de la sesión al día
      setState(() => _isEditing = false);
      _mostrarMensaje(resultado['message'].toString(), exito: true);
    } else {
      // Se queda en modo edición para que pueda corregir el dato
      _mostrarMensaje(resultado['message'].toString(), exito: false);
    }
  }

  // Sube la foto a Cloudinary mediante el backend (PUT /perfil/foto/:id_usuario)
  Future<void> _cambiarFoto() async {
    final id = SessionService.idUsuario;
    if (id == null) {
      _mostrarMensaje('No hay una sesión activa. Inicia sesión de nuevo.', exito: false);
      return;
    }

    try {
      final XFile? foto = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (foto == null || !mounted) return;

      setState(() => _guardando = true);
      final resultado = await PerfilService.cambiarFoto(id, foto);
      if (!mounted) return;

      setState(() {
        _guardando = false;
        if (resultado['success'] == true && resultado['foto_perfil'] != null) {
          _fotoPerfil = resultado['foto_perfil'].toString();
        }
      });
      _mostrarMensaje(
        resultado['message'].toString(),
        exito: resultado['success'] == true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _mostrarMensaje('No se pudo seleccionar la imagen: $e', exito: false);
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
          'MI PERFIL',
          style: EstiloTexto.bienvenida.copyWith(
            fontFamily: 'Oswald',
            fontSize: 16,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined, color: AppColors.verdePrimario),
            onPressed: _guardando
                ? null
                : () {
                    if (_isEditing) {
                      _guardarCambios();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
          ),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_isLoading || _guardando)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    color: AppColors.verdePrimario,
                    backgroundColor: AppColors.grisOscuro,
                  ),
                ),
              // Foto de Perfil (Avatar predeterminado o Cloudinary)
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.verdePrimario, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.grisOscuro,
                        backgroundImage: _fotoPerfil != null ? NetworkImage(_fotoPerfil!) : null,
                        child: _fotoPerfil == null
                            ? const Icon(Icons.person, size: 55, color: AppColors.grisClaro)
                            : null,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.verdePrimario,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: AppColors.fondoNegro, size: 15),
                            onPressed: _guardando ? null : _cambiarFoto,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '${_nombreController.text} ${_apellidoController.text}',
                  style: EstiloTexto.enlaceNegritaRoboto.copyWith(fontSize: 18),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.verdePrimario.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _rol.toUpperCase(),
                    style: EstiloTexto.textoNormalRoboto.copyWith(
                      color: AppColors.verdePrimario,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Información Personal y Datos Reales de la BD
              Text(
                'INFORMACIÓN GENERAL',
                style: EstiloTexto.enlaceNegritaRoboto.copyWith(fontSize: 13, color: AppColors.verdePrimario),
              ),
              const SizedBox(height: 10),
              _buildCampoEditable(Icons.person_outline, 'Nombre', _nombreController),
              const SizedBox(height: 8),
              _buildCampoEditable(Icons.person_outline, 'Apellido', _apellidoController),
              const SizedBox(height: 8),
              _buildCampoEditable(Icons.email_outlined, 'Correo electrónico', _correoController),
              const SizedBox(height: 8),
              _buildCampoEditable(Icons.phone_outlined, 'Teléfono', _telefonoController, keyboardType: TextInputType.phone),
              const SizedBox(height: 8),
              _buildCampoEditable(Icons.badge_outlined, 'Cédula', _cedulaController, keyboardType: TextInputType.number),
             
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildCampoEditable(Icons.cake_outlined, 'Edad', _edadController, keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildCampoEditable(Icons.monitor_weight_outlined, 'Peso (kg)', _pesoController, keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildCampoEditable(Icons.height_outlined, 'Altura (m)', _alturaController, keyboardType: TextInputType.number)),
                ],
              ),
             
              const SizedBox(height: 30),
             
              // Botón inferior si está editando
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrimario,
                      foregroundColor: AppColors.fondoNegro,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _guardando ? null : _guardarCambios,
                    child: Text('GUARDAR CAMBIOS', style: EstiloTexto.botonPrincipal.copyWith(color: AppColors.fondoNegro, fontSize: 14)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCampoEditable(IconData icon, String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.verdePrimario, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 10, color: AppColors.grisClaro)),
                const SizedBox(height: 2),
                _isEditing
                    ? TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        style: EstiloTexto.enlaceNegritaRoboto.copyWith(fontSize: 13),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(controller.text, style: EstiloTexto.enlaceNegritaRoboto.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
