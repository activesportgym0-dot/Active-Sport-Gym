import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class DescansoPantalla extends StatefulWidget {
  final int segundosDescanso;
  final bool esEntreEjercicios;
  final String nombreSiguienteEjercicio;
  final String tiempoTotalRutina;

  const DescansoPantalla({
    super.key,
    required this.segundosDescanso,
    required this.esEntreEjercicios,
    required this.nombreSiguienteEjercicio,
    required this.tiempoTotalRutina,
  });

  @override
  State<DescansoPantalla> createState() => _DescansoPantallaState();
}

class _DescansoPantallaState extends State<DescansoPantalla> {
  late int _tiempoRestante;
  late int _tiempoTotalInicial;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tiempoRestante = widget.segundosDescanso > 0 ? widget.segundosDescanso : 30;
    _tiempoTotalInicial = _tiempoRestante;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_tiempoRestante > 1) {
        if (mounted) setState(() => _tiempoRestante--);
      } else {
        _timer?.cancel();
        if (mounted) Navigator.pop(context, true); // Devuelve true al terminar
      }
    });
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
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(height: 10),
              
              Text(
                widget.esEntreEjercicios ? 'DESCANSO FINAL DE EJERCICIO' : 'DESCANSO ENTRE SERIES',
                style: const TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
              const SizedBox(height: 4),
              Text(
                'Siguiente: ${widget.nombreSiguienteEjercicio}',
                style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Tiempo Total de Rutina
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: AppColors.grisOscuro, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tiempo total de rutina', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(widget.tiempoTotalRutina, style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reloj Circular Progresivo Neón
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
                      const Text('Respira...', style: TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        widget.esEntreEjercicios ? 'Recupérate para cambiar de ejercicio.' : 'Prepárate para la siguiente serie.',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botón Omitir Descanso
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrimario,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'CONTINUAR AHORA',
                    style: TextStyle(fontFamily: 'Oswald', color: AppColors.fondoNegro, fontWeight: FontWeight.bold, fontSize: 16),
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