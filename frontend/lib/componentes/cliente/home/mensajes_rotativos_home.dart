import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Un mensaje o recomendación del home.
class MensajeHome {
  final String emoji;
  final String titulo;
  final String texto;

  const MensajeHome({required this.emoji, required this.titulo, required this.texto});
}

/// Tarjeta con recomendaciones que van cambiando solas cada pocos segundos
/// (con un desvanecimiento suave) y puntos indicadores.
/// Usa el mismo estilo de tarjeta que tenía "Rutina de hoy".
class MensajesRotativosHome extends StatefulWidget {
  final List<MensajeHome> mensajes;
  final Duration cada;

  const MensajesRotativosHome({
    super.key,
    required this.mensajes,
    this.cada = const Duration(seconds: 35),
  });

  @override
  State<MensajesRotativosHome> createState() => _MensajesRotativosHomeState();
}

class _MensajesRotativosHomeState extends State<MensajesRotativosHome> {
  Timer? _timer;
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.cada, (_) {
      if (!mounted || widget.mensajes.length < 2) return;
      setState(() => _indice = (_indice + 1) % widget.mensajes.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mensajes.isEmpty) return const SizedBox.shrink();

    final mensaje = widget.mensajes[_indice % widget.mensajes.length];

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blancoTransparente.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(_indice),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${mensaje.emoji} ', style: const TextStyle(fontSize: 16)),
                    Text(
                      mensaje.titulo,
                      style: const TextStyle(color: AppColors.blancoPuro, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  mensaje.texto,
                  style: const TextStyle(color: AppColors.grisClaro, fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(widget.mensajes.length, (i) {
              final activo = i == _indice;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(left: 4),
                width: activo ? 14 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: activo ? AppColors.verdePrimario : AppColors.grisMedio,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
