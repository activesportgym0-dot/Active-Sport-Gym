import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/pantallas/burbuja_mensaje_chat.dart';
import 'package:frontend/services/chat_service.dart';

class BurbujaMiniChatAdminModal extends StatefulWidget {
  const BurbujaMiniChatAdminModal({super.key});

  @override
  State<BurbujaMiniChatAdminModal> createState() => _BurbujaMiniChatAdminModalState();
}

class _BurbujaMiniChatAdminModalState extends State<BurbujaMiniChatAdminModal> {
  static const double _tamanoBurbuja = 56;
  static const double _margen = 10;
  double _posicionX = 16;
  double _posicionY = 100;
  bool _chatAbierto = false;
  bool _cargando = false;
  String? _sesionId;

  final TextEditingController _mensajeController = TextEditingController();
  final List<Map<String, dynamic>> _mensajes = [];

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  void _alternarChat() {
    setState(() {
      _chatAbierto = !_chatAbierto;
    });
  }

  void _enviarMensajeAdminAPI() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty || _cargando) return;

    setState(() {
      _mensajes.add({
        'texto': texto,
        'hora': TimeOfDay.now().format(context),
        'esUsuario': true,
      });
      _cargando = true;
      _mensajeController.clear();
    });

    try {
      final res = await ChatService.enviarMensajeAdmin(
        mensaje: texto,
        sesionId: _sesionId,
      );

      setState(() {
        _sesionId = res.sesionId;
        _mensajes.add({
          'texto': res.respuesta,
          'hora': TimeOfDay.now().format(context),
          'esUsuario': false,
        });
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _mensajes.add({
          'texto': 'Error de conexión: $e',
          'hora': TimeOfDay.now().format(context),
          'esUsuario': false,
        });
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final alto = constraints.maxHeight;
        const anchoChat = 320.0;
        const altoChat = 390.0;
        final maxX = (ancho - _tamanoBurbuja - _margen).clamp(_margen, ancho).toDouble();
        final maxY = (alto - _tamanoBurbuja - _margen).clamp(_margen, alto).toDouble();
        _posicionX = _posicionX.clamp(_margen, maxX).toDouble();
        _posicionY = _posicionY.clamp(_margen, maxY).toDouble();
        final anchoVentana = ancho < anchoChat + 2 * _margen ? ancho - 2 * _margen : anchoChat;
        final altoVentana = alto < altoChat + 2 * _margen ? alto - 2 * _margen : altoChat;

        final izquierdaBurbuja = ancho - _posicionX - _tamanoBurbuja;
        final arribaBurbuja = alto - _posicionY - _tamanoBurbuja;
        final izquierdaChat = (izquierdaBurbuja + _tamanoBurbuja - anchoVentana)
            .clamp(_margen, ancho - anchoVentana - _margen)
            .toDouble();
        final arribaChat = (arribaBurbuja - altoVentana - 12)
            .clamp(_margen, alto - altoVentana - _margen)
            .toDouble();

        return Stack(
          children: [
            if (_chatAbierto)
              Positioned(
                left: izquierdaChat,
                top: arribaChat,
                width: anchoVentana,
                height: altoVentana,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.fondoNegro,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.verdePrimario, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.verdePrimario.withOpacity(0.16),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          color: AppColors.grisOscuro,
                          child: Row(
                            children: [
                              ClipOval(
                                child: Image.asset('assets/images/ia.png', width: 30, height: 30, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('IA GERENCIAL', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 17)),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                onPressed: _alternarChat,
                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: _mensajes.length,
                            itemBuilder: (context, index) {
                              final mensaje = _mensajes[index];
                              return BurbujaMensajeChat(
                                texto: mensaje['texto'] as String,
                                hora: mensaje['hora'] as String,
                                esUsuario: mensaje['esUsuario'] as bool,
                                esAdmin: true,
                              );
                            },
                          ),
                        ),
                        if (_cargando)
                          const LinearProgressIndicator(color: AppColors.verdePrimario, backgroundColor: Colors.black),
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border(top: BorderSide(color: AppColors.verdePrimario.withOpacity(0.3))),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _mensajeController,
                                    minLines: 1,
                                    maxLines: 3,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _enviarMensajeAdminAPI(),
                                    style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white, fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText: 'Pregunta administrativa...',
                                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
                                      filled: true,
                                      fillColor: AppColors.grisOscuro,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  onPressed: _enviarMensajeAdminAPI,
                                  icon: const Icon(Icons.send, color: AppColors.verdePrimario, size: 21),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              right: _posicionX,
              bottom: _posicionY,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _posicionX = (_posicionX - details.delta.dx).clamp(_margen, maxX).toDouble();
                    _posicionY = (_posicionY - details.delta.dy).clamp(_margen, maxY).toDouble();
                  });
                },
                onTap: _alternarChat,
                child: Container(
                  width: _tamanoBurbuja,
                  height: _tamanoBurbuja,
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.verdePrimario, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.verdePrimario.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/images/ia.png', fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
