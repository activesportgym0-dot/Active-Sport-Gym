import 'package:flutter/material.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/core/colores.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'verificar_cuenta_screen.dart'; // Asegúrate de importar tu pantalla de verificación

class RegistrarScreen extends StatefulWidget {
  const RegistrarScreen({super.key});

  @override
  State<RegistrarScreen> createState() => _RegistrarScreenState();
}

class _RegistrarScreenState extends State<RegistrarScreen> {
  // Controladores para cada campo del formulario
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Método para ejecutar el registro
  void _realizarRegistro() async {
    final cedula = _cedulaController.text.trim();
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final correo = _correoController.text.trim();
    final telefono = _telefonoController.text.trim();
    final pesoStr = _pesoController.text.trim();
    final alturaStr = _alturaController.text.trim();
    final edadStr = _edadController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validación rápida local
    if (cedula.isEmpty || nombre.isEmpty || apellido.isEmpty || correo.isEmpty || 
        telefono.isEmpty || pesoStr.isEmpty || alturaStr.isEmpty || edadStr.isEmpty || 
        password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final nuevoUsuario = UserModel(
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      telefono: telefono,
      cedula: cedula,
      edad: int.tryParse(edadStr),
      peso: double.tryParse(pesoStr),
      altura: double.tryParse(alturaStr),
      password: password,
      confirmarContrasena: confirmPassword,
      rol: 'cliente',
    );

    // Llamamos al servicio de registro del backend
    final exito = await AuthService.registrar(nuevoUsuario);

    setState(() {
      _isLoading = false;
    });

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Registro exitoso! Ingresa el código enviado a tu correo.')),
      );

      // REDIRECCIÓN A VERIFICACIÓN: Pasamos el correo para que allá se valide el código
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificarCuentaScreen(correoRegistrado: correo),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar. Verifica los datos o tu conexión.')),
      );
    }
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
          // CONTENIDO PRINCIPAL SCROLLABLE
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // BOTÓN DE REGRESAR
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // TÍTULO "REGISTRO"
                    Text(
                      'REGISTRO',
                      style: EstiloTexto.tituloPrincipalPrimerPantalla,
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    // SUBTÍTULO DE BIENVENIDA
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
                    
                    // CONTENEDOR PRINCIPAL DEL FORMULARIO
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
                      child: Column(
                        children: [
                          _buildTextField(controller: _cedulaController, icon: Icons.card_membership, hint: 'Documento De Identidad...', keyboardType: TextInputType.number),
                          const SizedBox(height: 12),
                          _buildTextField(controller: _nombreController, icon: Icons.person_outline, hint: 'Nombre...'),
                          const SizedBox(height: 12),
                          _buildTextField(controller: _apellidoController, icon: Icons.person_outline, hint: 'Apellido...'),
                          const SizedBox(height: 12),
                          _buildTextField(controller: _correoController, icon: Icons.email_outlined, hint: 'Correo Electrónico...', keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 12),
                          _buildTextField(controller: _telefonoController, icon: Icons.phone_outlined, hint: 'Teléfono...', keyboardType: TextInputType.phone),
                          const SizedBox(height: 12),
                          _buildTextField(controller: _pesoController, icon: Icons.monitor_weight_outlined, hint: 'Peso (kg)...', keyboardType: TextInputType.number),
                          const SizedBox(height: 12),
                          _buildTextField(controller: _alturaController, icon: Icons.height_outlined, hint: 'Altura (cm)...', keyboardType: TextInputType.number),
                          const SizedBox(height: 12),
                          _buildTextField(controller: _edadController, icon: Icons.cake_outlined, hint: 'Edad...', keyboardType: TextInputType.number),
                          const SizedBox(height: 12),

                          // CONTRASEÑA
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
                          const SizedBox(height: 12),

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
                    const SizedBox(height: 25),

                    // BOTÓN "REGISTRAR" ÚNICO Y LIMPIO
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
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text(
                                'REGISTRAR',
                                style: EstiloTexto.botonPrincipal.copyWith(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ENLACES INFERIORES
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

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: EstiloTexto.campoTexto,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
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
}