import 'package:flutter/material.dart';
import 'package:frontend/componentes/administrador/notificacion/modal_crear_notificacion.dart';
import 'package:frontend/componentes/administrador/notificacion/tarjeta_notificacion_admin.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart'; // 👈 Importación de la burbuja de la IA

class NotificacionesAdminScreen extends StatefulWidget {
  const NotificacionesAdminScreen({super.key});

  @override
  State<NotificacionesAdminScreen> createState() => _NotificacionesAdminScreenState();
}

class _NotificacionesAdminScreenState extends State<NotificacionesAdminScreen> {
  final List<Map<String, dynamic>> _notificaciones = [
    {
      'id': 1,
      'titulo': '¡Nuevo Stock de Proteínas!',
      'mensaje': 'Ya llegó la nueva mercancía de Whey Gold Standard y Smart Gainer.',
      'tipo': 'stock',
      'destino': 'Todos los clientes',
      'fecha': '06 Oct 2026',
    },
    {
      'id': 2,
      'titulo': 'Mantenimiento de Maquinaria',
      'mensaje': 'El área de peso libre estará cerrada mañana en la mañana por mantenimiento.',
      'tipo': 'evento',
      'destino': 'Todos los clientes',
      'fecha': '05 Oct 2026',
    },
  ];

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
                    child: _notificaciones.isEmpty
                        ? Center(
                            child: Text(
                              'No hay notificaciones creadas',
                              style: EstiloTexto.hintTexto,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _notificaciones.length,
                            itemBuilder: (context, index) {
                              final noti = _notificaciones[index];
                              return TarjetaNotificacionAdmin(
                                noti: noti,
                                onDelete: () {
                                  setState(() {
                                    _notificaciones.removeAt(index);
                                  });
                                },
                              );
                            },
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
          onCrear: (nuevaNoti) {
            setState(() {
              _notificaciones.insert(0, nuevaNoti);
            });
          },
        );
      },
    );
  }
}