import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  // Lista simulada de historial adaptada a la estructura de tu backend Supabase/Node.js
  List<Map<String, dynamic>> _historial = [
    {
      'id_historial': 1,
      'nombre_rutina': 'RUTINA DE HIPERTROFIA',
      'fecha': '19/10/2026',
      'tiempo_total_min': 45,
      'ejercicios': [
        {'nombre': 'Dominadas', 'tiempo_min': 12},
        {'nombre': 'Remo con Barra', 'tiempo_min': 18},
        {'nombre': 'Curl de Bíceps', 'tiempo_min': 15},
      ]
    },
    {
      'id_historial': 2,
      'nombre_rutina': 'RUTINA EXPRESS FULL BODY',
      'fecha': '17/10/2026',
      'tiempo_total_min': 30,
      'ejercicios': [
        {'nombre': 'Sentadilla', 'tiempo_min': 15},
        {'nombre': 'Press de Banca', 'tiempo_min': 15},
      ]
    },
  ];

  // Formateador de minutos a texto legible
  String _formatearTiempo(int minutosTotales) {
    int horas = minutosTotales ~/ 60;
    int mins = minutosTotales % 60;
    if (horas > 0) {
      return '${horas}h ${mins}m';
    }
    return '${mins} min';
  }

  // Confirmar y eliminar un registro individual (borrarHistorialPorId)
  void _confirmarEliminarUnico(int idHistorial, String nombreRutina) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '¿ELIMINAR REGISTRO?',
          style: TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 18),
        ),
        content: Text(
          '¿Estás seguro de eliminar el registro de "$nombreRutina" del historial?',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _historial.removeWhere((item) => item['id_historial'] == idHistorial);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registro eliminado del historial'),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Confirmar y vaciar todo el historial (borrarTodoElHistorial)
  void _confirmarVaciarHistorial() {
    if (_historial.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '¿VACIAR TODO EL HISTORIAL?',
          style: TextStyle(fontFamily: 'Oswald', color: Colors.redAccent, fontSize: 18),
        ),
        content: const Text(
          'Esta acción borrará permanentemente todas las rutinas completadas que tienes guardadas.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _historial.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se ha vaciado todo el historial'),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('VACIAR TODO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
        title: Text(
          'HISTORIAL DE RUTINAS',
          style: EstiloTexto.tekoTituloSeccion.copyWith(fontSize: 18),
        ),
        actions: [
          if (_historial.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
              tooltip: 'Vaciar Historial',
              onPressed: _confirmarVaciarHistorial,
            ),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _historial.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off_rounded, size: 64, color: AppColors.verdePrimario.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        const Text(
                          'No tienes entrenamientos registrados.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Completa una rutina para ver tu progreso aquí.',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _historial.length,
                    itemBuilder: (context, index) {
                      final item = _historial[index];
                      final List<dynamic> ejercicios = item['ejercicios'] ?? [];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.grisOscuro.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.verdePrimario.withOpacity(0.25)),
                        ),
                        child: ExpansionTile(
                          iconColor: AppColors.verdePrimario,
                          collapsedIconColor: Colors.grey,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.verdePrimario.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.verdePrimario, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (item['nombre_rutina'] ?? 'ENTRENAMIENTO').toString().toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: 'Oswald',
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item['fecha']} • ${_formatearTiempo(item['tiempo_total_min'] ?? 0)}',
                                      style: const TextStyle(color: AppColors.verdePrimario, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              // Botón individual de papelera
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 20),
                                onPressed: () => _confirmarEliminarUnico(
                                  item['id_historial'],
                                  item['nombre_rutina'] ?? 'Rutina',
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: const BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'EJERCICIOS COMPLETADOS:',
                                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...ejercicios.map((ej) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '• ${ej['nombre']}',
                                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                                          ),
                                          Text(
                                            '${ej['tiempo_min']} min',
                                            style: const TextStyle(color: AppColors.verdePrimario, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}