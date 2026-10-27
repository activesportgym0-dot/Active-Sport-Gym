
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/pantallas/cliente/burbuja_mensaje_chat.dart';

class BurbujaMiniChatModal extends StatefulWidget {
  const BurbujaMiniChatModal({super.key});

  @override
  State<BurbujaMiniChatModal> createState() =>
      _BurbujaMiniChatModalState();
}

class _BurbujaMiniChatModalState
    extends State<BurbujaMiniChatModal> {
  static const double _tamanoBurbuja = 56;
  static const double _margen = 10;

  double _posicionX = 16;
  double _posicionY = 100;

  bool _chatAbierto = false;

  final TextEditingController _mensajeController =
      TextEditingController();

  final List<Map<String, dynamic>> _mensajes = [
    {
      'texto': '¡Hola! ¿En qué te puedo ayudar sobre esta pantalla?',
      'hora': '10:30 AM',
      'esUsuario': false,
    },
    {
      'texto': 'Quiero una rutina rápida',
      'hora': '10:30 AM',
      'esUsuario': true,
    },
  ];

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

  void _enviarMensaje() {
    final texto = _mensajeController.text.trim();

    if (texto.isEmpty) return;

    setState(() {
      _mensajes.add({
        'texto': texto,
        'hora': TimeOfDay.now().format(context),
        'esUsuario': true,
      });

      _mensajeController.clear();
    });

    // Solo se agrega el mensaje a la interfaz.
    // Las respuestas reales de la IA se conectarán después.
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final alto = constraints.maxHeight;

        const anchoChat = 320.0;
        const altoChat = 390.0;

        final maxX =
            (ancho - _tamanoBurbuja - _margen)
                .clamp(_margen, ancho)
                .toDouble();

        final maxY =
            (alto - _tamanoBurbuja - _margen)
                .clamp(_margen, alto)
                .toDouble();

        _posicionX = _posicionX.clamp(_margen, maxX).toDouble();
        _posicionY = _posicionY.clamp(_margen, maxY).toDouble();

        final anchoVentana = ancho < anchoChat + 2 * _margen
            ? ancho - 2 * _margen
            : anchoChat;

        final altoVentana = alto < altoChat + 2 * _margen
            ? alto - 2 * _margen
            : altoChat;

        // La burbuja usa distancias desde la derecha y desde abajo.
        // La ventana se coloca cerca de ella y dentro de la pantalla.
        final izquierdaBurbuja = ancho - _posicionX - _tamanoBurbuja;
        final arribaBurbuja = alto - _posicionY - _tamanoBurbuja;

        final izquierdaChat = (izquierdaBurbuja + _tamanoBurbuja -
                anchoVentana)
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
                      border: Border.all(
                        color: AppColors.verdePrimario,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.verdePrimario
                              .withOpacity(0.16),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Encabezado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          color: AppColors.grisOscuro,
                          child: Row(
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'assets/images/ia.png',
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ASISTENTE IA',
                                  style: EstiloTexto
                                      .tekoSubtituloSeccion
                                      .copyWith(fontSize: 17),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Ocultar chat',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                onPressed: _alternarChat,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Conversación
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: _mensajes.length,
                            itemBuilder: (context, index) {
                              final mensaje = _mensajes[index];

                              return BurbujaMensajeChat(
                                texto: mensaje['texto'] as String,
                                hora: mensaje['hora'] as String,
                                esUsuario:
                                    mensaje['esUsuario'] as bool,
                              );
                            },
                          ),
                        ),

                        // Campo de mensaje
                        Container(
                          padding: const EdgeInsets.fromLTRB(
                            8, 8, 8, 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.verdePrimario
                                    .withOpacity(0.3),
                              ),
                            ),
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
                                    textInputAction:
                                        TextInputAction.send,
                                    onSubmitted: (_) =>
                                        _enviarMensaje(),
                                    style: const TextStyle(
                                      fontFamily: 'RobotoCondensed',
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Escribe tu mensaje...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey
                                            .withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.grisOscuro,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  tooltip: 'Enviar mensaje',
                                  onPressed: _enviarMensaje,
                                  icon: const Icon(
                                    Icons.send,
                                    color: AppColors.verdePrimario,
                                    size: 21,
                                  ),
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

            // Burbuja flotante que se puede arrastrar
            Positioned(
              right: _posicionX,
              bottom: _posicionY,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _posicionX = (_posicionX - details.delta.dx)
                        .clamp(_margen, maxX)
                        .toDouble();

                    _posicionY = (_posicionY - details.delta.dy)
                        .clamp(_margen, maxY)
                        .toDouble();
                  });
                },
                onTap: _alternarChat,
                child: Container(
                  width: _tamanoBurbuja,
                  height: _tamanoBurbuja,
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.verdePrimario,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.verdePrimario
                            .withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/ia.png',
                      fit: BoxFit.cover,
                    ),
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
