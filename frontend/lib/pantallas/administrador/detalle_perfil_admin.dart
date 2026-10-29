import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/administrador/membresia/tarjeta_historial_admin.dart';
import 'package:frontend/componentes/administrador/membresia/control_membresia_admin.dart';

import 'package:frontend/pantallas/administrador/consultarHistorialMembresias.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/models/membresia_model.dart';
import 'package:frontend/models/perfil_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/membresia_service.dart';
import 'package:frontend/services/perfil_service.dart';
import 'package:frontend/services/usuario_service.dart';
class DetallePerfilAdminScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const DetallePerfilAdminScreen({super.key, required this.usuario});
  @override
  State<DetallePerfilAdminScreen> createState() => _DetallePerfilAdminScreenState();
}
class _DetallePerfilAdminScreenState extends State<DetallePerfilAdminScreen> {
  // Datos reales: perfil (GET /perfil/:id) y membresía actual (GET /membresias/historial/:id)
  PerfilModel? _perfil;
  MembresiaModel? _membresia;
  bool _isLoading = true;

  int? get _idUsuario =>
      int.tryParse((widget.usuario['id'] ?? widget.usuario['id_usuario']).toString());

  // Mientras llega el perfil se muestran los datos básicos que trajo la lista
  String get _nombreCompleto =>
      _perfil?.nombreCompleto ??
      '${widget.usuario['nombre'] ?? ''} ${widget.usuario['apellido'] ?? ''}'.trim();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _mostrarMensaje(String mensaje, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _cargarDatos() async {
    final id = _idUsuario;
    if (id == null) {
      _isLoading = false;
      return;
    }
    await Future.wait([_cargarPerfil(id), _cargarMembresia(id)]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _cargarPerfil(int id) async {
    final resultado = await PerfilService.obtenerPerfil(id);
    if (!mounted) return;
    if (resultado['success'] == true) {
      setState(() => _perfil = resultado['perfil'] as PerfilModel);
    } else {
      _mostrarMensaje('No se pudo cargar el perfil: ${resultado['message']}', exito: false);
    }
  }

  Future<void> _cargarMembresia(int id) async {
    try {
      final membresia = await MembresiaService.obtenerMembresiaActual(id);
      if (!mounted) return;
      setState(() => _membresia = membresia);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(
        'No se pudo cargar la membresía: ${e.toString().replaceFirst('Exception: ', '')}',
        exito: false,
      );
    }
  }

  Future<void> _cambiarEstadoMembresia(String nuevoEstado) async {
    final id = _idUsuario;
    final membresia = _membresia;

    if (id == null || membresia == null) {
      _mostrarMensaje(
        'Este usuario no tiene un plan. Usa "Asignar / Renovar" primero.',
        exito: false,
      );
      return;
    }
    if (membresia.estado == nuevoEstado) {
      _mostrarMensaje('La membresía ya está en estado $nuevoEstado.', exito: false);
      return;
    }

    final resultado = await MembresiaService.cambiarEstado(
      idMembresia: membresia.idMembresia,
      estado: nuevoEstado,
    );
    if (!mounted) return;

    final exito = resultado['success'] == true;
    _mostrarMensaje(resultado['message']?.toString() ?? 'Operación finalizada', exito: exito);
    if (exito) await _cargarMembresia(id);
  }

  void _mostrarModalAsignarMembresia() {
    final id = _idUsuario;
    if (id == null) return;

    final hoy = DateTime.now();
    final inicioController = TextEditingController(text: MembresiaModel.fechaIso(hoy));
    final finController = TextEditingController(
      text: MembresiaModel.fechaIso(DateTime(hoy.year, hoy.month + 1, hoy.day)),
    );
    String? errorMensaje;
    bool guardando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (builderContext, setSheetState) {
          Future<void> guardar() async {
            final inicio = inicioController.text.trim();
            final fin = finController.text.trim();
            final formato = RegExp(r'^\d{4}-\d{2}-\d{2}$');

            if (!formato.hasMatch(inicio) ||
                !formato.hasMatch(fin) ||
                DateTime.tryParse(inicio) == null ||
                DateTime.tryParse(fin) == null) {
              setSheetState(() => errorMensaje = 'Usa el formato YYYY-MM-DD (ej. 2026-10-01).');
              return;
            }
            if (!DateTime.parse(fin).isAfter(DateTime.parse(inicio))) {
              setSheetState(() => errorMensaje = 'La fecha de fin debe ser posterior a la de inicio.');
              return;
            }

            setSheetState(() {
              errorMensaje = null;
              guardando = true;
            });

            final resultado = await MembresiaService.asignarMembresia(
              idUsuario: id,
              estado: 'activa',
              fechaInicio: inicio,
              fechaFin: fin,
            );
            if (!mounted) return;

            if (resultado['success'] == true) {
              Navigator.pop(sheetContext);
              _mostrarMensaje(resultado['message'].toString(), exito: true);
              await _cargarMembresia(id);
            } else {
              setSheetState(() {
                guardando = false;
                errorMensaje = resultado['message'].toString();
              });
            }
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(builderContext).viewInsets.bottom + 20,
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
                if (errorMensaje != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMensaje!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: guardando ? null : guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrimario,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.fondoNegro,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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
          );
        },
      ),
    );
  }

  void _confirmarEliminarUsuario() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        title: const Text(
          'Eliminar Usuario',
          style: TextStyle(color: AppColors.blancoPuro, fontFamily: 'Oswald'),
        ),
        content: Text(
          '¿Estás segura de que deseas eliminar a $_nombreCompleto? Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.grisClaro, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grisClaro)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _eliminarUsuario();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarUsuario() async {
    final id = _idUsuario;
    if (id == null) return;

    // Evita que el administrador elimine su propia cuenta
    if (id == SessionService.idUsuario) {
      _mostrarMensaje('No puedes eliminar tu propia cuenta de administrador.', exito: false);
      return;
    }

    final resultado = await UsuarioService.eliminarUsuario(id);
    if (!mounted) return;

    if (resultado['success'] == true) {
      _mostrarMensaje(resultado['message'].toString(), exito: false);
      Navigator.pop(context, true); // la lista se recarga al volver
    } else {
      _mostrarMensaje(resultado['message'].toString(), exito: false);
    }
  }

  String _valor(String? texto) => (texto == null || texto.trim().isEmpty) ? '—' : texto.trim();

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
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(
                          color: AppColors.verdePrimario,
                          backgroundColor: AppColors.grisOscuro,
                        ),
                      ),
                    // Avatar e Identidad
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.grisOscuro,
                            backgroundImage: _perfil?.fotoPerfil != null
                                ? NetworkImage(_perfil!.fotoPerfil!)
                                : null,
                            child: _perfil?.fotoPerfil == null
                                ? const Icon(
                                    Icons.person,
                                    size: 45,
                                    color: AppColors.verdePrimario,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _nombreCompleto,
                            style: const TextStyle(
                              color: AppColors.blancoPuro,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rol: ${(_perfil?.rol ?? user['rol'] ?? '').toString().toUpperCase()}',
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
                          _buildInfoRow(Icons.badge_outlined, 'Cédula', _valor(_perfil?.cedula ?? user['cedula']?.toString())),
                          const Divider(color: AppColors.grisMedio, height: 20),
                          _buildInfoRow(Icons.email_outlined, 'Correo electrónico', _valor(_perfil?.correo ?? user['correo']?.toString())),
                          const Divider(color: AppColors.grisMedio, height: 20),
                          _buildInfoRow(Icons.phone_outlined, 'Teléfono', _valor(_perfil?.telefono ?? user['telefono']?.toString())),
                          const Divider(color: AppColors.grisMedio, height: 20),
                          _buildInfoRow(Icons.cake_outlined, 'Edad', _perfil?.edad != null ? '${_perfil!.edad} años' : '—'),
                          const Divider(color: AppColors.grisMedio, height: 20),
                          _buildInfoRow(Icons.monitor_weight_outlined, 'Peso', _perfil?.peso != null ? '${_perfil!.peso} kg' : '—'),
                          const Divider(color: AppColors.grisMedio, height: 20),
                          _buildInfoRow(Icons.height_outlined, 'Altura', _perfil?.altura != null ? '${_perfil!.altura} m' : '—'),
                          const Divider(color: AppColors.grisMedio, height: 20),
                          _buildInfoRow(Icons.event_outlined, 'Fecha de registro', _perfil?.fechaRegistroFormateada ?? '—'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Control de Membresía
                    ControlMembresiaAdmin(
                      estadoMembresia: _membresia?.estado ?? 'sin membresía',
                      fechaInicio: _membresia?.fechaInicioFormateada ?? '—',
                      fechaFin: _membresia?.fechaFinFormateada ?? '—',
                      onEstadoChanged: _cambiarEstadoMembresia,
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
