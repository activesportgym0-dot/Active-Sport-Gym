import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/componentes/cliente/rutina/media_ejercicio.dart';
import 'package:frontend/pantallas/cliente/rutina/iniciar-Rutina/descanso_pantalla.dart';
import 'package:frontend/pantallas/cliente/rutina/iniciar-Rutina/siguiente_ejercicio_screen.dart';
import 'package:frontend/services/historial_service.dart';

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

  // Tiempo real de cada ejercicio (en segundos, por posición en la rutina). Va al historial.
  final Map<int, int> _segundosPorEjercicio = {};
  int _inicioEjercicioSeg = 0;

  // Registro del entrenamiento en el historial (POST /historial)
  String _estadoGuardado = 'guardando'; // guardando | ok | error
  String _mensajeGuardado = '';

  // Cronómetro global de la rutina
  late Stopwatch _cronometroGlobal;
  Timer? _timerGlobalUpdate;
  String _tiempoTotalRutinaStr = '00:00';
  // Mismo reloj, pero observable: SiguienteEjercicioScreen y DescansoPantalla lo usan
  // para que el tiempo siga corriendo mientras están en pantalla.
  final ValueNotifier<String> _tiempoTotal = ValueNotifier<String>('00:00');

  // Descanso (el reloj regresivo está en DescansoPantalla)
  int _tiempoDescansoTotalInicial = 30;
  bool _esDescansoEntreEjercicios = false;

  // Cronómetro de Serie Activa
  late Stopwatch _cronometroSerie;
  Timer? _timerSerieUpdate;
  String _tiempoSerieStr = '00:00';

  @override
  void initState() {
    super.initState();

    // Ejercicios reales de la rutina (con series, descansos y el GIF/video de cada uno)
    _ejercicios = widget.diaRutina['ejercicios'] as List? ?? [];

    _cronometroGlobal = Stopwatch()..start();
    _timerGlobalUpdate = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final s = _cronometroGlobal.elapsed.inSeconds;
          final m = (s ~/ 60).toString().padLeft(2, '0');
          final seg = (s % 60).toString().padLeft(2, '0');
          _tiempoTotalRutinaStr = '$m:$seg';
          _tiempoTotal.value = _tiempoTotalRutinaStr;
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
    _tiempoTotal.dispose();
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

  // Pasa a la pantalla de descanso. El conteo regresivo lo hace DescansoPantalla,
  // que avisa con onTerminar (_avanzarDespuesDeDescanso) cuando se acaba el tiempo.
  void _iniciarTemporizadorDescanso(int segundos, bool esEntreEjercicios) {
    _cronometroSerie.stop();
    _timerSerieUpdate?.cancel();
    setState(() {
      _estadoPantalla = 2;
      _tiempoDescansoTotalInicial = segundos > 0 ? segundos : 30;
      _esDescansoEntreEjercicios = esEntreEjercicios;
    });
  }

  void _avanzarDespuesDeDescanso() {
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
      _inicioEjercicioSeg = _cronometroGlobal.elapsed.inSeconds; // empieza a contar este ejercicio
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
        // Última serie: se guarda cuánto tardó este ejercicio
        _segundosPorEjercicio[_ejercicioIndexActual] = _cronometroGlobal.elapsed.inSeconds - _inicioEjercicioSeg;

        if (_ejercicioIndexActual < _ejercicios.length - 1) {
          final int descFinal = ejercicioActual['descanso_final'] ?? 60;
          _iniciarTemporizadorDescanso(descFinal, true);
        } else {
          _cronometroGlobal.stop();
          _cronometroSerie.stop();
          setState(() => _estadoPantalla = 3); // Pantalla 10.png
          _registrarEnHistorial(); // guarda la sesión en el backend
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
      // Con Scaffold la pantalla final tiene el fondo negro (antes quedaba blanco abajo)
      return Scaffold(
        backgroundColor: AppColors.fondoNegro,
        body: _buildPantallaRutinaCompletada(),
      );
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

    // 0: presentación del ejercicio
    if (_estadoPantalla == 0) {
      return SiguienteEjercicioScreen(
        nombreEjercicio: tituloEjercicio,
        numeroEjercicio: _ejercicioIndexActual + 1,
        totalEjercicios: _ejercicios.length,
        serieActual: _serieIndexActual + 1,
        totalSeries: totalSeries,
        reps: reps,
        peso: peso,
        tiempoTotalRutina: _tiempoTotal,
        onEmpezar: _alApretarBotonAccion,
      );
    }

    // 2: descanso (entre series o final del ejercicio)
    if (_estadoPantalla == 2) {
      String nombreSiguiente;
      if (_esDescansoEntreEjercicios && _ejercicioIndexActual < _ejercicios.length - 1) {
        final siguiente = _ejercicios[_ejercicioIndexActual + 1];
        nombreSiguiente = (siguiente['title'] ?? siguiente['nombre_ejercicio'] ?? 'Ejercicio').toString().toUpperCase();
      } else {
        nombreSiguiente = 'Serie ${_serieIndexActual + 2} de $totalSeries';
      }

      return DescansoPantalla(
        // Una pantalla de descanso nueva (con su propio reloj) por cada descanso
        key: ValueKey('descanso_${_ejercicioIndexActual}_${_serieIndexActual}_$_esDescansoEntreEjercicios'),
        segundosDescanso: _tiempoDescansoTotalInicial,
        esEntreEjercicios: _esDescansoEntreEjercicios,
        serieActual: _serieIndexActual + 1,
        totalSeries: totalSeries,
        nombreSiguiente: nombreSiguiente,
        tiempoTotalRutina: _tiempoTotal,
        onTerminar: _avanzarDespuesDeDescanso,
      );
    }

    // 1: serie activa con el GIF/video del ejercicio
    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      body: SafeArea(
        child: _buildPantallaEjecucionSerie(tituloEjercicio, totalSeries, reps, peso),
      ),
    );
  }

  // 1️⃣ EJECUCIÓN SERIE ACTIVA
  Widget _buildPantallaEjecucionSerie(String tituloEjercicio, int totalSeries, int reps, dynamic peso) {
    final bool esUltimaSerie = _serieIndexActual == totalSeries - 1;
    final bool esUltimoEjercicio = _ejercicioIndexActual == _ejercicios.length - 1;
    // Demostración del ejercicio: el GIF/video que subió el admin; si no tiene, su imagen
    final ejercicioMostrado = _ejercicios[_ejercicioIndexActual];
    final String gifUrlActual = (ejercicioMostrado['gif_url'] ?? '').toString().isNotEmpty
        ? ejercicioMostrado['gif_url'].toString()
        : (ejercicioMostrado['imagen'] ?? '').toString();

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
              // GIF o video de demostración del ejercicio (campo gif_url del backend)
              child: MediaEjercicio(
                key: ValueKey('media_${_ejercicioIndexActual}_$gifUrlActual'),
                url: gifUrlActual,
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

  // 3️⃣ RUTINA COMPLETADA (10.PNG) CON DEFAULTTEXTSTYLE PARA EVITAR SUBRAYADOS
  // Guarda el entrenamiento terminado: POST /historial con el tiempo total y el de cada ejercicio
  Future<void> _registrarEnHistorial() async {
    final idRutina = int.tryParse(widget.rutina['id_rutina'].toString());
    if (idRutina == null) {
      setState(() {
        _estadoGuardado = 'error';
        _mensajeGuardado = 'No se encontró el ID de la rutina.';
      });
      return;
    }

    setState(() => _estadoGuardado = 'guardando');

    final ejercicios = <Map<String, dynamic>>[];
    for (var i = 0; i < _ejercicios.length; i++) {
      final id = int.tryParse(_ejercicios[i]['id_ejercicio'].toString());
      if (id != null) {
        ejercicios.add({'id_ejercicio': id, 'tiempo_ejercicio': _segundosPorEjercicio[i] ?? 0});
      }
    }

    final resultado = await HistorialService.registrarEntrenamiento(
      idRutina: idRutina,
      tiempoTotalSegundos: _cronometroGlobal.elapsed.inSeconds,
      ejercicios: ejercicios,
    );
    if (!mounted) return;

    setState(() {
      _estadoGuardado = resultado['success'] == true ? 'ok' : 'error';
      _mensajeGuardado = resultado['message'].toString();
    });
  }

  // 125 segundos -> "2:05"
  String _formatearMmSs(int segundos) {
    final m = segundos ~/ 60;
    final s = (segundos % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _fechaHoyTexto() {
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    final hoy = DateTime.now();
    return '${hoy.day} ${meses[hoy.month - 1]} ${hoy.year}';
  }

  // Aviso de la pantalla final: guardando, guardado o con error (con opción de reintentar)
  Widget _buildEstadoGuardado() {
    final bool guardando = _estadoGuardado == 'guardando';
    final bool error = _estadoGuardado == 'error';
    final Color color = error ? Colors.redAccent : AppColors.verdePrimario;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          guardando
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: AppColors.verdePrimario, strokeWidth: 2.5),
                )
              : Icon(error ? Icons.error_outline : Icons.check_circle, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guardando
                      ? 'GUARDANDO EN TU HISTORIAL...'
                      : error
                          ? 'NO SE PUDO GUARDAR'
                          : 'RUTINA GUARDADA CORRECTAMENTE',
                  style: TextStyle(fontFamily: 'Oswald', color: color, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.none),
                ),
                Text(
                  guardando
                      ? 'Un momento, estamos registrando tu sesión.'
                      : error
                          ? _mensajeGuardado
                          : 'La sesión quedó registrada en tu historial. Puedes repetir esta rutina cuando desees.',
                  style: const TextStyle(color: Colors.grey, fontSize: 10, decoration: TextDecoration.none),
                ),
              ],
            ),
          ),
          if (error)
            TextButton(
              onPressed: _registrarEnHistorial,
              child: const Text(
                'REINTENTAR',
                style: TextStyle(color: AppColors.verdePrimario, fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              ),
            ),
        ],
      ),
    );
  }

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
                      Expanded(child: _buildFichaResumen(Icons.calendar_today_rounded, 'FECHA:', _fechaHoyTexto())),
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
                        ..._ejercicios.asMap().entries.map((entrada) {
                          final ej = entrada.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('• ${ej['title'] ?? 'Ejercicio'}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
                                Row(
                                  children: [
                                    Text('${_formatearMmSs(_segundosPorEjercicio[entrada.key] ?? 0)} ', style: TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.none)),
                                    const Icon(Icons.access_time, color: AppColors.verdePrimario, size: 14),
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
                  _buildEstadoGuardado(),
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