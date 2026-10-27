import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/administrador/control_membresias.dart';
import 'package:frontend/componentes/administrador/membresia/tarjeta_historial_admin.dart';
import 'package:frontend/pantallas/administrador/consultarHistorialMembresias.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

class DetallePerfilAdminScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const DetallePerfilAdminScreen({super.key, required this.usuario});

  @override
  State<DetallePerfilAdminScreen> createState() => _DetallePerfilAdminScreenState();
}

class _DetallePerfilAdminScreenState extends State<DetallePerfilAdminScreen> {
  // Inicialización directa para evitar errores de tipo LateInitializationError
  String _estadoMembresia = 'activa';
  String _fechaInicio = '2026-10-01';
  String _fechaFin = '2026-11-01';

  @override
  void initState() {
    super.initState();
    _estadoMembresia = widget.usuario['activo'] == true ? 'activa' : 'inactiva';
  }

  void _mostrarModalAsignarMembresia() {
    final TextEditingController inicioController = TextEditingController(text: _fechaInicio);
    final TextEditingController finController = TextEditingController(text: _fechaFin);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 24,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: AppColors.grisOscuro,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: AppColors.verdePrimario.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ASIGNAR / RENOVAR MEMBRESÍA',
              style: TextStyle(
                fontFamily: 'Oswald',
                color: AppColors.verdePrimario,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: inicioController,
              style: const TextStyle(color: AppColors.blancoPuro, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Fecha de Inicio (YYYY-MM-DD)',
                labelStyle: const TextStyle(color: AppColors.grisClaro, fontSize: 12),
                filled: true,
                fillColor: AppColors.fondoNegro,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.verdePrimario),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: finController,
              style: const TextStyle(color: AppColors.blancoPuro, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Fecha Fin (YYYY-MM-DD)',
                labelStyle: const TextStyle(color: AppColors.grisClaro, fontSize: 12),
                filled: true,
                fillColor: AppColors.fondoNegro,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.verdePrimario),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _fechaInicio = inicioController.text;
                    _fechaFin = finController.text;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Membresía actualizada con éxito'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdePrimario,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'GUARDAR REGISTRO',
                  style: TextStyle(
                    color: AppColors.fondoNegro,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminarUsuario() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        title: const Text(
          'Eliminar Usuario',
          style: TextStyle(color: AppColors.blancoPuro, fontFamily: 'Oswald'),
        ),
        content: Text(
          '¿Estás segura de que deseas eliminar a ${widget.usuario['nombre']} ${widget.usuario['apellido']}? Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.grisClaro, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grisClaro)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usuario eliminado correctamente'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.usuario;

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
          'PERFIL DE USUARIO',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 16,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            tooltip: 'Eliminar usuario',
            onPressed: _confirmarEliminarUsuario,
          ),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar e Identidad
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.grisOscuro,
                            child: Icon(
                              Icons.person,
                              size: 45,
                              color: AppColors.verdePrimario,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${user['nombre']} ${user['apellido']}',
                            style: const TextStyle(
                              color: AppColors.blancoPuro,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rol: ${user['rol'].toUpperCase()}',
                            style: const TextStyle(
                              color: AppColors.verdePrimario,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Información de Contacto
                    const Text(
                      'INFORMACIÓN DE CONTACTO',
                      style: TextStyle(
                        color: AppColors.grisMedio,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.grisOscuro,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.badge_outlined, 'Cédula', '${user['cedula']}'),
                          const Divider(color: AppColors.grisMedio, height: 20),
                          _buildInfoRow(Icons.email_outlined, 'Correo electrónico', '${user['correo']}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Control de Membresía
                    ControlMembresiaAdmin(
                      estadoMembresia: _estadoMembresia,
                      fechaInicio: _fechaInicio,
                      fechaFin: _fechaFin,
                      onEstadoChanged: (nuevoEstado) {
                        setState(() {
                          _estadoMembresia = nuevoEstado;
                        });
                      },
                      onRenovarAsignar: _mostrarModalAsignarMembresia,
                    ),
                    const SizedBox(height: 24),

                    // Tarjeta de Historial
                    TarjetaHistorialAdmin(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistorialClienteAdminScreen(usuario: widget.usuario),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const BurbujaMiniChatModal(),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.verdePrimario, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.grisClaro, fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: AppColors.blancoPuro, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}