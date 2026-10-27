import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/pantallas/cliente/rutina/iniciar-Rutina/detalle_rutina_screen.dart';
import 'package:frontend/pantallas/cliente/menuLateral/historial_screen.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

// Importa tus dos pantallas de detalle correspondientes
import 'package:frontend/pantallas/cliente/rutina/detalle_rutina_diaria_screen.dart'; 
import 'package:frontend/pantallas/cliente/rutina/detalle_plan_semanal_screen.dart'; // Ajusta la ruta si es necesario

class EntrenamientoScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? rutinasBackend;

  const EntrenamientoScreen({
    super.key,
    this.rutinasBackend,
  });

  @override
  State<EntrenamientoScreen> createState() => _EntrenamientoScreenState();
}

class _EntrenamientoScreenState extends State<EntrenamientoScreen> {
  int _pestanaActiva = 0; // 0 = Diarias, 1 = Semanales

  late List<Map<String, dynamic>> _rutinasDiarias;
  late List<Map<String, dynamic>> _rutinasSemanales;

  @override
  void initState() {
    super.initState();

    final todasLasRutinas = widget.rutinasBackend ?? [
      {
        'id_rutina': 1,
        'nombre_rutina': 'RUTINA EXPRESS DE BRAZO',
        'tipo': 'diaria',
        'fecha': '19/10/2026',
        'ejercicios': [
          {
            'title': 'Dominadas en Barra',
            'category': 'Espalda',
            'descanso_final': 60,
            'series': [
              {'repeticiones': 10, 'peso': 0, 'descanso_entre_series': 30},
              {'repeticiones': 10, 'peso': 5, 'descanso_entre_series': 30},
            ]
          }
        ]
      },
      {
        'id_rutina': 2,
        'nombre_plan': 'PLAN HIPERTROFIA FASE 1',
        'tipo': 'semanal',
        'fecha': '20/10/2026',
        'estructura_semanal': {
          'L': {
            'nombre_rutina': 'Espalda + Bíceps',
            'ejercicios': [
              {
                'title': 'Remo con Mancuerna',
                'category': 'Espalda',
                'descanso_final': 60,
                'series': [
                  {'repeticiones': 12, 'peso': 14, 'descanso_entre_series': 30},
                ]
              }
            ]
          },
          'Mi': {
            'nombre_rutina': 'Pecho + Tríceps',
            'ejercicios': [
              {
                'title': 'Press de Banca',
                'category': 'Pecho',
                'descanso_final': 90,
                'series': [
                  {'repeticiones': 10, 'peso': 40, 'descanso_entre_series': 45},
                ]
              }
            ]
          }
        }
      },
    ];

    _rutinasDiarias = todasLasRutinas
        .where((r) => (r['tipo'] ?? '').toString().toLowerCase() == 'diaria')
        .toList();

    _rutinasSemanales = todasLasRutinas
        .where((r) => (r['tipo'] ?? '').toString().toLowerCase() == 'semanal')
        .toList();
  }

  // 1. Abre el Detalle de Rutina Diaria
  void _verDetalleDiario(Map<String, dynamic> rutinaData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleRutinaDiariaScreen(rutinaData: rutinaData),
      ),
    );
  }

  // 2. Abre el Detalle del Plan Semanal
  void _verDetalleSemanal(Map<String, dynamic> planData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallePlanSemanalScreen(planData: planData),
      ),
    );
  }

  // 3. Abre la Portada de Inicio de Entrenamiento (8.png) con el cronómetro
  void _iniciarEntrenamiento(Map<String, dynamic> rutina, [Map<String, dynamic>? diaRutina]) {
    final Map<String, dynamic> diaData = diaRutina ?? {
      'nombre_dia': rutina['nombre_rutina'] ?? rutina['nombre_plan'] ?? 'ENTRENAMIENTO'
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleRutinaScreen(
          rutina: rutina,
          diaRutina: diaData,
        ),
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
          'TUS RUTINAS',
          style: EstiloTexto.tekoTituloSeccion.copyWith(fontSize: 20, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.verdePrimario, size: 24),
            tooltip: 'Historial',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistorialScreen()),
              );
            },
          ),
        ],
      ),
      body: FondoApp(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Pestañas (RUTINAS DIARIAS / PLANES SEMANALES)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.grisOscuro,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _pestanaActiva = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _pestanaActiva == 0 ? AppColors.verdePrimario : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'RUTINAS DIARIAS',
                                style: TextStyle(
                                  fontFamily: 'Oswald',
                                  color: _pestanaActiva == 0 ? AppColors.fondoNegro : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _pestanaActiva = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _pestanaActiva == 1 ? AppColors.verdePrimario : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'PLANES SEMANALES',
                                style: TextStyle(
                                  fontFamily: 'Oswald',
                                  color: _pestanaActiva == 1 ? AppColors.fondoNegro : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _pestanaActiva == 0
                    ? _construirListaDiarias()
                    : _construirListaSemanales(),
              ),
            ],
          ),
        ),
      ),
      
      floatingActionButton: const BurbujaMiniChatModal(),
    );
  }

  // 🏋️ LISTA DIARIAS
  Widget _construirListaDiarias() {
    if (_rutinasDiarias.isEmpty) {
      return const Center(child: Text('No tienes rutinas diarias creadas.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _rutinasDiarias.length,
      itemBuilder: (context, index) {
        final rutina = _rutinasDiarias[index];
        final String nombre = rutina['nombre_rutina'] ?? 'Rutina Diaria';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.grisOscuro.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.verdePrimario.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: AppColors.verdePrimario, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Oswald',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Fecha: ${rutina['fecha'] ?? 'Hoy'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // Botón VER DETALLE -> Abre DetalleRutinaDiariaScreen
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.verdePrimario),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => _verDetalleDiario(rutina),
                  child: const Text(
                    'VER DETALLE',
                    style: TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón ENTRENAR -> Abre DetalleRutinaScreen (8.png)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrimario,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => _iniciarEntrenamiento(rutina),
                  child: const Text(
                    'ENTRENAR',
                    style: TextStyle(fontFamily: 'Oswald', color: AppColors.fondoNegro, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📅 LISTA SEMANALES
  Widget _construirListaSemanales() {
    if (_rutinasSemanales.isEmpty) {
      return const Center(child: Text('No tienes planes semanales creados.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _rutinasSemanales.length,
      itemBuilder: (context, index) {
        final plan = _rutinasSemanales[index];
        final String nombrePlan = plan['nombre_plan'] ?? 'Plan Semanal';
        final String fechaInicio = plan['fecha'] ?? 'Sin fecha';
        final Map<String, dynamic> estructura = plan['estructura_semanal'] ?? {};

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.grisOscuro.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: ExpansionTile(
            iconColor: AppColors.verdePrimario,
            collapsedIconColor: Colors.grey,
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.verdePrimario.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Inicia: $fechaInicio',
                          style: const TextStyle(color: AppColors.verdePrimario, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nombrePlan.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Oswald',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón VER DETALLE -> Abre DetallePlanSemanalScreen
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.verdePrimario, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _verDetalleSemanal(plan),
                  child: const Text(
                    'VER DETALLE',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      color: AppColors.verdePrimario,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: const Text(
              'Toca para desplegar los días del plan',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Column(
                  children: estructura.entries.map<Widget>((entry) {
                    final String diaKey = entry.key;
                    final datosDia = entry.value as Map<String, dynamic>;
                    final String nombreRutinaDia = datosDia['nombre_rutina'] ?? 'Rutina';

                    const nombresCompletos = {
                      'L': 'LUNES', 'M': 'MARTES', 'Mi': 'MIÉRCOLES',
                      'J': 'JUEVES', 'V': 'VIERNES', 'S': 'SÁBADO', 'D': 'DOMINGO'
                    };

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.grisOscuro,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${nombresCompletos[diaKey] ?? diaKey}: ',
                                style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                nombreRutinaDia,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                          // Botón INICIAR para entrenar ese día en vivo
                          GestureDetector(
                            onTap: () => _iniciarEntrenamiento(plan, {
                              'nombre_dia': '$nombreRutinaDia (${nombresCompletos[diaKey] ?? diaKey})'
                            }),
                            child: const Row(
                              children: [
                                Text(
                                  'INICIAR',
                                  style: TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.play_arrow_rounded, color: AppColors.verdePrimario, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}