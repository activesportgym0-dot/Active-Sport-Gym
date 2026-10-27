import 'package:flutter/material.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/registro-recuperar/Login.dart';
import '../services/auth_service.dart';

class CambiarContrasena extends StatefulWidget {
  final String correoRecibido; // El correo viaja automáticamente desde la pantalla anterior

  const CambiarContrasena({super.key, required this.correoRecibido});

  @override
  State<CambiarContrasena> createState() => _CambiarContrasenaState();
}

class _CambiarContrasenaState extends State<CambiarContrasena> {
  // Controladores solo para lo que el usuario debe digitar: el código y las nuevas contraseñas
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  void _ejecutarCambioPassword() async {
    final codigo = _codigoController.text.trim();
    final nuevaPass = _passwordController.text.trim();
    final confirmarPass = _confirmPasswordController.text.trim();

    if (codigo.isEmpty || nuevaPass.isEmpty || confirmarPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    if (nuevaPass != confirmarPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    if (nuevaPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Usamos widget.correoRecibido de forma interna, sin que el usuario lo vea ni lo escriba de nuevo
    final resultado = await AuthService.cambiarContrasenaConCodigo(
      correo: widget.correoRecibido,
      codigo: codigo,
      nuevaContrasena: nuevaPass,
      confirmarContrasena: confirmarPass,
    );

    setState(() {
      _isLoading = false;
    });

    if (resultado['success']) {
      _mostrarExitoYRedirigir(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['message'] ?? 'Error al actualizar'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // IMAGEN DE FONDO CON FILTRO OSCURO
          SizedBox.expand(
            child: Image.asset(
              'assets/images/4.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.colorBurn,
            ),
          ),
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
                  const SizedBox(height: 5),
                  Text(
                    'NUEVA CONTRASEÑA',
                    style: EstiloTexto.tituloPrincipalPrimerPantalla,
                    textAlign: TextAlign.center,
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
                  const SizedBox(height: 15),

                  // MENSAJE INDICANDO QUE EL CORREO YA ESTÁ TOMADO EN CUENTA
                  Text(
                    'Hemos enviado un código de 6 dígitos al correo:\n${widget.correoRecibido}',
                      style: EstiloTexto.textoNormalRoboto.copyWith(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),

                  // TARJETA SEMITRANSPARENTE PARA EL FORMULARIO (Sin campo de correo)
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
                        // CÓDIGO DE 6 CIFRAS
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
                        const SizedBox(height: 15),

                        // NUEVA CONTRASEÑA
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
                            hintText: 'Nueva contraseña...',
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

                        // CONFIRMAR CONTRASEÑA
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: EstiloTexto.campoTexto,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // BOTÓN CAMBIAR CONTRASEÑA
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _ejecutarCambioPassword,
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
                              'CAMBIAR CONTRASEÑA',
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

  // ALERTA ELEGANTE DE ÉXITO
  void _mostrarExitoYRedirigir(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          title: Text(
            "¡CAMBIO DE CONTRASEÑA\nEXITOSO!",
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

    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }
}