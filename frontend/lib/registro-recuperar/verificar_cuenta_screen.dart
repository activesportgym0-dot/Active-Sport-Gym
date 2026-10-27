import 'package:flutter/material.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/core/colores.dart';
import '../services/auth_service.dart';
import 'Login.dart'; 
class VerificarCuentaScreen extends StatefulWidget {
  final String correoRegistrado;

  const VerificarCuentaScreen({super.key, required this.correoRegistrado});

  @override
  State<VerificarCuentaScreen> createState() => _VerificarCuentaScreenState();
}

class _VerificarCuentaScreenState extends State<VerificarCuentaScreen> {
  final TextEditingController _codigoController = TextEditingController();
  bool _isLoading = false;

  // Método para verificar el código enviado por el usuario
  void _verificarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty || codigo.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el código de 6 dígitos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final resultado = await AuthService.verificarCuenta(widget.correoRegistrado, codigo);

    setState(() {
      _isLoading = false;
    });

    if (resultado['success']) {
      // Llamamos a la alerta elegante de éxito al verificar correctamente
      _mostrarExitoYRedirigir(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['message'] ?? 'Código incorrecto')),
      );
    }
  }

  // ALERTA ELEGANTE DE ÉXITO (Estilo idéntico al de Cambiar Contraseña)
  void _mostrarExitoYRedirigir(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Bloquea toques afuera
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          title: Text(
            "¡CUENTA VERIFICADA\nEXITOSAMENTE!",
            style: EstiloTexto.bienvenida,
            textAlign: TextAlign.center,
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                "Redirigiendo al login...",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    // Temporizador de 3 segundos para ir al login automáticamente
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pop(); // Cierra la alerta
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // IMAGEN DE FONDO
          Positioned.fill(
            child: Image.asset(
              'assets/images/3.jpg',
              fit: BoxFit.cover,
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // BOTÓN REGresar
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // TÍTULO
                    Text(
                      'VERIFICAR CUENTA',
                      style: EstiloTexto.tituloPrincipalPrimerPantalla,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    // LOGO CIRCULAR
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
                    const SizedBox(height: 15),
                    // SUBTÍTULO CON CORREO
                    Text(
                      'Hemos enviado un código de 6 dígitos al correo:\n${widget.correoRegistrado}',
                      style: EstiloTexto.textoNormalRoboto.copyWith(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    // CONTENEDOR DEL FORMULARIO
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
                          TextField(
                            controller: _codigoController,
                            style: EstiloTexto.campoTexto,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              counterText: '',
                              prefixIcon: const Icon(Icons.pin_outlined, color: Colors.white70),
                              hintText: 'Código de 6 cifras...',
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
                    const SizedBox(height: 25),
                    // BOTÓN VERIFICAR CÓDIGO
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verificarCodigo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdePrimario,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text(
                                'VERIFICAR CÓDIGO',
                                style: EstiloTexto.botonPrincipal.copyWith(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // REENVIAR CÓDIGO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No recibiste el código? ',
                          style: EstiloTexto.textoNormalRoboto,
                        ),
                        GestureDetector(
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reenviando código a tu correo...')),
                            );

                            final respuesta = await AuthService.reenviarCodigo(widget.correoRegistrado);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(respuesta['message']),
                                  backgroundColor: respuesta['success'] ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text(
                            'REENVIAR',
                            style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                              color: AppColors.verdePrimario,
                            ),
                          ),
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
}