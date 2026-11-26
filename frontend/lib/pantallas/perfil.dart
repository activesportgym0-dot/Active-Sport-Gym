
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontend/models/perfil_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/perfil_cache.dart';
import 'package:frontend/services/perfil_service.dart';
import 'package:frontend/services/usuario_service.dart';
import 'package:frontend/services/colombia_service.dart';

import 'package:frontend/registro-recuperar/Login.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // ESTADO
  bool _isEditing = false;
  bool _isLoading = true;
  bool _guardando = false;

  final ImagePicker _picker = ImagePicker();

  // CONTROLADORES
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

  final TextEditingController _departamentoController =
      TextEditingController();

  final TextEditingController _municipioController =
      TextEditingController();

  final TextEditingController _direccionController =
      TextEditingController();

  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();

  // DATOS DEL PERFIL
  String _rol = 'cliente';
  String? _fotoPerfil;

  // DEPARTAMENTOS Y MUNICIPIOS
  List<Map<String, dynamic>> _departamentos = [];
  List<Map<String, dynamic>> _municipios = [];

  int? _departamentoSeleccionadoId;
  String? _municipioSeleccionado;

  bool _cargandoDepartamentos = false;
  bool _cargandoMunicipios = false;

  // --------------------------------------------------
  // INICIALIZACIÓN
  // --------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Mostrar inmediatamente los datos almacenados en caché.
    final guardado = PerfilCache.perfil;

    if (guardado != null) {
      _llenarCampos(guardado);
      _isLoading = false;
    }

    // Consultar los datos actualizados del servidor.
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _cedulaController.dispose();
    _departamentoController.dispose();
    _municipioController.dispose();
    _direccionController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // MENSAJES
  // --------------------------------------------------

  void _mostrarMensaje(String mensaje, {required bool exito}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  // --------------------------------------------------
  // LLENAR LOS CAMPOS DEL PERFIL
  // --------------------------------------------------

  void _llenarCampos(PerfilModel perfil) {
    _nombreController.text = perfil.nombre;
    _apellidoController.text = perfil.apellido;
    _correoController.text = perfil.correo;
    _telefonoController.text = perfil.telefono;
    _cedulaController.text = perfil.cedula;

    _departamentoController.text = perfil.departamento ?? '';
    _municipioController.text = perfil.municipio ?? '';
    _direccionController.text = perfil.direccion ?? '';

    _edadController.text = perfil.edad?.toString() ?? '';
    _pesoController.text = perfil.peso?.toString() ?? '';
    _alturaController.text = perfil.altura?.toString() ?? '';

    _rol = perfil.rol;
    _fotoPerfil = perfil.fotoPerfil;
  }

  // --------------------------------------------------
  // CARGAR PERFIL DESDE EL BACKEND
  // --------------------------------------------------

  Future<void> _cargarPerfil() async {
    final id = SessionService.idUsuario;

    if (id == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final yaHayDatosEnPantalla = !_isLoading;

    final resultado = await PerfilService.obtenerPerfil(id);

    if (!mounted) return;

    if (resultado['success'] == true) {
      final perfil = resultado['perfil'] as PerfilModel;

      PerfilCache.guardar(perfil);

      // No sobrescribir los datos si el usuario está editando.
      if (!_isEditing) {
        setState(() {
          _llenarCampos(perfil);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }

      // Cargar los desplegables con la ubicación guardada.
      await _cargarDepartamentosYUbicacion();
    } else {
      setState(() {
        _isLoading = false;
      });

      // Si había datos en caché, se conservan.
      if (!yaHayDatosEnPantalla) {
        _mostrarMensaje(
          'Error al cargar el perfil: ${resultado['message']}',
          exito: false,
        );
      }

      // Intentar cargar los departamentos igualmente.
      await _cargarDepartamentosYUbicacion();
    }
  }

  // --------------------------------------------------
  // CARGAR DEPARTAMENTOS
  // --------------------------------------------------

  Future<void> _cargarDepartamentosYUbicacion() async {
    final departamentoGuardado =
        _departamentoController.text.trim();

    final municipioGuardado =
        _municipioController.text.trim();

    if (mounted) {
      setState(() {
        _cargandoDepartamentos = true;
      });
    }

    try {
      final resultado =
          await ColombiaService.obtenerDepartamentos();

      final lista = List<Map<String, dynamic>>.from(
        resultado.map(
          (e) => Map<String, dynamic>.from(e),
        ),
      );

      if (!mounted) return;

      setState(() {
        _departamentos = lista;
        _cargandoDepartamentos = false;
      });

      if (departamentoGuardado.isEmpty) return;

      // Buscar el departamento guardado.
      final departamento = _departamentos.firstWhere(
        (d) =>
            d['name'].toString().toLowerCase() ==
            departamentoGuardado.toLowerCase(),
        orElse: () => {},
      );

      if (departamento.isEmpty) return;

      final idDepartamento = int.tryParse(
        departamento['id'].toString(),
      );

      if (idDepartamento == null) return;

      setState(() {
        _departamentoSeleccionadoId = idDepartamento;

        _departamentoController.text =
            departamento['name'].toString();
      });

      // Cargar los municipios del departamento.
      await _cargarMunicipios(
        idDepartamento,
        municipioGuardado: municipioGuardado,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoDepartamentos = false;
      });

      _mostrarMensaje(
        'No se pudieron cargar los departamentos.',
        exito: false,
      );
    }
  }

  // --------------------------------------------------
  // CARGAR MUNICIPIOS SEGÚN EL DEPARTAMENTO
  // --------------------------------------------------

  Future<void> _cargarMunicipios(
    int idDepartamento, {
    String? municipioGuardado,
  }) async {
    setState(() {
      _cargandoMunicipios = true;
      _municipios = [];
    });

    try {
      final resultado =
          await ColombiaService.obtenerMunicipios(idDepartamento);

      final lista = List<Map<String, dynamic>>.from(
        resultado.map(
          (e) => Map<String, dynamic>.from(e),
        ),
      );

      if (!mounted) return;

      setState(() {
        _municipios = lista;
        _cargandoMunicipios = false;
      });

      // Recuperar el municipio que ya estaba guardado.
      if (municipioGuardado != null &&
          municipioGuardado.isNotEmpty) {
        final municipio = _municipios.firstWhere(
          (m) =>
              m['name'].toString().toLowerCase() ==
              municipioGuardado.toLowerCase(),
          orElse: () => {},
        );

        if (municipio.isNotEmpty) {
          setState(() {
            _municipioSeleccionado =
                municipio['name'].toString();

            _municipioController.text =
                municipio['name'].toString();
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoMunicipios = false;
      });

      _mostrarMensaje(
        'No se pudieron cargar los municipios.',
        exito: false,
      );
    }
  }

  // --------------------------------------------------
  // CAMBIAR DEPARTAMENTO
  // --------------------------------------------------

  Future<void> _cambiarDepartamento(int? id) async {
    if (id == null) return;

    final departamento = _departamentos.firstWhere(
      (d) => int.tryParse(d['id'].toString()) == id,
    );

    setState(() {
      _departamentoSeleccionadoId = id;

      _departamentoController.text =
          departamento['name'].toString();

      // Limpiar el municipio anterior.
      _municipioSeleccionado = null;
      _municipioController.clear();
      _municipios = [];
    });

    await _cargarMunicipios(id);
  }

  // --------------------------------------------------
  // DESPLEGABLE DE DEPARTAMENTOS
  // --------------------------------------------------

  Widget _buildDepartamentoDropdown() {
    if (!_isEditing) {
      return _buildCampoEditable(
        Icons.apartment_outlined,
        'Departamento',
        _departamentoController,
        editable: false,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.grisMedio.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.apartment_outlined,
            color: AppColors.verdePrimario,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _departamentos.any(
                (d) =>
                    int.tryParse(d['id'].toString()) ==
                    _departamentoSeleccionadoId,
              )
                  ? _departamentoSeleccionadoId
                  : null,
              dropdownColor: AppColors.grisOscuro,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Departamento',
                labelStyle: TextStyle(
                  color: AppColors.verdePrimario,
                  fontSize: 12,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              hint: const Text(
                'Selecciona un departamento',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              items: _departamentos.map((departamento) {
                return DropdownMenuItem<int>(
                  value: int.parse(
                    departamento['id'].toString(),
                  ),
                  child: Text(
                    departamento['name'].toString(),
                  ),
                );
              }).toList(),
              onChanged: _cargandoDepartamentos ||
                      _guardando
                  ? null
                  : _cambiarDepartamento,
            ),
          ),
          if (_cargandoDepartamentos)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.verdePrimario,
              ),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DESPLEGABLE DE MUNICIPIOS
  // --------------------------------------------------

  Widget _buildMunicipioDropdown() {
    if (!_isEditing) {
      return _buildCampoEditable(
        Icons.location_city_outlined,
        'Municipio',
        _municipioController,
        editable: false,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.grisMedio.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_city_outlined,
            color: AppColors.verdePrimario,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _municipios.any(
                (m) =>
                    m['name'].toString() ==
                    _municipioSeleccionado,
              )
                  ? _municipioSeleccionado
                  : null,
              dropdownColor: AppColors.grisOscuro,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Municipio',
                labelStyle: TextStyle(
                  color: AppColors.verdePrimario,
                  fontSize: 12,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              hint: Text(
                _departamentoSeleccionadoId == null
                    ? 'Primero selecciona un departamento'
                    : 'Selecciona un municipio',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              items: _municipios.map((municipio) {
                return DropdownMenuItem<String>(
                  value: municipio['name'].toString(),
                  child: Text(
                    municipio['name'].toString(),
                  ),
                );
              }).toList(),
              onChanged: _cargandoMunicipios ||
                      _departamentoSeleccionadoId == null ||
                      _guardando
                  ? null
                  : (valor) {
                      setState(() {
                        _municipioSeleccionado = valor;
                        _municipioController.text =
                            valor ?? '';
                      });
                    },
            ),
          ),
          if (_cargandoMunicipios)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.verdePrimario,
              ),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ACTUALIZAR CACHÉ
  // --------------------------------------------------

  Future<void> _actualizarCache(int id) async {
    try {
      final resultado =
          await PerfilService.obtenerPerfil(id);

      if (resultado['success'] == true) {
        PerfilCache.guardar(
          resultado['perfil'] as PerfilModel,
        );
      }
    } catch (_) {
      // Se actualizará cuando vuelva a consultar el perfil.
    }
  }

  // --------------------------------------------------
  // GUARDAR CAMBIOS DEL PERFIL
  // --------------------------------------------------

  Future<void> _guardarCambios() async {
    if (_guardando) return;

    final id = SessionService.idUsuario;

    if (id == null) {
      _mostrarMensaje(
        'No hay una sesión activa. Inicia sesión de nuevo.',
        exito: false,
      );
      return;
    }

    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final direccion = _direccionController.text.trim();

    // VALIDAR NOMBRE Y APELLIDO
    if (nombre.isEmpty || apellido.isEmpty) {
      _mostrarMensaje(
        'Nombre y apellido son obligatorios.',
        exito: false,
      );
      return;
    }

    // VALIDAR DEPARTAMENTO
    if (_departamentoSeleccionadoId == null ||
        _departamentoController.text.trim().isEmpty) {
      _mostrarMensaje(
        'Selecciona un departamento.',
        exito: false,
      );
      return;
    }

    // VALIDAR MUNICIPIO
    if (_municipioSeleccionado == null ||
        _municipioSeleccionado!.isEmpty) {
      _mostrarMensaje(
        'Selecciona un municipio.',
        exito: false,
      );
      return;
    }

    // VALIDAR DIRECCIÓN
    if (direccion.isEmpty) {
      _mostrarMensaje(
        'La dirección es obligatoria.',
        exito: false,
      );
      return;
    }

    if (direccion.length > 150) {
      _mostrarMensaje(
        'La dirección no puede superar 150 caracteres.',
        exito: false,
      );
      return;
    }

    // CAMPOS QUE SE ACTUALIZAN EN LA TABLA USUARIOS
    final campos = <String, dynamic>{
      'nombre': nombre,
      'apellido': apellido,
      'departamento': _departamentoController.text.trim(),
      'municipio': _municipioSeleccionado,
      'direccion': direccion,
    };

    // VALIDAR EDAD
    if (_edadController.text.trim().isNotEmpty) {
      final edad = int.tryParse(
        _edadController.text.trim(),
      );

      if (edad == null || edad < 1 || edad > 120) {
        _mostrarMensaje(
          'La edad debe ser un número entre 1 y 120.',
          exito: false,
        );
        return;
      }

      campos['edad'] = edad;
    }

    // VALIDAR PESO
    if (_pesoController.text.trim().isNotEmpty) {
      final peso = double.tryParse(
        _pesoController.text.trim().replaceAll(',', '.'),
      );

      if (peso == null || !peso.isFinite ||
          peso <= 0 || peso > 500) {
        _mostrarMensaje(
          'El peso debe ser un número válido.',
          exito: false,
        );
        return;
      }

      campos['peso'] = peso;
    }

    // VALIDAR ALTURA
    if (_alturaController.text.trim().isNotEmpty) {
      final altura = double.tryParse(
        _alturaController.text.trim().replaceAll(',', '.'),
      );

      if (altura == null || !altura.isFinite ||
          altura <= 0 || altura > 3) {
        _mostrarMensaje(
          'La altura debe ser un número válido en metros.',
          exito: false,
        );
        return;
      }

      campos['altura'] = altura;
    }

    // GUARDAR EN EL BACKEND
    setState(() {
      _guardando = true;
    });

    final resultado =
        await PerfilService.editarPerfil(id, campos);

    if (!mounted) return;

    setState(() {
      _guardando = false;
    });

    if (resultado['success'] == true) {
      SessionService.nombreUsuario = nombre;

      setState(() {
        _isEditing = false;
      });

      _mostrarMensaje(
        resultado['message'].toString(),
        exito: true,
      );

      await _actualizarCache(id);
    } else {
      _mostrarMensaje(
        resultado['message'].toString(),
        exito: false,
      );
    }
  }

  // --------------------------------------------------
  // CAMBIAR FOTO DE PERFIL
  // --------------------------------------------------

  Future<void> _cambiarFoto() async {
    if (_guardando) return;

    final id = SessionService.idUsuario;

    if (id == null) {
      _mostrarMensaje(
        'No hay una sesión activa. Inicia sesión de nuevo.',
        exito: false,
      );
      return;
    }

    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (foto == null || !mounted) return;

      setState(() {
        _guardando = true;
      });

      final resultado =
          await PerfilService.cambiarFoto(id, foto);

      if (!mounted) return;

      setState(() {
        _guardando = false;

        if (resultado['success'] == true &&
            resultado['foto_perfil'] != null) {
          _fotoPerfil =
              resultado['foto_perfil'].toString();
        }
      });

      _mostrarMensaje(
        resultado['message'].toString(),
        exito: resultado['success'] == true,
      );

      if (resultado['success'] == true) {
        await _actualizarCache(id);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      _mostrarMensaje(
        'No se pudo seleccionar la imagen: $e',
        exito: false,
      );
    }
  }

  // --------------------------------------------------
  // ELIMINAR MI CUENTA
  // --------------------------------------------------

  Future<void> _confirmarEliminarCuenta() async {
    final contrasenaController = TextEditingController();

    bool verContrasena = false;
    bool eliminando = false;
    String? errorDialogo;

    final eliminada = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogo) => AlertDialog(
          backgroundColor: AppColors.grisOscuro,
          title: const Text(
            'Eliminar mi cuenta',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Oswald',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Se borrarán tu cuenta y tus datos '
                  '(perfil, rutinas, progreso y más). '
                  'Esta acción no se puede deshacer.\n\n'
                  'Para confirmar, escribe tu contraseña.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: contrasenaController,
                  obscureText: !verContrasena,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(
                      color: AppColors.verdePrimario,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.verdePrimario,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        verContrasena
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        setDialogo(() {
                          verContrasena = !verContrasena;
                        });
                      },
                    ),
                  ),
                ),
                if (errorDialogo != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorDialogo!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: eliminando
                  ? null
                  : () {
                      Navigator.pop(dialogContext, false);
                    },
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: eliminando
                  ? null
                  : () async {
                      final contrasena =
                          contrasenaController.text;

                      if (contrasena.isEmpty) {
                        setDialogo(() {
                          errorDialogo =
                              'Escribe tu contraseña para confirmar.';
                        });
                        return;
                      }

                      setDialogo(() {
                        eliminando = true;
                        errorDialogo = null;
                      });

                      final resultado =
                          await UsuarioService.eliminarMiCuenta(
                        contrasena,
                      );

                      if (resultado['success'] == true) {
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } else {
                        setDialogo(() {
                          eliminando = false;
                          errorDialogo =
                              resultado['message'].toString();
                        });
                      }
                    },
              child: Text(
                eliminando ? 'ELIMINANDO...' : 'ELIMINAR',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    contrasenaController.dispose();

    if (eliminada != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tu cuenta fue eliminada correctamente',
        ),
        backgroundColor: Colors.green,
      ),
    );

    PerfilCache.limpiar();
    SessionService.limpiarSesion();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // --------------------------------------------------
  // CAMPO EDITABLE GENERAL
  // --------------------------------------------------

  Widget _buildCampoEditable(
    IconData icon,
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool editable = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.grisMedio.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.verdePrimario,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: EstiloTexto.textoNormalRoboto.copyWith(
                    fontSize: 10,
                    color: AppColors.grisClaro,
                  ),
                ),
                const SizedBox(height: 2),
                _isEditing && editable
                    ? TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        style: EstiloTexto.enlaceNegritaRoboto
                            .copyWith(fontSize: 13),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        controller.text.isEmpty
                            ? '—'
                            : controller.text,
                        style: EstiloTexto.enlaceNegritaRoboto
                            .copyWith(fontSize: 13),
                      ),
              ],
            ),
          ),
          if (_isEditing && !editable)
            const Icon(
              Icons.lock_outline,
              color: AppColors.grisMedio,
              size: 16,
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // CONSTRUIR PANTALLA
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoNegro,

      // APP BAR
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.verdePrimario,
            size: 20,
          ),
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
            icon: Icon(
              _isEditing
                  ? Icons.check
                  : Icons.edit_outlined,
              color: AppColors.verdePrimario,
            ),
            tooltip: _isEditing
                ? 'Guardar cambios'
                : 'Editar perfil',
            onPressed: _guardando || _isLoading
                ? null
                : () {
                    if (_isEditing) {
                      _guardarCambios();
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
          ),
        ],
      ),

      // CUERPO
      body: FondoApp(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // INDICADOR DE CARGA
              if (_isLoading || _guardando)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    color: AppColors.verdePrimario,
                    backgroundColor: AppColors.grisOscuro,
                  ),
                ),

              // FOTO DE PERFIL
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.verdePrimario,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.grisOscuro,
                        backgroundImage:
                            _fotoPerfil != null &&
                                    _fotoPerfil!.isNotEmpty
                                ? NetworkImage(_fotoPerfil!)
                                : null,
                        child: _fotoPerfil == null ||
                                _fotoPerfil!.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 55,
                                color: AppColors.grisClaro,
                              )
                            : null,
                      ),
                    ),

                    // BOTÓN CAMBIAR FOTO
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
                            icon: const Icon(
                              Icons.camera_alt,
                              color: AppColors.fondoNegro,
                              size: 15,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed:
                                _guardando ? null : _cambiarFoto,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // NOMBRE COMPLETO
              Center(
                child: Text(
                  '${_nombreController.text} ${_apellidoController.text}'
                      .trim(),
                  style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // ROL
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
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

              // INFORMACIÓN GENERAL
              Text(
                'INFORMACIÓN GENERAL',
                style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                  fontSize: 13,
                  color: AppColors.verdePrimario,
                ),
              ),

              const SizedBox(height: 10),

              // NOMBRE
              _buildCampoEditable(
                Icons.person_outline,
                'Nombre',
                _nombreController,
              ),

              const SizedBox(height: 8),

              // APELLIDO
              _buildCampoEditable(
                Icons.person_outline,
                'Apellido',
                _apellidoController,
              ),

              const SizedBox(height: 8),

              // CORREO BLOQUEADO
              _buildCampoEditable(
                Icons.email_outlined,
                'Correo electrónico',
                _correoController,
                editable: false,
              ),

              const SizedBox(height: 8),

              // TELÉFONO BLOQUEADO
              _buildCampoEditable(
                Icons.phone_outlined,
                'Teléfono',
                _telefonoController,
                keyboardType: TextInputType.phone,
                editable: false,
              ),

              const SizedBox(height: 8),

              // CÉDULA BLOQUEADA
              _buildCampoEditable(
                Icons.badge_outlined,
                'Cédula',
                _cedulaController,
                keyboardType: TextInputType.number,
                editable: false,
              ),

              const SizedBox(height: 8),

              // DEPARTAMENTO DESPLEGABLE
              _buildDepartamentoDropdown(),

              const SizedBox(height: 8),

              // MUNICIPIO DESPLEGABLE
              _buildMunicipioDropdown(),

              const SizedBox(height: 8),

              // DIRECCIÓN
              _buildCampoEditable(
                Icons.home_outlined,
                'Dirección (barrio o vereda)',
                _direccionController,
              ),

              const SizedBox(height: 12),

              // EDAD, PESO Y ALTURA
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildCampoEditable(
                      Icons.cake_outlined,
                      'Edad',
                      _edadController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCampoEditable(
                      Icons.monitor_weight_outlined,
                      'Peso (kg)',
                      _pesoController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCampoEditable(
                      Icons.height_outlined,
                      'Altura (m)',
                      _alturaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // BOTÓN GUARDAR
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrimario,
                      foregroundColor: AppColors.fondoNegro,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:
                        _guardando ? null : _guardarCambios,
                    child: Text(
                      'GUARDAR CAMBIOS',
                      style: EstiloTexto.botonPrincipal.copyWith(
                        color: AppColors.fondoNegro,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              // ELIMINAR CUENTA
              if (!_isEditing &&
                  !SessionService.esAdminPrincipal) ...[
                const SizedBox(height: 24),

                const Divider(
                  color: AppColors.grisMedio,
                  thickness: 0.5,
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.redAccent,
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _guardando
                        ? null
                        : _confirmarEliminarCuenta,
                    icon: const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    label: const Text(
                      'ELIMINAR MI CUENTA',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
