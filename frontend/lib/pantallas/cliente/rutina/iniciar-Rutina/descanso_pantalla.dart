import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Pantalla de descanso del entrenamiento (reloj circular).
/// La usa EjecucionEntrenamientoScreen: el tiempo de descanso es el que el usuario
/// escribió al crear su rutina (descanso entre series o descanso final del ejercicio).
/// Cuando el tiempo se acaba, o el usuario pulsa el botón, llama a [onTerminar].
class DescansoPantalla extends StatefulWidget {
  final int segundosDescanso;
  final bool esEntreEjercicios; // true = descanso final del ejercicio, false = entre series
  final int serieActual; // serie que se acaba de terminar
  final int totalSeries;
  final String nombreSiguiente; // "Serie 2 de 4" o el nombre del siguiente ejercicio

  /// Tiempo total de la rutina. Es un ValueListenable para que el reloj siga
  /// avanzando en esta pantalla mientras se descansa.
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
  bool _terminado = false; // evita avisar dos veces (tiempo cumplido + botón)

  @override
  void initState() {
    super.initState();
    _tiempoRestante = widget.segundosDescanso > 0 ? widget.segundosDescanso : 30;
    _tiempoTotalInicial = _tiempoRestante;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_tiempoRestante > 1) {
        if (mounted) setState(() => _tiempoRestante--);
      } else {
        _terminar();
      }
    });
  }

  void _terminar() {
    if (_terminado) return;
    _terminado = true;
    _timer?.cancel();
    if (mounted) widget.onTerminar();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progreso = _tiempoRestante / _tiempoTotalInicial;

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'DESCANSO',
                style: TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              Text(
                widget.esEntreEjercicios
                    ? 'Descanso final de ejercicio'
                    : 'Serie ${widget.serieActual} de ${widget.totalSeries}',
                style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Siguiente: ${widget.nombreSiguiente}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: AppColors.grisOscuro, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tiempo total de rutina', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ValueListenableBuilder<String>(
                      valueListenable: widget.tiempoTotalRutina,
                      builder: (context, tiempo, _) => Text(
                        tiempo,
                        style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
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
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.verdePrimario),
                              ),
                            ),
                            Text(
                              '$_tiempoRestante',
                              style: const TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Respira...',
                        style: TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.esEntreEjercicios ? 'Prepárate para el siguiente ejercicio.' : 'Prepárate para la siguiente serie.',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: widget.tiempoTotalRutina,
                builder: (context, tiempo, _) => Text(
                  tiempo,
                  style: const TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
              Container(width: 80, height: 3, color: AppColors.verdePrimario),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrimario,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _terminar,
                  child: Text(
                    widget.esEntreEjercicios ? 'SIGUIENTE EJERCICIO' : 'SIGUIENTE SERIE',
                    style: const TextStyle(fontFamily: 'Oswald', color: AppColors.fondoNegro, fontWeight: FontWeight.bold, fontSize: 16),
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