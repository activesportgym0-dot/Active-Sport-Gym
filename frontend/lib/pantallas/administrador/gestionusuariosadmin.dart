import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/gestionar%20usuarios/tarjeta_usuario_admin.dart';
import 'package:frontend/componentes/cliente/burbuja_mini_chat_modal.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/administrador/detalle_perfil_admin.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/usuario_service.dart';
class GestionUsuariosAdminScreen extends StatefulWidget {
  const GestionUsuariosAdminScreen({super.key});
  @override
  State<GestionUsuariosAdminScreen> createState() => _GestionUsuariosAdminScreenState();
}
class _GestionUsuariosAdminScreenState extends State<GestionUsuariosAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Usuarios reales que vienen del servidor (GET /usuarios). Se guardan como mapas
  // con las claves que ya usan TarjetaUsuarioAdmin y el detalle (id, nombre, activo...).
  List<Map<String, dynamic>> _usuarios = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _usuariosFiltrados = [];

  // Filtro rápido: ver solo las cuentas inactivas (las nuevas esperan aquí a que las actives)
  bool _soloInactivos = false;

  int get _cantidadInactivos => _usuarios.where((u) => u['activo'] != true).length;
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrarUsuarios);
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    if (mounted) setState(() => _isLoading = true);

    final resultado = await UsuarioService.listarUsuarios();
    if (!mounted) return;

    if (resultado['success'] == true) {
      final lista = resultado['usuarios'] as List<UserModel>;
      setState(() {
        _usuarios = lista.map((u) => u.toMapaAdmin()).toList();
        _isLoading = false;
      });
      _filtrarUsuarios();
    } else {
      setState(() => _isLoading = false);
      _mostrarMensaje(
        'Error al cargar los usuarios: ${resultado['message']}',
        exito: false,
      );
    }
  }

  void _mostrarMensaje(String mensaje, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  // Activa o desactiva la cuenta (PATCH /usuarios/:id/estado).
  // El interruptor cambia al instante y vuelve atrás si el servidor lo rechaza.
  Future<void> _cambiarEstadoUsuario(Map<String, dynamic> usuario, bool nuevoEstado) async {
    final id = int.tryParse(usuario['id'].toString());
    if (id == null) return;

    // Evita que el administrador se deje a sí mismo sin acceso
    if (!nuevoEstado && id == SessionService.idUsuario) {
      _mostrarMensaje('No puedes desactivar tu propia cuenta de administrador.', exito: false);
      return;
    }

    final estadoAnterior = usuario['activo'] == true;
    setState(() => usuario['activo'] = nuevoEstado);

    final resultado = await UsuarioService.cambiarEstado(id, nuevoEstado);
    if (!mounted) return;

    if (resultado['success'] == true) {
      _mostrarMensaje(resultado['message'].toString(), exito: true);
      _filtrarUsuarios();
    } else {
      setState(() => usuario['activo'] = estadoAnterior);
      _mostrarMensaje(resultado['message'].toString(), exito: false);
    }
  }

  Future<void> _abrirDetalle(Map<String, dynamic> usuario) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallePerfilAdminScreen(usuario: usuario),
      ),
    );
    // Al volver se recarga: el usuario pudo ser eliminado desde el detalle
    if (mounted) _cargarUsuarios();
  }
  void _filtrarUsuarios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _usuariosFiltrados = _usuarios.where((usuario) {
        final nombreCompleto = '${usuario['nombre']} ${usuario['apellido']}'.toLowerCase();
        final cedula = usuario['cedula'].toString();
        final coincideTexto = nombreCompleto.contains(query) || cedula.contains(query);
        final coincideEstado = !_soloInactivos || usuario['activo'] != true;
        return coincideTexto && coincideEstado;
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

              // Filtro rápido: todos / inactivos (pendientes de activar)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('TODOS (${_usuarios.length})'),
                      selected: !_soloInactivos,
                      selectedColor: AppColors.verdePrimario,
                      backgroundColor: AppColors.grisOscuro,
                      labelStyle: TextStyle(
                        color: !_soloInactivos ? AppColors.fondoNegro : AppColors.grisClaro,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) {
                        setState(() => _soloInactivos = false);
                        _filtrarUsuarios();
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('INACTIVOS ($_cantidadInactivos)'),
                      selected: _soloInactivos,
                      selectedColor: Colors.redAccent,
                      backgroundColor: AppColors.grisOscuro,
                      labelStyle: TextStyle(
                        color: _soloInactivos ? AppColors.blancoPuro : AppColors.grisClaro,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) {
                        setState(() => _soloInactivos = true);
                        _filtrarUsuarios();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.verdePrimario),
                      )
                    : RefreshIndicator(
                        color: AppColors.verdePrimario,
                        onRefresh: _cargarUsuarios,
                        child: _usuariosFiltrados.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 120),
                                  Center(
                                    child: Text(
                                      'No se encontraron usuarios',
                                      style: TextStyle(color: AppColors.grisClaro, fontSize: 13),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _usuariosFiltrados.length,
                                itemBuilder: (context, index) {
                                  final usuario = _usuariosFiltrados[index];
                                  return TarjetaUsuarioAdmin(
                                    usuario: usuario,
                                    onTap: () => _abrirDetalle(usuario),
                                    onSwitchChanged: (value) => _cambiarEstadoUsuario(usuario, value),
                                  );
                                },
                              ),
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