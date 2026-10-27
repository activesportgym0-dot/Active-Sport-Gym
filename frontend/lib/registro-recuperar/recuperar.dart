import 'package:flutter/material.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/registro-recuperar/cambiarcontrasena.dart';
import '../services/auth_service.dart'; // Asegúrate de que la ruta a tu servicio sea correcta

class RecuperarScreen extends StatefulWidget {
  const RecuperarScreen({super.key});

  @override
  State<RecuperarScreen> createState() => _RecuperarScreenState();
}

class _RecuperarScreenState extends State<RecuperarScreen> {
  // Controlador para el campo de correo electrónico
  final TextEditingController _correoController = TextEditingController();
  bool _isLoading = false;

  // Método para solicitar el código al backend
  void _solicitarCodigo() async {
    final correo = _correoController.text.trim();

    if (correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu correo electrónico')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Llamamos a la función del servicio que creamos para el backend
    final resultado = await AuthService.solicitarCodigoRecuperacion(correo);

    setState(() {
      _isLoading = false;
    });

    if (resultado['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['message']), backgroundColor: Colors.green),
      );

      // Redirigimos a la pantalla de cambiar contraseña, pasando opcionalmente el correo si lo requieres
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  CambiarContrasena(correoRecibido: correo,),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. IMAGEN DE FONDO CON FILTRO OSCURO
          SizedBox.expand(
            child: Image.asset(
              'assets/images/5.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.colorBurn,
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
                  // BOTÓN DE REGRESO
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // TÍTULO ORIGINAL
                  Text(
                    'RECUPERAR CONTRASEÑA',
                    style: EstiloTexto.tituloPrincipalPrimerPantalla,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 25),
                  // MENSAJE DEBAJO DEL LOGO
                  Text(
                    'Ingresa tu correo electrónico para recibir un código de 6 cifras y cambiar tu contraseña.',
                    style: EstiloTexto.textoNormalRoboto.copyWith(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // TARJETA SEMITRANSPARENTE PARA EL FORMULARIO
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // CAMPO DE CORREO ELECTRÓNICO CON EL CONTROLADOR
                        TextField(
                          controller: _correoController,
                          style: EstiloTexto.campoTexto,
                          keyboardType: TextInputType.emailAddress,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // BOTÓN "VERIFICAR" / SOLICITAR CÓDIGO
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _solicitarCodigo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdePrimario, // O mantén negro si prefieres
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              'VERIFICAR',
                              style: EstiloTexto.botonPrincipal.copyWith(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                    ),
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