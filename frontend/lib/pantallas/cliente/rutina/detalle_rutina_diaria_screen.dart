import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';


class DetalleRutinaDiariaScreen extends StatelessWidget {
  final Map<String, dynamic> rutinaData;

  const DetalleRutinaDiariaScreen({super.key, required this.rutinaData});

  @override
  Widget build(BuildContext context) {
    final String nombreRutina = rutinaData['nombre_rutina'] ?? 'Sin nombre';
    final String fecha = rutinaData['fecha'] ?? 'No especificada';
    final List ejercicios = rutinaData['ejercicios'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('RESUMEN DE RUTINA', style: EstiloTexto.tekoTituloSeccion),
      ),
      body: FondoApp(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera General
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreRutina.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Teko',
                          fontSize: 26,
                          color: AppColors.verdePrimario,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                          const SizedBox(width: 6),
                          Text('Fecha: $fecha', style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.grey, size: 14),
                          const SizedBox(width: 6),
                          Text('Total de ejercicios: ${ejercicios.length}', style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'EJERCICIOS PROGRAMADOS',
                  style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 18, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),

                if (ejercicios.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('No hay ejercicios registrados en esta rutina.', style: TextStyle(fontFamily: 'Roboto', color: Colors.grey, fontSize: 13)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ejercicios.length,
                    itemBuilder: (context, index) {
                      final ej = ejercicios[index];
                      final series = ej['series'] as List? ?? [];
                      final int descansoFinal = ej['descanso_final'] ?? 60;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.grisOscuro.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título y Categoría
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ',
                                  style: const TextStyle(fontFamily: 'Teko', fontSize: 18, color: AppColors.verdePrimario, fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    ej['title'] ?? 'Ejercicio',
                                    style: const TextStyle(fontFamily: 'Teko', fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            if (ej['category'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2, bottom: 6),
                                child: Text(
                                  'Categoría: ${ej['category']}',
                                  style: EstiloTexto.subtituloRoboto.copyWith(fontSize: 11, color: AppColors.verdePrimario),
                                ),
                              ),
                            const Divider(color: Colors.white24, height: 12),

                            // Desglose de Series (con repeticiones y peso reales)
                            const Text(
                              'SERIES:',
                              style: TextStyle(fontFamily: 'Oswald', color: Colors.grey, fontSize: 11, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 4),
                            ...List.generate(series.length, (sIndex) {
                              final s = series[sIndex];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Serie ${sIndex + 1}',
                                      style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white70, fontSize: 12),
                                    ),
                                    Text(
                                      '${s['repeticiones']} reps  |  ${s['peso']} kg',
                                      style: const TextStyle(fontFamily: 'RobotoCondensed', color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 8),
                            const Divider(color: Colors.white12, height: 8),

                            // Descansos
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Descanso entre series: ${series.isNotEmpty ? (series[0]['descanso_entre_series'] ?? 30) : 30}s',
                                  style: const TextStyle(fontFamily: 'Roboto', color: Colors.grey, fontSize: 11),
                                ),
                                Text(
                                  'Descanso final: ${descansoFinal}s',
                                  style: const TextStyle(fontFamily: 'Roboto', color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrimario,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('VOLVER A INICIO', style: TextStyle(fontFamily: 'Oswald', fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}