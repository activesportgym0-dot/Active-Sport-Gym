import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/gestionar%20usuarios/tarjeta_usuario_admin.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/administrador/detalle_perfil_admin.dart';

class GestionUsuariosAdminScreen extends StatefulWidget {
  const GestionUsuariosAdminScreen({super.key});

  @override
  State<GestionUsuariosAdminScreen> createState() => _GestionUsuariosAdminScreenState();
}

class _GestionUsuariosAdminScreenState extends State<GestionUsuariosAdminScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _usuarios = [
    {
      'id': 5,
      'nombre': 'Santiago',
      'apellido': 'Gonzalez',
      'correo': 'maicolgonzalezorozco1604@gmail.com',
      'cedula': '1077848982',
      'rol': 'cliente',
      'activo': true,
    },
    {
      'id': 7,
      'nombre': 'Active Sport',
      'apellido': 'Gym',
      'correo': 'activesportgym0@gmail.com',
      'cedula': '1076505116',
      'rol': 'admin',
      'activo': true,
    },
    {
      'id': 13,
      'nombre': 'Luisa María',
      'apellido': 'Carvajal',
      'correo': 'luisamariacarvajalospina548@gmail.com',
      'cedula': '1076505117',
      'rol': 'cliente',
      'activo': true,
    },
  ];

  List<Map<String, dynamic>> _usuariosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _usuariosFiltrados = _usuarios;
    _searchController.addListener(_filtrarUsuarios);
  }

  void _filtrarUsuarios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _usuariosFiltrados = _usuarios.where((usuario) {
        final nombreCompleto = '${usuario['nombre']} ${usuario['apellido']}'.toLowerCase();
        final cedula = usuario['cedula'].toString();
        return nombreCompleto.contains(query) || cedula.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text(
          'GESTIÓN DE USUARIOS',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 16,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: FondoApp(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.blancoPuro, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, apellido o cédula...',
                    hintStyle: const TextStyle(color: AppColors.grisMedio, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: AppColors.grisMedio),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.grisMedio, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.grisOscuro,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.verdePrimario),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _usuariosFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron usuarios',
                          style: TextStyle(color: AppColors.grisClaro, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _usuariosFiltrados.length,
                        itemBuilder: (context, index) {
                          final usuario = _usuariosFiltrados[index];
                          return TarjetaUsuarioAdmin(
                            usuario: usuario,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetallePerfilAdminScreen(usuario: usuario),
                                ),
                              );
                            },
                            onSwitchChanged: (value) {
                              setState(() {
                                usuario['activo'] = value;
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const BurbujaMiniChatModal(),
    );
  }
}