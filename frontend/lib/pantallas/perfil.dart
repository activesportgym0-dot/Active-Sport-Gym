import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Datos reales basados exactamente en tu base de datos de Supabase
  bool _isEditing = false;

  final TextEditingController _nombreController = TextEditingController(text: 'Luisa María');
  final TextEditingController _apellidoController = TextEditingController(text: 'Carvajal');
  final TextEditingController _correoController = TextEditingController(text: 'luisamariacarvajalospina548@gmail.com');
  final TextEditingController _telefonoController = TextEditingController(text: '3115313005');
  final TextEditingController _cedulaController = TextEditingController(text: '1076505117');
  final TextEditingController _edadController = TextEditingController(text: '19');
  final TextEditingController _pesoController = TextEditingController(text: '60.0');
  final TextEditingController _alturaController = TextEditingController(text: '1.50');
  
  final String rol = 'cliente'; // o 'admin'
  final String? fotoPerfil = null; // Viene de la tabla perfil (NULL por defecto)

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
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // TODO: Guardar cambios en tu backend / Supabase (Tablas usuarios y perfil)
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                        backgroundImage: fotoPerfil != null ? NetworkImage(fotoPerfil!) : null,
                        child: fotoPerfil == null
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
                            onPressed: () {
                              // Cambiar foto de perfil
                            },
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
                    rol.toUpperCase(),
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
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        // Guardar cambios
                      });
                    },
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