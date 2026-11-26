
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:frontend/core/colores.dart';

/// Pantalla de descanso del entrenamiento.
/// Permite agregar 11 segundos adicionales durante el descanso.
/// La alerta sonora se reproduce cuando quedan 11 segundos.
class DescansoPantalla extends StatefulWidget {
  final int segundosDescanso;
  final bool esEntreEjercicios;
  final int serieActual;
  final int totalSeries;
  final String nombreSiguiente;
  final ValueListenable<String> tiempoTotalRutina;
  final VoidCallback onTerminar;

  const DescansoPantalla({
    super.key,
    required this.segundosDescanso,
    required this.esEntreEjercicios,
    required this.serieActual,
    required this.totalSeries,
    required this.nombreSiguiente,
    required this.tiempoTotalRutina,
    required this.onTerminar,
  });

  @override
  State<DescansoPantalla> createState() => _DescansoPantallaState();
}

class _DescansoPantallaState extends State<DescansoPantalla> {
  late int _tiempoRestante;
  late int _tiempoTotalInicial;

  Timer? _timer;

  final AudioPlayer _reproductor = AudioPlayer();

  bool _terminado = false;

  // Evita que la alerta se repita cada segundo.
  // Se reinicia cuando el usuario agrega 11 segundos.
  bool _alertaActivada = false;

  // Evita agregar tiempo varias veces mientras se detiene el audio.
  bool _procesandoExtension = false;

  static const int _segundosAdicionales = 11;
  static const int _segundosAlerta = 11;

  @override
  void initState() {
    super.initState();

    _tiempoRestante =
        widget.segundosDescanso > 0 ? widget.segundosDescanso : 30;

    _tiempoTotalInicial = _tiempoRestante;

    _iniciarTemporizador();

    // Si el descanso comienza con 11 segundos o menos,
    // activa inmediatamente la alerta.
    if (_tiempoRestante <= _segundosAlerta) {
      unawaited(_reproducirAlerta());
    }
  }

  /// Inicia el conteo regresivo.
  void _iniciarTemporizador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _terminado) {
        timer.cancel();
        return;
      }

      if (_tiempoRestante > 1) {
        setState(() {
          _tiempoRestante--;
        });

        // Cuando quedan 11 segundos comienza la alerta.
        if (_tiempoRestante <= _segundosAlerta &&
            !_alertaActivada &&
            !_procesandoExtension) {
          unawaited(_reproducirAlerta());
        }
      } else {
        _terminar();
      }
    });
  }

  /// Reproduce el audio completo de alerta.
  Future<void> _reproducirAlerta() async {
    if (_terminado || _alertaActivada) return;

    _alertaActivada = true;

    try {
      await _reproductor.stop();

      if (_terminado) return;

      await _reproductor.setVolume(1.0);

      await _reproductor.play(
        AssetSource('audios/alerta_descanso.mp3'),
      );
    } catch (e) {
      debugPrint('Error al reproducir la alerta: $e');
    }
  }

  /// Agrega 11 segundos al descanso.
  Future<void> _agregarTiempo() async {
    if (_terminado || _procesandoExtension) return;

    _procesandoExtension = true;

    try {
      // Detiene el audio actual para comenzar un nuevo ciclo.
      await _reproductor.stop();

      if (!mounted || _terminado) return;

      setState(() {
        _tiempoRestante += _segundosAdicionales;
        _tiempoTotalInicial += _segundosAdicionales;

        // Permite que la alerta vuelva a sonar
        // cuando queden nuevamente 11 segundos.
        _alertaActivada = false;
      });
    } catch (e) {
      debugPrint('Error al agregar tiempo: $e');
    } finally {
      _procesandoExtension = false;
    }
  }

  /// Finaliza el descanso y continúa el entrenamiento.
  void _terminar() {
    if (_terminado) return;

    _terminado = true;

    _timer?.cancel();

    unawaited(_reproductor.stop());

    if (mounted) {
      widget.onTerminar();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    unawaited(_reproductor.dispose());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progreso =
        (_tiempoRestante / _tiempoTotalInicial).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.verdePrimario,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'DESCANSO',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              Text(
                widget.esEntreEjercicios
                    ? 'Descanso final de ejercicio'
                    : 'Serie ${widget.serieActual} de ${widget.totalSeries}',
                style: const TextStyle(
                  color: AppColors.verdePrimario,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Siguiente: ${widget.nombreSiguiente}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 14),

              // Tiempo total de la rutina.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grisOscuro,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tiempo total de rutina',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    ValueListenableBuilder<String>(
                      valueListenable: widget.tiempoTotalRutina,
                      builder: (context, tiempo, _) {
                        return Text(
                          tiempo,
                          style: const TextStyle(
                            color: AppColors.verdePrimario,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reloj circular de descanso.
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.verdePrimario.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: progreso,
                                strokeWidth: 12,
                                backgroundColor: Colors.white12,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  AppColors.verdePrimario,
                                ),
                              ),
                            ),

                            Text(
                              '$_tiempoRestante',
                              style: const TextStyle(
                                fontFamily: 'Oswald',
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Respira...',
                        style: TextStyle(
                          fontFamily: 'Oswald',
                          color: AppColors.verdePrimario,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        widget.esEntreEjercicios
                            ? 'Prepárate para el siguiente ejercicio.'
                            : 'Prepárate para la siguiente serie.',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botón para agregar 11 segundos.
                      SizedBox(
                        width: 190,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: _terminado || _procesandoExtension
                              ? null
                              : _agregarTiempo,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            size: 20,
                          ),
                          label: const Text(
                            '+11 SEGUNDOS',
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.verdePrimario,
                            side: const BorderSide(
                              color: AppColors.verdePrimario,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tiempo total de rutina.
              ValueListenableBuilder<String>(
                valueListenable: widget.tiempoTotalRutina,
                builder: (context, tiempo, _) {
                  return Text(
                    tiempo,
                    style: const TextStyle(
                      fontFamily: 'Oswald',
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),

              Container(
                width: 80,
                height: 3,
                color: AppColors.verdePrimario,
              ),

              const SizedBox(height: 16),

              // Finalizar descanso.
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrimario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _terminar,
                  child: Text(
                    widget.esEntreEjercicios
                        ? 'SIGUIENTE EJERCICIO'
                        : 'SIGUIENTE SERIE',
                    style: const TextStyle(
                      fontFamily: 'Oswald',
                      color: AppColors.fondoNegro,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
