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
  // Controladores para lo que el usuario debe digitar
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Estados para validar los requisitos de la contraseña en tiempo real
  bool _tieneMinimo8 = false;
  bool _tieneMayuscula = false;
  bool _tieneNumero = false;
  bool _tieneSimbolo = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validarContrasenaEnTiempoReal);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validarContrasenaEnTiempoReal);
    _codigoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validarContrasenaEnTiempoReal() {
    final val = _passwordController.text;
    setState(() {
      _tieneMinimo8 = val.length >= 8;
      _tieneMayuscula = RegExp(r'(?=.*[A-Z])').hasMatch(val);
      _tieneNumero = RegExp(r'(?=.*[0-9])').hasMatch(val);
      _tieneSimbolo = RegExp(r'(?=.*[!@#\$%^&*(),.?":{}|<>])').hasMatch(val);
    });
  }

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

    if (!_tieneMinimo8 || !_tieneMayuscula || !_tieneNumero || !_tieneSimbolo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña no cumple con todos los requisitos de seguridad')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Usamos widget.correoRecibido de forma interna
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
                        const SizedBox(height: 8),

                        // INDICADORES EN TIEMPO REAL
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRequisitoItem('Mínimo 8 caracteres', _tieneMinimo8),
                              _buildRequisitoItem('Al menos una letra mayúscula', _tieneMayuscula),
                              _buildRequisitoItem('Al menos un número', _tieneNumero),
                              _buildRequisitoItem('Al menos un símbolo especial', _tieneSimbolo),
                            ],
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

  Widget _buildRequisitoItem(String texto, bool cumple) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            cumple ? Icons.check_circle : Icons.radio_button_unchecked,
            color: cumple ? AppColors.verdePrimario : Colors.grey,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: cumple ? AppColors.verdePrimario : Colors.grey,
              fontSize: 11,
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