import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';

class DetallePlanSemanalScreen extends StatelessWidget {
  final Map<String, dynamic> planData;

  const DetallePlanSemanalScreen({super.key, required this.planData});

  @override
  Widget build(BuildContext context) {
    final String nombrePlan = planData['nombre_plan'] ?? 'Sin nombre';
    final String fechaInicio = planData['fecha'] ?? 'No especificada';
    final Map<String, dynamic> estructura = planData['estructura_semanal'] ?? {};

    final diasActivos = estructura.entries.where((entry) {
      final datosDia = entry.value as Map<String, dynamic>;
      final ejercicios = datosDia['ejercicios'] as List;
      final nombreRutina = datosDia['nombre_rutina'] as String;
      return ejercicios.isNotEmpty || nombreRutina.trim().isNotEmpty;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoNegro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('RESUMEN DEL PLAN', style: EstiloTexto.tekoTituloSeccion),
      ),
      body: FondoApp(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera General del Plan
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
                        nombrePlan.toUpperCase(),
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
                          Text('Fecha de inicio: $fechaInicio', style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.repeat, color: Colors.grey, size: 14),
                          const SizedBox(width: 6),
                          const Text('Tipo: Plan Semanal', style: TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'DISTRIBUCIÓN SEMANAL',
                  style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 18, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),

                if (diasActivos.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('No hay días configurados en este plan.', style: TextStyle(fontFamily: 'Roboto', color: Colors.grey, fontSize: 13)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: diasActivos.length,
                    itemBuilder: (context, index) {
                      final diaKey = diasActivos[index].key;
                      final datosDia = diasActivos[index].value as Map<String, dynamic>;
                      final nombreRutinaDia = datosDia['nombre_rutina'] ?? 'Rutina sin nombre';
                      final ejerciciosDia = datosDia['ejercicios'] as List;

                      const nombresCompletos = {
                        'L': 'LUNES', 'M': 'MARTES', 'Mi': 'MIÉRCOLES',
                        'J': 'JUEVES', 'V': 'VIERNES', 'S': 'SÁBADO', 'D': 'DOMINGO'
                      };

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.grisOscuro.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado del Día
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  nombresCompletos[diaKey] ?? diaKey,
                                  style: const TextStyle(fontFamily: 'Teko', fontSize: 18, color: AppColors.verdePrimario, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.verdePrimario.withOpacity(0.5)),
                                  ),
                                  child: Text('${ejerciciosDia.length} ejercicios', style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white70, fontSize: 11)),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 10),

                            Text(
                              nombreRutinaDia.toUpperCase(),
                              style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 10),

                            // Desglose detallado de cada ejercicio del día
                            ...ejerciciosDia.asMap().entries.map((entry) {
                              final int eIndex = entry.key;
                              final ej = entry.value;
                              final series = ej['series'] as List? ?? [];
                              final int descansoFinal = ej['descanso_final'] ?? 60;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${eIndex + 1}. ${ej['title']}',
                                      style: const TextStyle(fontFamily: 'Teko', fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    if (ej['category'] != null)
                                      Text('Categoría: ${ej['category']}', style: const TextStyle(fontFamily: 'Roboto', color: AppColors.verdePrimario, fontSize: 10)),
                                    const SizedBox(height: 6),

                                    ...series.asMap().entries.map((sEntry) {
                                      final int sIndex = sEntry.key;
                                      final s = sEntry.value;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Serie ${sIndex + 1}', style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white70, fontSize: 11)),
                                            Text('${s['repeticiones']} reps  |  ${s['peso']} kg', style: const TextStyle(fontFamily: 'RobotoCondensed', color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 11)),
                                          ],
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Descanso series: ${series.isNotEmpty ? (series[0]['descanso_entre_series'] ?? 30) : 30}s', style: const TextStyle(fontFamily: 'Roboto', color: Colors.grey, fontSize: 10)),
                                        Text('Descanso final: ${descansoFinal}s', style: const TextStyle(fontFamily: 'Roboto', color: Colors.grey, fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 40,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}