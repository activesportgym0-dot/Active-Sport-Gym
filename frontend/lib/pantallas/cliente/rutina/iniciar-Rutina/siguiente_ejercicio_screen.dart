import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Presentación del ejercicio que viene en el entrenamiento ("¡SIGUIENTE EJERCICIO!").
/// La usa EjecucionEntrenamientoScreen y recibe los datos del ejercicio que el
/// usuario armó al crear su rutina (nombre, series, repeticiones y peso).
class SiguienteEjercicioScreen extends StatelessWidget {
  final String nombreEjercicio;
  final int numeroEjercicio; // posición del ejercicio en la rutina (1, 2, 3...)
  final int totalEjercicios;
  final int serieActual; // serie que se va a hacer (1, 2, 3...)
  final int totalSeries;
  final int reps;
  final dynamic peso;

  /// Tiempo total de la rutina. Es un ValueListenable para que el reloj siga
  /// avanzando en esta pantalla mientras se muestra.
  final ValueListenable<String> tiempoTotalRutina;
  final VoidCallback onEmpezar;

  const SiguienteEjercicioScreen({
    super.key,
    required this.nombreEjercicio,
    required this.numeroEjercicio,
    required this.totalEjercicios,
    required this.totalSeries,
    required this.reps,
    required this.peso,
    required this.tiempoTotalRutina,
    required this.onEmpezar,
    this.serieActual = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: Image.asset(
                      'assets/images/9.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (c, e, s) => Container(color: AppColors.grisOscuro),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                            AppColors.fondoNegro.withOpacity(0.85),
                            AppColors.fondoNegro,
                          ],
                          stops: const [0.0, 0.4, 0.85, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    const Text(
                      '¡SIGUIENTE EJERCICIO!',
                      style: TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nombreEjercicio.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ejercicio $numeroEjercicio de $totalEjercicios',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.grisOscuro,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildItem(Icons.fitness_center_rounded, 'Series', '$serieActual/$totalSeries'),
                          _buildItem(Icons.loop_rounded, 'Reps:', '$reps'),
                          _buildItem(Icons.scale_rounded, 'Peso:', '$peso Kg'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: AppColors.grisOscuro, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tiempo total de rutina', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ValueListenableBuilder<String>(
                            valueListenable: tiempoTotalRutina,
                            builder: (context, tiempo, _) => Text(
                              tiempo,
                              style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdePrimario,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 6,
                        ),
                        onPressed: onEmpezar,
                        child: const Text(
                          'EMPEZAR EJERCICIO',
                          style: TextStyle(fontFamily: 'Oswald', color: AppColors.fondoNegro, fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 1.1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.verdePrimario, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}