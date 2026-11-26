
import 'package:flutter/material.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/core/colores.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'terminos_condiciones_screen.dart';
import 'verificar_cuenta_screen.dart';
import '../services/colombia_service.dart';

class RegistrarScreen extends StatefulWidget {
  const RegistrarScreen({super.key});

  @override
  State<RegistrarScreen> createState() => _RegistrarScreenState();
}

class _RegistrarScreenState extends State<RegistrarScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _aceptaTerminos = false;

  // Requisitos de contraseña en tiempo real.
  bool _tieneMinimo8 = false;
  bool _tieneMayuscula = false;
  bool _tieneNumero = false;
  bool _tieneSimbolo = false;

  // Datos de ubicación.
  List<Map<String, dynamic>> _departamentos = [];
  List<Map<String, dynamic>> _municipios = [];
  int? _departamentoSeleccionado;
  bool _cargandoDepartamentos = false;
  bool _cargandoMunicipios = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validarContrasenaEnTiempoReal);
    _cargarDepartamentos();
  }

  Future<void> _cargarDepartamentos() async {
    if (!mounted) return;

    setState(() => _cargandoDepartamentos = true);

    try {
      final datos = await ColombiaService.obtenerDepartamentos();

      if (!mounted) return;

      setState(() {
        _departamentos = datos;
        _cargandoDepartamentos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargandoDepartamentos = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudieron cargar los departamentos. Revisa tu conexión.',
          ),
        ),
      );
    }
  }

  Future<void> _cargarMunicipios(int departamentoId) async {
    setState(() {
      _municipios = [];
      _municipioController.clear();
      _cargandoMunicipios = true;
    });

    try {
      final datos =
          await ColombiaService.obtenerMunicipios(departamentoId);

      if (!mounted) return;

      setState(() {
        _municipios = datos;
        _cargandoMunicipios = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargandoMunicipios = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron cargar los municipios.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validarContrasenaEnTiempoReal);

    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _municipioController.dispose();
    _direccionController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _edadController.dispose();

    super.dispose();
  }

  void _validarContrasenaEnTiempoReal() {
    if (!mounted) return;

    final val = _passwordController.text;

    setState(() {
      _tieneMinimo8 = val.length >= 8;
      _tieneMayuscula = RegExp(r'(?=.*[A-Z])').hasMatch(val);
      _tieneNumero = RegExp(r'(?=.*[0-9])').hasMatch(val);
      _tieneSimbolo =
          RegExp(r'(?=.*[!@#\$%^&*(),.?":{}|<>])').hasMatch(val);
    });
  }

  // REGISTRO DE USUARIO.
  Future<void> _realizarRegistro() async {
    // Evita que se envíe el formulario más de una vez.
    if (_isLoading) return;

    // Cada campo muestra su propio mensaje de validación.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validación de aceptación de términos.
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes aceptar los términos y condiciones para registrarte.',
          ),
        ),
      );
      return;
    }

    final cedula = _cedulaController.text.trim();
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final correo = _correoController.text.trim();
    final telefono = _telefonoController.text.trim();
    final municipio = _municipioController.text.trim();
    final direccion = _direccionController.text.trim();

    final pesoStr = _pesoController.text.trim();
    final alturaStr = _alturaController.text.trim();
    final edadStr = _edadController.text.trim();

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // EDAD, PESO Y ALTURA SON OPCIONALES.
    // Si el usuario no escribe nada, se envía null.
    final int? edad =
        edadStr.isEmpty ? null : int.tryParse(edadStr);

    final double? peso = pesoStr.isEmpty
        ? null
        : double.tryParse(pesoStr.replaceAll(',', '.'));

    final double? altura = alturaStr.isEmpty
        ? null
        : double.tryParse(alturaStr.replaceAll(',', '.'));

    // Validaciones adicionales para evitar enviar valores incorrectos.
    if (edadStr.isNotEmpty &&
        (edad == null || edad < 1 || edad > 120)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La edad debe ser un número válido entre 1 y 120 años.',
          ),
        ),
      );
      return;
    }

    if (pesoStr.isNotEmpty &&
        (peso == null || !peso.isFinite || peso <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa un peso válido mayor que cero.',
          ),
        ),
      );
      return;
    }

    if (alturaStr.isNotEmpty &&
        (altura == null || !altura.isFinite || altura <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa una altura válida mayor que cero.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nuevoUsuario = UserModel(
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        telefono: telefono,
        municipio: municipio,
        direccion: direccion,
        cedula: cedula,
        edad: edad,
        peso: peso,
        altura: altura,
        password: password,
        confirmarContrasena: confirmPassword,
        rol: 'cliente',
      );

      final resultado = await AuthService.registrar(
        nuevoUsuario,
        aceptaTerminos: _aceptaTerminos,
      );

      if (!mounted) return;

      final exito = resultado['success'] == true;

      final mensaje = (resultado['message'] ??
              'No se pudo completar el registro. Inténtalo nuevamente.')
          .toString();

      final correoEnviado = resultado['correoEnviado'] != false;

      if (exito && correoEnviado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mensaje.isNotEmpty
                  ? mensaje
                  : '¡Registro recibido! Ingresa el código enviado a tu correo.',
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VerificarCuentaScreen(correoRegistrado: correo),
          ),
        );
      } else if (exito && !correoEnviado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mensaje.isNotEmpty
                  ? mensaje
                  : 'La cuenta se creó, pero no se pudo enviar el correo de verificación. Contacta al administrador.',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocurrió un problema al registrar la cuenta.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // IMAGEN DE FONDO.
          Positioned.fill(
            child: Image.asset(
              'assets/images/3.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // FILTRO OSCURO.
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // CONTENIDO PRINCIPAL.
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'REGISTRO',
                      style: EstiloTexto.tituloPrincipalPrimerPantalla,
                    ),

                    const SizedBox(height: 10),

                    // LOGO.
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // BIENVENIDA.
                    Text.rich(
                      TextSpan(
                        text: 'Bienvenido a ',
                        style: EstiloTexto.bienvenida.copyWith(
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                            text: 'Active Sport Gym',
                            style: EstiloTexto.bienvenida.copyWith(
                              color: AppColors.verdePrimario,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FORMULARIO.
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _cedulaController,
                              icon: Icons.card_membership,
                              hint: 'Documento De Identidad...',
                              keyboardType: TextInputType.number,
                              validator: _validarCedula,
                            ),

                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _nombreController,
                              icon: Icons.person_outline,
                              hint: 'Nombre...',
                              validator: _validarNombreApellido,
                            ),

                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _apellidoController,
                              icon: Icons.person_outline,
                              hint: 'Apellido...',
                              validator: _validarNombreApellido,
                            ),

                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _correoController,
                              icon: Icons.email_outlined,
                              hint: 'Correo Electrónico...',
                              keyboardType: TextInputType.emailAddress,
                              validator: _validarCorreo,
                            ),

                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _telefonoController,
                              icon: Icons.phone_outlined,
                              hint: 'Teléfono...',
                              keyboardType: TextInputType.phone,
                              validator: _validarTelefono,
                            ),

                            const SizedBox(height: 12),

                            // DEPARTAMENTO.
                            DropdownButtonFormField<int>(
                              value: _departamentoSeleccionado,
                              isExpanded: true,
                              dropdownColor: Colors.black,
                              style: EstiloTexto.campoTexto,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.map_outlined,
                                  color: Colors.white70,
                                ),
                                hintText: _cargandoDepartamentos
                                    ? 'Cargando departamentos...'
                                    : 'Selecciona tu departamento...',
                                hintStyle: EstiloTexto.hintTexto,
                                filled: true,
                                fillColor: Colors.black,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _departamentos.map((departamento) {
                                return DropdownMenuItem<int>(
                                  value:
                                      (departamento['id'] as num).toInt(),
                                  child: Text(
                                    departamento['name'].toString(),
                                  ),
                                );
                              }).toList(),
                              onChanged: _cargandoDepartamentos
                                  ? null
                                  : (valor) {
                                      if (valor == null) return;

                                      setState(() {
                                        _departamentoSeleccionado = valor;
                                        _municipios = [];
                                        _municipioController.clear();
                                      });

                                      _cargarMunicipios(valor);
                                    },
                              validator: (valor) {
                                if (valor == null) {
                                  return 'Selecciona tu departamento';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // MUNICIPIO.
                            DropdownButtonFormField<String>(
                              value: _municipioController.text.isEmpty
                                  ? null
                                  : _municipioController.text,
                              isExpanded: true,
                              dropdownColor: Colors.black,
                              style: EstiloTexto.campoTexto,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.location_city_outlined,
                                  color: Colors.white70,
                                ),
                                hintText: _cargandoMunicipios
                                    ? 'Cargando municipios...'
                                    : 'Selecciona tu municipio...',
                                hintStyle: EstiloTexto.hintTexto,
                                filled: true,
                                fillColor: Colors.black,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _municipios.map((municipio) {
                                return DropdownMenuItem<String>(
                                  value: municipio['name'].toString(),
                                  child: Text(
                                    municipio['name'].toString(),
                                  ),
                                );
                              }).toList(),
                              onChanged:
                                  _municipios.isEmpty || _cargandoMunicipios
                                      ? null
                                      : (valor) {
                                          setState(() {
                                            _municipioController.text =
                                                valor ?? '';
                                          });
                                        },
                              validator: (valor) {
                                if (valor == null || valor.isEmpty) {
                                  return 'Selecciona tu municipio';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _direccionController,
                              icon: Icons.home_outlined,
                              hint: 'Barrio, vereda o dirección...',
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Escribe tu barrio, vereda o dirección';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // PESO OPCIONAL.
                            _buildTextField(
                              controller: _pesoController,
                              icon: Icons.monitor_weight_outlined,
                              hint: 'Peso (kg) (opcional)...',
                              validator: (v) =>
                                  _validarNumeroOpcional(v, 'peso'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ALTURA OPCIONAL.
                            _buildTextField(
                              controller: _alturaController,
                              icon: Icons.height_outlined,
                              hint: 'Altura (cm) (opcional)...',
                              validator: (v) =>
                                  _validarNumeroOpcional(v, 'altura'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // EDAD OPCIONAL.
                            _buildTextField(
                              controller: _edadController,
                              icon: Icons.cake_outlined,
                              hint: 'Edad (opcional)...',
                              validator: _validarEdadOpcional,
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 12),

                            // CONTRASEÑA.
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: EstiloTexto.campoTexto,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white70,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                          !_obscurePassword;
                                    });
                                  },
                                ),
                                hintText: 'Contraseña...',
                                hintStyle: EstiloTexto.hintTexto,
                                filled: true,
                                fillColor: Colors.black,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Por favor ingresa una contraseña';
                                }

                                if (!_tieneMinimo8 ||
                                    !_tieneMayuscula ||
                                    !_tieneNumero ||
                                    !_tieneSimbolo) {
                                  return 'La contraseña no cumple con todos los requisitos';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 8),

                            // REQUISITOS DE CONTRASEÑA.
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRequisitoItem(
                                    'Mínimo 8 caracteres',
                                    _tieneMinimo8,
                                  ),
                                  _buildRequisitoItem(
                                    'Al menos una letra mayúscula',
                                    _tieneMayuscula,
                                  ),
                                  _buildRequisitoItem(
                                    'Al menos un número',
                                    _tieneNumero,
                                  ),
                                  _buildRequisitoItem(
                                    'Al menos un símbolo especial',
                                    _tieneSimbolo,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // CONFIRMAR CONTRASEÑA.
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: EstiloTexto.campoTexto,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white70,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                hintText: 'Confirmar contraseña...',
                                hintStyle: EstiloTexto.hintTexto,
                                filled: true,
                                fillColor: Colors.black,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Por favor confirma tu contraseña';
                                }

                                if (val != _passwordController.text) {
                                  return 'Las contraseñas no coinciden';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ACEPTACIÓN DE TÉRMINOS Y POLÍTICA DE DATOS.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _aceptaTerminos,
                            activeColor: AppColors.verdePrimario,
                            checkColor: Colors.black,
                            side: const BorderSide(
                              color: Colors.white54,
                              width: 1.5,
                            ),
                            onChanged: (valor) {
                              setState(() {
                                _aceptaTerminos = valor ?? false;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Acepto los ',
                                style: EstiloTexto.politicasRoboto,
                              ),

                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TerminosCondicionesScreen(
                                      tabInicial: 0,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Términos y condiciones',
                                  style:
                                      EstiloTexto.politicasRoboto.copyWith(
                                    color: AppColors.verdePrimario,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),

                              Text(
                                ' y autorizo el tratamiento de mis datos personales según la ',
                                style: EstiloTexto.politicasRoboto,
                              ),

                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TerminosCondicionesScreen(
                                      tabInicial: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Política de datos',
                                  style:
                                      EstiloTexto.politicasRoboto.copyWith(
                                    color: AppColors.verdePrimario,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),

                              Text(
                                '.',
                                style: EstiloTexto.politicasRoboto,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // BOTÓN REGISTRAR.
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _realizarRegistro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdePrimario,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                'REGISTRAR',
                                style:
                                    EstiloTexto.botonPrincipal.copyWith(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ENLACE PARA INICIAR SESIÓN.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes cuenta? ',
                              style: EstiloTexto.textoNormalRoboto,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'INICIA SESIÓN',
                                style: EstiloTexto.enlaceNegritaRoboto,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // VALIDAR DOCUMENTO.
  String? _validarCedula(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Ingresa tu número de documento';
    }

    if (!RegExp(r'^\d{5,15}$').hasMatch(texto)) {
      return 'El documento debe tener entre 5 y 15 números';
    }

    return null;
  }

  // VALIDAR CORREO.
  String? _validarCorreo(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$')
        .hasMatch(texto)) {
      return 'Escribe un correo válido, por ejemplo nombre@correo.com';
    }

    return null;
  }

  // VALIDAR TELÉFONO.
  String? _validarTelefono(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Ingresa tu número de teléfono';
    }

    final digitos = texto.replaceAll(RegExp(r'\D'), '');

    if (digitos.length < 7 || digitos.length > 15) {
      return 'El teléfono debe tener entre 7 y 15 dígitos';
    }

    return null;
  }

  // VALIDAR EDAD OPCIONAL.
  String? _validarEdadOpcional(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) return null;

    final numero = int.tryParse(texto);

    if (numero == null || numero < 1 || numero > 120) {
      return 'La edad debe ser un número entre 1 y 120';
    }

    return null;
  }

  // VALIDAR PESO Y ALTURA OPCIONALES.
  String? _validarNumeroOpcional(String? valor, String campo) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) return null;

    final numero = double.tryParse(texto.replaceAll(',', '.'));

    if (numero == null || !numero.isFinite || numero <= 0) {
      return 'Ingresa un valor válido para $campo, mayor que cero';
    }

    return null;
  }

  // VALIDAR NOMBRE Y APELLIDO.
  String? _validarNombreApellido(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Este campo es obligatorio';
    }

    // Permite letras, tildes, ñ, espacios, guiones y apóstrofes.
    final formatoValido = RegExp(
      r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]+([ '-][a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]+)*$",
    );

    if (!formatoValido.hasMatch(texto)) {
      return 'Usa solo letras, espacios o guiones';
    }

    return null;
  }

  // CONSTRUCTOR DE CAMPOS DEL FORMULARIO.
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: EstiloTexto.campoTexto,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.white70,
        ),
        hintText: hint,
        hintStyle: EstiloTexto.hintTexto,
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // INDICADORES DE REQUISITOS DE CONTRASEÑA.
  Widget _buildRequisitoItem(String texto, bool cumple) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            cumple
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: cumple
                ? AppColors.verdePrimario
                : Colors.grey,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: cumple
                  ? AppColors.verdePrimario
                  : Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
