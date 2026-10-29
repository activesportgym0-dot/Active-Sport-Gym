import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/notificacion/modal_crear_notificacion.dart';
import 'package:frontend/componentes/administrador/notificacion/tarjeta_notificacion_admin.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/models/notificacion_model.dart';
import 'package:frontend/services/notificacion_service.dart'; // 👈 Importación de la burbuja de la IA
class NotificacionesAdminScreen extends StatefulWidget {
  const NotificacionesAdminScreen({super.key});
  @override
  State<NotificacionesAdminScreen> createState() => _NotificacionesAdminScreenState();
}
class _NotificacionesAdminScreenState extends State<NotificacionesAdminScreen> {
  // Notificaciones reales que vienen del servidor (GET /notificaciones/admin)
  List<NotificacionModel> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final notificaciones = await NotificacionService.obtenerTodas();
      if (!mounted) return;
      setState(() {
        _notificaciones = notificaciones;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarMensaje(
        'Error al cargar las notificaciones: ${e.toString().replaceFirst('Exception: ', '')}',
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

  Future<void> _crearNotificacion(Map<String, dynamic> datos) async {
    final resultado = await NotificacionService.crearNotificacion(
      titulo: datos['titulo'].toString(),
      mensaje: datos['mensaje'].toString(),
      tipo: datos['tipo'].toString(),
      idUsuario: datos['id_usuario'] as int?,
    );
    if (!mounted) return;

    final exito = resultado['success'] == true;
    _mostrarMensaje(resultado['message']?.toString() ?? 'Operación finalizada', exito: exito);
    if (exito) await _cargarNotificaciones();
  }

  Future<void> _eliminarNotificacion(NotificacionModel noti) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        title: const Text('Eliminar Notificación', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás segura de que deseas eliminar "${noti.titulo}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final resultado = await NotificacionService.eliminarNotificacion(noti.idNotificacion);
    if (!mounted) return;

    final exito = resultado['success'] == true;
    _mostrarMensaje(resultado['message']?.toString() ?? 'Operación finalizada', exito: exito);
    if (exito) await _cargarNotificaciones();
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
        title: Text(
          'GESTIÓN DE NOTIFICACIONES',
          style: EstiloTexto.bienvenida.copyWith(
            fontFamily: 'Oswald',
            fontSize: 16,
            color: AppColors.verdePrimario,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      // 🌟 Usamos un Stack dentro de FondoApp para alojar el contenido y la burbuja de la IA flotando libremente
      body: FondoApp(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NOTIFICACIONES ENVIADAS',
                          style: EstiloTexto.enlaceNegritaRoboto.copyWith(letterSpacing: 1.1),
                        ),
                        Text(
                          '${_notificaciones.length} activas',
                          style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.verdePrimario),
                          )
                        : RefreshIndicator(
                            color: AppColors.verdePrimario,
                            onRefresh: _cargarNotificaciones,
                            child: _notificaciones.isEmpty
                                ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      const SizedBox(height: 120),
                                      Center(
                                        child: Text(
                                          'No hay notificaciones creadas',
                                          style: EstiloTexto.hintTexto,
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                    itemCount: _notificaciones.length,
                                    itemBuilder: (context, index) {
                                      final noti = _notificaciones[index];
                                      return TarjetaNotificacionAdmin(
                                        noti: noti.toMapaTarjeta(),
                                        onDelete: () => _eliminarNotificacion(noti),
                                      );
                                    },
                                  ),
                          ),
                  ),
                ],
              ),
              // 🌟 Burbuja de la IA interactiva y arrastrable por toda la pantalla
              const Positioned.fill(
                child: BurbujaMiniChatModal(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarModalCrear(context),
        backgroundColor: AppColors.verdePrimario,
        icon: const Icon(Icons.send_rounded, color: AppColors.fondoNegro),
        label: Text(
          'CREAR NOTIFICACIÓN',
          style: EstiloTexto.botonPrincipal.copyWith(color: AppColors.fondoNegro, fontSize: 15),
        ),
      ),
    );
  }
  void _mostrarModalCrear(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondoNegro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ModalCrearNotificacion(
          onCrear: (datos) => _crearNotificacion(datos),
        );
      },
    );
  }
}
