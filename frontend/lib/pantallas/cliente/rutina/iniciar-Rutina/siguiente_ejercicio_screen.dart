import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class SiguienteEjercicioScreen extends StatelessWidget {
  final String nombreEjercicio;
  final int totalSeries;
  final int reps;
  final dynamic peso;
  final String tiempoTotalRutina;
  final VoidCallback onEmpezar;

  const SiguienteEjercicioScreen({
    super.key,
    required this.nombreEjercicio,
    required this.totalSeries,
    required this.reps,
    required this.peso,
    required this.tiempoTotalRutina,
    required this.onEmpezar,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      body: SafeArea(
        child: Column(
          children: [
            // Header Imagen 9.png
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.42,
                  child: Image.asset(
                    'assets/images/9.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (c, e, s) => Container(color: AppColors.grisOscuro),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.fondoNegro],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 18),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('¡SIGUIENTE EJERCICIO!', style: TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(nombreEjercicio.toUpperCase(), style: const TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontSize: 30, fontWeight: FontWeight.bold, height: 1.1)),
                        const SizedBox(height: 2),
                        const Text('Prepárate para la siguiente serie.', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),

                    // Ficha de Series
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(color: AppColors.grisOscuro, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildItem(Icons.fitness_center_rounded, 'Series', '1/$totalSeries'),
                          _buildItem(Icons.loop_rounded, 'Reps:', '$reps'),
                          _buildItem(Icons.scale_rounded, 'Peso:', '$peso Kg'),
                        ],
                      ),
                    ),

                    // Tiempo de Rutina
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: AppColors.grisOscuro, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tiempo total de rutina', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(tiempoTotalRutina, style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.verdePrimario, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: onEmpezar,
                        child: const Text('EMPEZAR EJERCICIO', style: TextStyle(fontFamily: 'Oswald', color: AppColors.fondoNegro, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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