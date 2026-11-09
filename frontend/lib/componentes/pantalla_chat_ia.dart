import "package:flutter/material.dart";
import "package:frontend/core/colores.dart";
import "package:frontend/core/estilotexto.dart";
import "package:frontend/componentes/fondo.dart";
import "package:frontend/pantallas/burbuja_mensaje_chat.dart";
import "package:frontend/services/chat_conversacion.dart";

/// Pantalla completa del asistente IA. La usan el cliente y el administrador
/// (solo cambia [esAdmin]). Comparte la misma conversación que la burbuja flotante:
/// lo que se escribe en una se ve en la otra mientras la sesión esté iniciada.
class PantallaChatIA extends StatefulWidget {
  final bool esAdmin;

  const PantallaChatIA({super.key, required this.esAdmin});

  @override
  State<PantallaChatIA> createState() => _PantallaChatIAState();
}

class _PantallaChatIAState extends State<PantallaChatIA> {
  late final ConversacionChat _conversacion;
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<Map<String, dynamic>> _temasCliente = [
    {"titulo": "Rutinas de entrenamiento", "icono": Icons.fitness_center},
    {"titulo": "Nutrición y alimentación", "icono": Icons.restaurant_menu},
    {"titulo": "Suplementos", "icono": Icons.bolt},
    {"titulo": "Pérdida de grasa", "icono": Icons.local_fire_department},
    {"titulo": "Ganancia muscular", "icono": Icons.sports_gymnastics},
    {"titulo": "Consejos de bienestar", "icono": Icons.lightbulb},
    {"titulo": "Hidratación", "icono": Icons.water_drop},
  ];

  static const List<Map<String, dynamic>> _temasAdmin = [
    {"titulo": "Métricas y totales del sistema", "icono": Icons.analytics},
    {"titulo": "Alertas de stock crítico", "icono": Icons.warning_amber},
    {"titulo": "Inventario de la tienda", "icono": Icons.inventory_2},
    {"titulo": "Estadísticas de membresías", "icono": Icons.card_membership},
    {"titulo": "Control de rutinas y usuarios", "icono": Icons.group},
    {"titulo": "Reglas y horarios activos", "icono": Icons.access_time},
  ];

  // ───────────── Textos según el rol ─────────────
  List<Map<String, dynamic>> get _temas => widget.esAdmin ? _temasAdmin : _temasCliente;
  String get _tituloAppBar => widget.esAdmin ? "ASISTENTE GERENCIAL IA" : "ASISTENTE IA VIRTUAL";
  String get _saludoTitulo => widget.esAdmin ? "¡Panel de Administración!" : "¡Hola, atleta!";
  String get _saludoTexto => widget.esAdmin
      ? "Consulta las métricas, el stock y la gestión del gimnasio. ¿Qué deseas revisar?"
      : "Puedo orientarte sobre entrenamiento, nutrición y bienestar. ¿Qué te gustaría consultar?";
  String get _hint => widget.esAdmin ? "Consulta gerencial para la IA..." : "Escribe tu consulta...";
  String get _prefijoTema => widget.esAdmin ? "Necesito información sobre: " : "Quiero información sobre: ";

  @override
  void initState() {
    super.initState();
    // Misma conversación que la burbuja flotante
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

  void _enviar([String? texto]) {
    final limpio = (texto ?? _mensajeController.text).trim();
    if (limpio.isEmpty || _conversacion.cargando) return;
    _mensajeController.clear();
    _conversacion.enviar(limpio);
  }

  // ───────────── Piezas ─────────────

  Widget _tarjetaBienvenida() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.grisOscuro, Color(0xFF141F0C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.verdePrimario.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.verdePrimario.withOpacity(0.15), blurRadius: 14, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.verdePrimario, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.verdePrimario.withOpacity(0.35), blurRadius: 12),
                  ],
                ),
                child: ClipOval(child: Image.asset("assets/images/ia.png", fit: BoxFit.cover)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _saludoTitulo,
                      style: const TextStyle(
                        fontFamily: "Teko",
                        fontSize: 25,
                        height: 1.0,
                        color: AppColors.verdePrimario,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _saludoTexto,
                      style: const TextStyle(fontFamily: "Roboto", color: Colors.white70, fontSize: 12.5, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!widget.esAdmin) ...[
            const SizedBox(height: 12),
            Text(
              "Mis respuestas son orientativas y no reemplazan a un médico o nutricionista.",
              style: TextStyle(color: Colors.grey.withOpacity(0.85), fontSize: 10.5, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tituloTemas() {
    return Row(
      children: [
        Icon(widget.esAdmin ? Icons.admin_panel_settings : Icons.bolt, color: AppColors.verdePrimario, size: 18),
        const SizedBox(width: 6),
        Text(
          widget.esAdmin ? "ACCESOS DIRECTOS" : "TEMAS DE CONSULTA",
          style: const TextStyle(
            fontFamily: "Teko",
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _cuadriculaTemas() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _temas.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 54,
      ),
      itemBuilder: (context, index) {
        final tema = _temas[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _enviar("$_prefijoTema${tema["titulo"]}"),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.grisOscuro.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.verdePrimario.withOpacity(0.28)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.verdePrimario.withOpacity(0.12),
                  ),
                  child: Icon(tema["icono"] as IconData, color: AppColors.verdePrimario, size: 17),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tema["titulo"] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: "RobotoCondensed",
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _zonaDeMensajes() {
    final mensajes = _conversacion.mensajes;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      children: [
        // Siempre visibles: la bienvenida y los temas sugeridos (se pueden tocar cuando quieras)
        _tarjetaBienvenida(),
        const SizedBox(height: 20),
        _tituloTemas(),
        const SizedBox(height: 10),
        _cuadriculaTemas(),
        if (mensajes.isNotEmpty || _conversacion.cargando) ...[
          const SizedBox(height: 18),
          _separadorConversacion(),
          const SizedBox(height: 6),
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
            texto: "Escribiendo...",
            hora: "",
            esUsuario: false,
            esAdmin: widget.esAdmin,
          ),
      ],
    );
  }

  Widget _separadorConversacion() {
    return Row(
      children: [
        const Icon(Icons.chat_bubble_outline, color: AppColors.verdePrimario, size: 16),
        const SizedBox(width: 6),
        const Text(
          "CONVERSACIÓN",
          style: TextStyle(
            fontFamily: "Teko",
            color: Colors.white,
            fontSize: 17,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: AppColors.verdePrimario.withOpacity(0.3))),
      ],
    );
  }

  Widget _barraDeEnvio() {
    final cargando = _conversacion.cargando;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
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
                maxLines: 4,
                maxLength: 500,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _enviar(),
                style: const TextStyle(fontFamily: "RobotoCondensed", color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: _hint,
                  hintStyle: TextStyle(fontFamily: "RobotoCondensed", color: Colors.grey.withOpacity(0.6)),
                  filled: true,
                  fillColor: AppColors.grisOscuro,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide(color: AppColors.verdePrimario.withOpacity(0.35)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide(color: AppColors.verdePrimario.withOpacity(0.35)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: const BorderSide(color: AppColors.verdePrimario, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Opacity(
              opacity: cargando ? 0.5 : 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.verdePrimario,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.verdePrimario.withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.black, size: 22),
                  onPressed: cargando ? null : () => _enviar(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────── Pantalla ─────────────
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
        title: Text(_tituloAppBar, style: EstiloTexto.tekoTituloSeccion),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.verdePrimario, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset("assets/images/ia.png", width: 34, height: 34, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
      body: FondoApp(
        child: Column(
          children: [
            Expanded(child: _zonaDeMensajes()),
            _barraDeEnvio(),
          ],
        ),
      ),
    );
  }
}
