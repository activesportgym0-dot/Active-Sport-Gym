import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/pantallas/burbuja_mensaje_chat.dart';
import 'package:frontend/services/auth_service.dart'; // SessionService
import 'package:frontend/services/chat_conversacion.dart';

/// Burbuja flotante del asistente IA (se puede arrastrar).
/// Al tocarla abre el chat como una ventana modal: mientras está abierta no se puede
/// usar el resto de la pantalla; al tocar afuera (o la X, o "atrás") se cierra.
///
/// [esAdmin] es opcional: si no se indica, se detecta solo según el rol de la sesión,
/// así un administrador siempre habla con el asistente gerencial y un cliente con el suyo.
class BurbujaChatIA extends StatefulWidget {
  final bool? esAdmin;

  const BurbujaChatIA({super.key, this.esAdmin});

  @override
  State<BurbujaChatIA> createState() => _BurbujaChatIAState();
}

class _BurbujaChatIAState extends State<BurbujaChatIA> {
  static const double _tamanoBurbuja = 56;
  static const double _margen = 10;

  // static: la burbuja conserva su posición al pasar de una pantalla a otra
  static double _posicionX = 16;
  static double _posicionY = 100;

  bool get _esAdmin => widget.esAdmin ?? SessionService.rol == 'admin';

  void _abrirChat() {
    final esAdmin = _esAdmin;
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // tocar afuera cierra el chat
      barrierLabel: 'Cerrar asistente',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, _, __) => VentanaChatIA(esAdmin: esAdmin),
      transitionBuilder: (context, animation, _, child) {
        final curva = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curva,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1).animate(curva),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final alto = constraints.maxHeight;
        final maxX = (ancho - _tamanoBurbuja - _margen).clamp(_margen, ancho).toDouble();
        final maxY = (alto - _tamanoBurbuja - _margen).clamp(_margen, alto).toDouble();
        _posicionX = _posicionX.clamp(_margen, maxX).toDouble();
        _posicionY = _posicionY.clamp(_margen, maxY).toDouble();

        return Stack(
          children: [
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
                onTap: _abrirChat,
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

/// Ventana del chat (se muestra como diálogo modal sobre la pantalla).
class VentanaChatIA extends StatefulWidget {
  final bool esAdmin;

  const VentanaChatIA({super.key, required this.esAdmin});

  @override
  State<VentanaChatIA> createState() => _VentanaChatIAState();
}

class _VentanaChatIAState extends State<VentanaChatIA> {
  late final ConversacionChat _conversacion;
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // La conversación vive fuera de la ventana: no se pierde al cerrarla ni al cambiar de pantalla
    _conversacion = ChatSessionStore.obtener(esAdmin: widget.esAdmin);
    _conversacion.addListener(_alCambiarConversacion);
    _irAlFinal(animar: false);
  }

  @override
  void dispose() {
    _conversacion.removeListener(_alCambiarConversacion);
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ───────────── Textos según el rol ─────────────
  String get _titulo => widget.esAdmin ? 'IA GERENCIAL' : 'ASISTENTE IA';
  String get _subtitulo => widget.esAdmin ? 'Asistente del administrador' : 'Active Sport Gym';
  String get _hint => widget.esAdmin ? 'Pregunta administrativa...' : 'Escribe tu mensaje...';

  String get _saludo => widget.esAdmin
      ? '¡Hola! Soy tu asistente gerencial. Puedo ayudarte a interpretar las métricas del gimnasio, revisar el stock y organizar ideas de gestión.'
      : '¡Hola! Soy el asistente virtual de Active Sport Gym. Pregúntame por rutinas, nutrición, suplementos o la tienda.';

  List<String> get _sugerencias => widget.esAdmin
      ? ['Resumen del gimnasio', 'Productos con stock bajo', 'Ideas para motivar a los socios']
      : ['Rutina para hoy', '¿Qué suplementos hay?', 'Horarios del gimnasio'];

  // ───────────── Acciones ─────────────
  void _alCambiarConversacion() {
    if (!mounted) return;
    setState(() {});
    _irAlFinal();
  }

  void _irAlFinal({bool animar = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final fin = _scrollController.position.maxScrollExtent;
      if (animar) {
        _scrollController.animateTo(fin, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      } else {
        _scrollController.jumpTo(fin);
      }
    });
  }

  void _enviar([String? textoRapido]) {
    final texto = (textoRapido ?? _mensajeController.text).trim();
    if (texto.isEmpty || _conversacion.cargando) return;
    _mensajeController.clear();
    _conversacion.enviar(texto);
  }

  // ───────────── Piezas ─────────────
  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro.withOpacity(0.55),
        border: Border(bottom: BorderSide(color: AppColors.verdePrimario.withOpacity(0.25))),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.verdePrimario, width: 1.5),
            ),
            child: ClipOval(child: Image.asset('assets/images/ia.png', fit: BoxFit.cover)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_titulo, style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16, height: 1.0)),
                const SizedBox(height: 2),
                Text(_subtitulo, style: TextStyle(color: Colors.grey.withOpacity(0.9), fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _mensajes() {
    final mensajes = _conversacion.mensajes;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      children: [
        // Bienvenida y preguntas rápidas: solo mientras no haya mensajes
        if (mensajes.isEmpty) ...[
          BurbujaMensajeChat(
            texto: _saludo,
            hora: TimeOfDay.now().format(context),
            esUsuario: false,
            esAdmin: widget.esAdmin,
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _sugerencias
                .map(
                  (s) => InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _enviar(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.verdePrimario.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.verdePrimario.withOpacity(0.5)),
                      ),
                      child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 11.5)),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        for (final m in mensajes)
          BurbujaMensajeChat(
            texto: m.texto,
            hora: TimeOfDay.fromDateTime(m.fecha).format(context),
            esUsuario: m.esUsuario,
            esAdmin: widget.esAdmin,
            esError: m.esError,
          ),
        if (_conversacion.cargando)
          BurbujaMensajeChat(
            texto: 'Escribiendo...',
            hora: '',
            esUsuario: false,
            esAdmin: widget.esAdmin,
          ),
      ],
    );
  }

  Widget _barraDeEnvio() {
    final cargando = _conversacion.cargando;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        border: Border(top: BorderSide(color: AppColors.verdePrimario.withOpacity(0.25))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _mensajeController,
              minLines: 1,
              maxLines: 3,
              maxLength: 500,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _enviar(),
              style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                counterText: '',
                hintText: _hint,
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
                filled: true,
                fillColor: AppColors.grisOscuro.withOpacity(0.7),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Opacity(
            opacity: cargando ? 0.5 : 1,
            child: Material(
              color: AppColors.verdePrimario,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: cargando ? null : () => _enviar(),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.send_rounded, color: AppColors.fondoNegro, size: 19),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ventana() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.verdePrimario.withOpacity(0.18), blurRadius: 20, spreadRadius: 1),
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // Cristal: el fondo se ve difuminado y semitransparente
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.fondoNegro.withOpacity(0.82),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.verdePrimario.withOpacity(0.75), width: 1.2),
            ),
            child: Column(
              children: [
                _encabezado(),
                Expanded(child: _mensajes()),
                _barraDeEnvio(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final teclado = mq.viewInsets.bottom;
    final altoDisponible = mq.size.height - teclado - mq.padding.top - mq.padding.bottom;

    // Tamaño proporcional a la pantalla: en un celular pequeño no la tapa toda
    // y siempre queda un margen alrededor.
    final ancho = math.min(320.0, mq.size.width - 56);
    final altoBase = (mq.size.height * 0.55).clamp(280.0, 400.0).toDouble();
    final alto = math.min(altoBase, altoDisponible - 32);

    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: SafeArea(
        child: Center(
          child: SizedBox(
            width: ancho,
            height: alto,
            child: Material(
              color: Colors.transparent,
              child: _ventana(),
            ),
          ),
        ),
      ),
    );
  }
}
