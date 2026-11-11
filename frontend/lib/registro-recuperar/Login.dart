import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/pantallas/administrador/home_administrador.dart';
import 'package:frontend/pantallas/cliente/home.dart';
import 'package:frontend/registro-recuperar/recuperar.dart';
import 'package:frontend/registro-recuperar/registro.dart';
import 'package:frontend/registro-recuperar/terminos_condiciones_screen.dart';
import 'package:frontend/registro-recuperar/verificar_cuenta_screen.dart';
import '../services/auth_service.dart';
import '../services/sesion_guardada_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar correo y contraseña
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _restaurandoSesion = true; // mientras se revisa si hay una sesión guardada

  @override
  void initState() {
    super.initState();
    _intentarRestaurarSesion();
  }

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // "Recordarme": si hay una sesión guardada y el servidor todavía la acepta, entra directo al home.
  // Si no, rellena el correo recordado y muestra el login normal.
  Future<void> _intentarRestaurarSesion() async {
    final correoGuardado = await SesionGuardada.correoRecordado();
    final rol = await SesionGuardada.restaurar();
    if (!mounted) return;

    if (rol != null) {
      _irAlHome(rol);
      return;
    }

    setState(() {
      if (correoGuardado != null) {
        _correoController.text = correoGuardado;
        _rememberMe = true;
      }
      _restaurandoSesion = false;
    });
  }

  // Redirección inteligente según el rol que devuelve tu backend
  void _irAlHome(String rol) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => rol == 'admin'
            ? const HomeAdministradorScreen()
            : const HomeClienteScreen(),
      ),
    );
  }

  // Método para iniciar sesión y validar roles
  void _hacerLogin() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final resultado = await AuthService.login(correo, password);

    setState(() {
      _isLoading = false;
    });

    if (resultado['success']) {
      // 🌟 El token y la sesión ya se guardaron automáticamente en SessionService dentro de AuthService.login
      final usuarioData = resultado['usuario'];
      final String rol = usuarioData['rol'] ?? 'cliente';

      // "Recordarme": guarda la sesión en el teléfono (o la borra si la casilla no está marcada)
      if (_rememberMe) {
        await SesionGuardada.guardar(correo);
      } else {
        await SesionGuardada.olvidar();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Bienvenido, ${usuarioData['nombre']}!')),
      );

      _irAlHome(rol);
    } else {
      final mensajeError = resultado['message'] ?? 'Error desconocido';

      // Si el backend indica que la cuenta no está verificada, mostramos la alerta de redirección
      if (mensajeError.toLowerCase().contains('no ha sido verificada') || 
          mensajeError.toLowerCase().contains('no está verificada')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Cuenta no verificada', style: TextStyle(color: Colors.white)),
            content: Text(
              'El correo "$correo" está registrado pero aún no ha ingresado el código de 6 dígitos. ¿Deseas ir a verificarla ahora?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                onPressed: () {
                  Navigator.pop(context); // Cierra la alerta
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerificarCuentaScreen(
                        correoRegistrado: correo,
                      ),
                    ),
                  );
                },
                child: const Text('Verificar', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensajeError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se revisa la sesión guardada no se muestra el login, para que no parpadee
    if (_restaurandoSesion) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.verdePrimario),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. IMAGEN DE FONDO CON FILTRO OSCURO
          SizedBox.expand(
            child: Image.asset(
              'assets/images/7.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // FILTRO OSCURO
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // CONTENIDO PRINCIPAL
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // TÍTULO
                  Text(
                    'INICIO DE SESIÓN',
                    style: EstiloTexto.tituloPrincipalPrimerPantalla,
                  ),
                  const SizedBox(height: 15),
                  // LOGO
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
                  const SizedBox(height: 30),
                  // TARJETA SEMITRANSPARENTE PARA EL FORMULARIO
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.58),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // CAMPO DE CORREO ELECTRÓNICO
                        TextField(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          style: EstiloTexto.campoTexto,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                            hintText: 'Correo Electrónico...',
                            hintStyle: EstiloTexto.hintTexto,
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // CAMPO DE CONTRASEÑA
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: EstiloTexto.campoTexto,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
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
                        ),
                        const SizedBox(height: 10),
                        // CHECKBOX "RECORDARME"
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                fillColor: WidgetStateProperty.resolveWith((states) => Colors.white),
                                checkColor: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recordarme',
                              style: EstiloTexto.politicasRoboto.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // BOTÓN "INICIAR SESIÓN"
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _hacerLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const LinearBorder(),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'INICIAR SESIÓN',
                              style: EstiloTexto.botonPrincipal.copyWith(
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  // ENLACES INFERIORES Y POLÍTICAS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Olvidaste tu contraseña? ',
                            style: EstiloTexto.textoNormalRoboto,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecuperarScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'RECUPERAR',
                              style: EstiloTexto.enlaceNegritaRoboto,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta? ',
                            style: EstiloTexto.textoNormalRoboto,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegistrarScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'REGISTRAR',
                              style: EstiloTexto.enlaceNegritaRoboto,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Al tocarlo se abren los términos y condiciones y la política de datos
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TerminosCondicionesScreen(),
                              ),
                            ),
                            child: Text(
                              'Políticas y condiciones',
                              style: EstiloTexto.politicasRoboto.copyWith(
                                decoration: TextDecoration.underline,
                              ),
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
        ],
      ),
    );
  }
}