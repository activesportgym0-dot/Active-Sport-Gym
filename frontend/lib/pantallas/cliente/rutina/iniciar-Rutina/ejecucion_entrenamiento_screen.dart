import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class EjecucionEntrenamientoScreen extends StatefulWidget {
  final Map<String, dynamic> rutina;
  final Map<String, dynamic> diaRutina;

  const EjecucionEntrenamientoScreen({
    super.key,
    required this.rutina,
    required this.diaRutina,
  });

  @override
  State<EjecucionEntrenamientoScreen> createState() => _EjecucionEntrenamientoScreenState();
}

class _EjecucionEntrenamientoScreenState extends State<EjecucionEntrenamientoScreen> {
  // 0: Presentación del Ejercicio (9.png)
  // 1: Ejecución Serie Activa
  // 2: Descanso (Reloj Circular Neón - entre series o final de ejercicio)
  // 3: Rutina Completada (10.png)
  int _estadoPantalla = 0;

  late List<dynamic> _ejercicios;
  int _ejercicioIndexActual = 0;
  int _serieIndexActual = 0;

  // Cronómetro global de la rutina
  late Stopwatch _cronometroGlobal;
  Timer? _timerGlobalUpdate;
  String _tiempoTotalRutinaStr = '00:00';

  // Temporizador de Descanso
  Timer? _timerDescanso;
  int _tiempoDescansoRestante = 30;
  int _tiempoDescansoTotalInicial = 30;
  bool _esDescansoEntreEjercicios = false;

  // Cronómetro de Serie Activa
  late Stopwatch _cronometroSerie;
  Timer? _timerSerieUpdate;
  String _tiempoSerieStr = '00:00';

  @override
  void initState() {
    super.initState();

    _ejercicios = widget.diaRutina['ejercicios'] as List? ?? [
      {
        'title': 'DOMINADAS',
        'descanso_final': 60,
        'series': [
          {'repeticiones': 10, 'peso': 5, 'descanso_entre_series': 30},
          {'repeticiones': 10, 'peso': 10, 'descanso_entre_series': 30},
        ]
      },
      {
        'title': 'REMO CON BARRA',
        'descanso_final': 60,
        'series': [
          {'repeticiones': 12, 'peso': 20, 'descanso_entre_series': 45},
        ]
      }
    ];

    _cronometroGlobal = Stopwatch()..start();
    _timerGlobalUpdate = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final s = _cronometroGlobal.elapsed.inSeconds;
          final m = (s ~/ 60).toString().padLeft(2, '0');
          final seg = (s % 60).toString().padLeft(2, '0');
          _tiempoTotalRutinaStr = '$m:$seg';
        });
      }
    });

    _cronometroSerie = Stopwatch();
  }

  @override
  void dispose() {
    _cronometroGlobal.stop();
    _cronometroSerie.stop();
    _timerGlobalUpdate?.cancel();
    _timerSerieUpdate?.cancel();
    _timerDescanso?.cancel();
    super.dispose();
  }

  void _iniciarMedicionSerie() {
    _cronometroSerie.reset();
    _cronometroSerie.start();
    _timerSerieUpdate?.cancel();
    _timerSerieUpdate = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final s = _cronometroSerie.elapsed.inSeconds;
          final m = (s ~/ 60).toString().padLeft(2, '0');
          final seg = (s % 60).toString().padLeft(2, '0');
          _tiempoSerieStr = '$m:$seg';
        });
      }
    });
  }

  void _iniciarTemporizadorDescanso(int segundos, bool esEntreEjercicios) {
    _cronometroSerie.stop();
    setState(() {
      _estadoPantalla = 2;
      _tiempoDescansoRestante = segundos;
      _tiempoDescansoTotalInicial = segundos > 0 ? segundos : 1;
      _esDescansoEntreEjercicios = esEntreEjercicios;
    });

    _timerDescanso?.cancel();
    _timerDescanso = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tiempoDescansoRestante > 1) {
        if (mounted) {
          setState(() {
            _tiempoDescansoRestante--;
          });
        }
      } else {
        _timerDescanso?.cancel();
        _avanzarDespuesDeDescanso();
      }
    });
  }

  void _avanzarDespuesDeDescanso() {
    _timerDescanso?.cancel();
    if (_esDescansoEntreEjercicios) {
      setState(() {
        _ejercicioIndexActual++;
        _serieIndexActual = 0;
        _estadoPantalla = 0; // Vuelve a la pantalla 9.png
      });
    } else {
      setState(() {
        _serieIndexActual++;
        _estadoPantalla = 1; // Pasa a la siguiente serie
      });
      _iniciarMedicionSerie();
    }
  }

  void _alApretarBotonAccion() {
    final ejercicioActual = _ejercicios[_ejercicioIndexActual];
    final List series = ejercicioActual['series'] as List? ?? [];
    final int totalSeries = series.length;

    if (_estadoPantalla == 0) {
      setState(() => _estadoPantalla = 1);
      _iniciarMedicionSerie();
      return;
    }

    if (_estadoPantalla == 2) {
      _avanzarDespuesDeDescanso();
      return;
    }

    if (_estadoPantalla == 1) {
      if (_serieIndexActual < totalSeries - 1) {
        final int descSerie = series[_serieIndexActual]['descanso_entre_series'] ?? 30;
        _iniciarTemporizadorDescanso(descSerie, false);
      } else {
        if (_ejercicioIndexActual < _ejercicios.length - 1) {
          final int descFinal = ejercicioActual['descanso_final'] ?? 60;
          _iniciarTemporizadorDescanso(descFinal, true);
        } else {
          _cronometroGlobal.stop();
          _cronometroSerie.stop();
          setState(() => _estadoPantalla = 3); // Pantalla 10.png
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ejercicios.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.fondoNegro,
        body: Center(child: Text('No hay ejercicios en esta rutina.', style: TextStyle(color: Colors.grey))),
      );
    }

    if (_estadoPantalla == 3) {
      return _buildPantallaRutinaCompletada();
    }

    final ejercicioActual = _ejercicios[_ejercicioIndexActual];
    final String tituloEjercicio = (ejercicioActual['title'] ?? ejercicioActual['nombre_ejercicio'] ?? 'EJERCICIO').toString().toUpperCase();
    final List series = ejercicioActual['series'] as List? ?? [
      {'repeticiones': 10, 'peso': 0}
    ];

    final int totalSeries = series.length;
    final Map<String, dynamic> serieActualData = series[_serieIndexActual < totalSeries ? _serieIndexActual : 0];
    final int reps = serieActualData['repeticiones'] ?? 10;
    final dynamic peso = serieActualData['peso'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      body: SafeArea(
        child: _estadoPantalla == 0
            ? _buildPantallaSiguienteEjercicio(tituloEjercicio, series, reps, peso)
            : _estadoPantalla == 1
                ? _buildPantallaEjecucionSerie(tituloEjercicio, totalSeries, reps, peso)
                : _buildPantallaDescanso(tituloEjercicio, totalSeries),
      ),
    );
  }

  // 0️⃣ PRESENTACIÓN DEL EJERCICIO (9.PNG) CON SCROLL FLUIDO
  Widget _buildPantallaSiguienteEjercicio(String tituloEjercicio, List series, int reps, dynamic peso) {
    return SingleChildScrollView(
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
                  tituloEjercicio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
                ),
                const SizedBox(height: 4),
                const Text('Prepárate para la siguiente serie.', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                      _buildInfoItem(Icons.fitness_center_rounded, 'Series', '${_serieIndexActual + 1}/${series.length}'),
                      _buildInfoItem(Icons.loop_rounded, 'Reps:', '$reps'),
                      _buildInfoItem(Icons.scale_rounded, 'Peso:', '$peso Kg'),
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
                      Text(_tiempoTotalRutinaStr, style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 15)),
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
                    onPressed: _alApretarBotonAccion,
                    child: const Text('EMPEZAR EJERCICIO', style: TextStyle(fontFamily: 'Oswald', color: AppColors.fondoNegro, fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 1.1)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1️⃣ EJECUCIÓN SERIE ACTIVA
  Widget _buildPantallaEjecucionSerie(String tituloEjercicio, int totalSeries, int reps, dynamic peso) {
    final bool esUltimaSerie = _serieIndexActual == totalSeries - 1;
    final bool esUltimoEjercicio = _ejercicioIndexActual == _ejercicios.length - 1;

    String textoBoton = 'TERMINAR SERIE';
    if (esUltimaSerie) {
      textoBoton = esUltimoEjercicio ? 'TERMINAR RUTINA' : 'TERMINAR EJERCICIO';
    }

    return Padding(
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
          const SizedBox(height: 6),
          Text('EJERCICIO ${_ejercicioIndexActual + 1}', style: const TextStyle(fontFamily: 'Oswald', color: Colors.white70, fontSize: 16)),
          Text(tituloEjercicio, style: const TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(color: AppColors.grisOscuro, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(Icons.fitness_center_rounded, 'Series', '${_serieIndexActual + 1}'),
                _buildInfoItem(Icons.loop_rounded, 'Reps:', '$reps'),
                _buildInfoItem(Icons.scale_rounded, 'Peso:', '$peso Kg'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.grisOscuro, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tiempo total de rutina', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(_tiempoTotalRutinaStr, style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/images/dominadas.png',
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.fitness_center, color: Colors.black45, size: 80)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Text(_tiempoSerieStr, style: const TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
              Container(width: 100, height: 3, color: AppColors.verdePrimario),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.verdePrimario, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _alApretarBotonAccion,
              child: Text(textoBoton, style: const TextStyle(fontFamily: 'Oswald', color: AppColors.fondoNegro, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // 2️⃣ DESCANSO CON RELOJ CIRCULAR NEÓN
  Widget _buildPantallaDescanso(String tituloEjercicio, int totalSeries) {
    final double progreso = _tiempoDescansoRestante / _tiempoDescansoTotalInicial;

    return Padding(
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
          const Text('DESCANSO', style: TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          Text(
            _esDescansoEntreEjercicios
                ? 'Descanso final de ejercicio'
                : 'Serie ${_serieIndexActual + 1} de $totalSeries',
            style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: AppColors.grisOscuro, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tiempo total de rutina', style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text(_tiempoTotalRutinaStr, style: const TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 15)),
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
                          '$_tiempoDescansoRestante',
                          style: const TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Respira...', style: TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    _esDescansoEntreEjercicios ? 'Prepárate para el siguiente ejercicio.' : 'Prepárate para la siguiente serie.',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(_tiempoTotalRutinaStr, style: const TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          Container(width: 80, height: 3, color: AppColors.verdePrimario),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.verdePrimario, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _alApretarBotonAccion,
              child: Text(
                _esDescansoEntreEjercicios ? 'SIGUIENTE EJERCICIO' : 'SIGUIENTE SERIE',
                style: const TextStyle(fontFamily: 'Oswald', color: AppColors.fondoNegro, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3️⃣ RUTINA COMPLETADA (10.PNG) CON DEFAULTTEXTSTYLE PARA EVITAR SUBRAYADOS
  Widget _buildPantallaRutinaCompletada() {
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.48,
                  child: Image.asset(
                    'assets/images/10.png',
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
                  const Text('¡RUTINA COMPLETADA!', style: TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 1.1, decoration: TextDecoration.none)),
                  const SizedBox(height: 2),
                  const Text('Cada entrenamiento te acerca a tu mejor versión.', style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.none)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildFichaResumen(Icons.calendar_today_rounded, 'FECHA:', '20 Octubre 2026')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildFichaResumen(Icons.access_time_rounded, 'TIEMPO TOTAL:', '$_tiempoTotalRutinaStr Minutos')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildFichaResumen(Icons.fitness_center_rounded, 'EJERCICIOS:', '${_ejercicios.length}/${_ejercicios.length} Completados')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildFichaResumen(Icons.check_circle_outline_rounded, 'ESTADO:', 'Completado\n¡Excelente trabajo!')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.grisOscuro, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text('Tiempo por ejercicio', style: TextStyle(fontFamily: 'Oswald', color: Colors.grey, fontSize: 13, decoration: TextDecoration.none)),
                        ),
                        const Divider(color: Colors.white12, height: 16),
                        ..._ejercicios.map((ej) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('• ${ej['title'] ?? 'Ejercicio'}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
                                const Row(
                                  children: [
                                    Text('5:10 ', style: TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.none)),
                                    Icon(Icons.access_time, color: AppColors.verdePrimario, size: 14),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.verdePrimario.withOpacity(0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.verdePrimario, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RUTINA GUARDADA CORRECTAMENTE', style: TextStyle(fontFamily: 'Oswald', color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.none)),
                              Text('La sesión quedó registrada en tu historial. Puedes repetir esta rutina cuando desees.', style: TextStyle(color: Colors.grey, fontSize: 10, decoration: TextDecoration.none)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.verdePrimario, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('FINALIZAR', style: TextStyle(fontFamily: 'Oswald', color: AppColors.fondoNegro, fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 1.1, decoration: TextDecoration.none)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFichaResumen(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.grisOscuro, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.verdePrimario, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, decoration: TextDecoration.none)),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.none)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.verdePrimario, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, decoration: TextDecoration.none)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.none)),
          ],
        ),
      ],
    );
  }
}