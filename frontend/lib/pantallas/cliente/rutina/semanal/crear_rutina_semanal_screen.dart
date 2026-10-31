import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/rutina/diaria/tarjeta_ejercicio_agregado.dart';
import 'package:frontend/componentes/cliente/rutina/diaria/dialog_confirmar_cancelar.dart';
import 'package:frontend/componentes/cliente/rutina/semanal/selector_dias_semana.dart';
import 'package:frontend/componentes/cliente/rutina/semanal/bloque_primer_ejercicio.dart';
import 'package:frontend/pantallas/cliente/rutina/detalle_plan_semanal_screen.dart';
import 'package:frontend/pantallas/cliente/rutina/diaria/crear_rutina_diaria_screen.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';
import 'package:frontend/models/ejercicio_catalogo_model.dart';
import 'package:frontend/models/rutina_model.dart';
import 'package:frontend/services/ejercicio_service.dart';
import 'package:frontend/services/rutina_service.dart';

class CrearRutinaSemanalScreen extends StatefulWidget {
  const CrearRutinaSemanalScreen({super.key});

  @override
  State<CrearRutinaSemanalScreen> createState() => _CrearRutinaSemanalScreenState();
}

class _CrearRutinaSemanalScreenState extends State<CrearRutinaSemanalScreen> {
  final TextEditingController _nombrePlanController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _nombreRutinaDiaController = TextEditingController();
  
  String _tipoRutina = 'semanal';
  String _diaSeleccionado = 'L';

  final Map<String, Map<String, dynamic>> _estructuraSemanal = {
    'L': {'nombre_rutina': '', 'ejercicios': <Map<String, dynamic>>[]},
    'M': {'nombre_rutina': '', 'ejercicios': <Map<String, dynamic>>[]},
    'Mi': {'nombre_rutina': '', 'ejercicios': <Map<String, dynamic>>[]},
    'J': {'nombre_rutina': '', 'ejercicios': <Map<String, dynamic>>[]},
    'V': {'nombre_rutina': '', 'ejercicios': <Map<String, dynamic>>[]},
    'S': {'nombre_rutina': '', 'ejercicios': <Map<String, dynamic>>[]},
    'D': {'nombre_rutina': '', 'ejercicios': <Map<String, dynamic>>[]},
  };

  final Map<String, String> _nombresDiasCompletos = {
    'L': 'LUNES',
    'M': 'MARTES',
    'Mi': 'MIÉRCOLES',
    'J': 'JUEVES',
    'V': 'VIERNES',
    'S': 'SÁBADO',
    'D': 'DOMINGO',
  };

  // Catálogo real de ejercicios (GET /ejercicios) y sus categorías (GET /categorias)
  List<EjercicioCatalogoModel> _catalogo = [];
  List<String> _categorias = [];
  bool _cargandoCatalogo = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _actualizarControladorDia();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    final ejerciciosRaw = await EjercicioService.obtenerEjercicios();
    final categoriasRaw = await EjercicioService.obtenerCategorias();
    if (!mounted) return;

    setState(() {
      _catalogo = ejerciciosRaw
          .whereType<Map>()
          .map((e) => EjercicioCatalogoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      _categorias = categoriasRaw
          .whereType<Map>()
          .map((c) => (c['nombre'] ?? '').toString())
          .where((n) => n.isNotEmpty)
          .toList();
      _cargandoCatalogo = false;
    });

    if (_catalogo.isEmpty) {
      _mostrarMensaje('No se pudo cargar el catálogo de ejercicios.', exito: false);
    }
  }

  void _mostrarMensaje(String mensaje, {required bool exito}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  void _actualizarControladorDia() {
    _nombreRutinaDiaController.text = _estructuraSemanal[_diaSeleccionado]?['nombre_rutina'] ?? '';
  }

  @override
  void dispose() {
    _nombrePlanController.dispose();
    _fechaController.dispose();
    _nombreRutinaDiaController.dispose();
    super.dispose();
  }

  void _manejarIntentoCancelar() {
    bool hayDatos = _nombrePlanController.text.trim().isNotEmpty ||
        _estructuraSemanal.values.any((dia) => (dia['ejercicios'] as List).isNotEmpty || (dia['nombre_rutina'] as String).trim().isNotEmpty);

    if (hayDatos) {
      DialogConfirmarCancelar.mostrar(
        context,
        onConfirmar: () => Navigator.pop(context),
      );
    } else {
      Navigator.pop(context);
    }
  }

  // Agrega una tarjeta "Ejercicio N" vacía al día seleccionado: muestra el mini buscador
  void _agregarEjercicio() {
    final listaEjercicios = _estructuraSemanal[_diaSeleccionado]!['ejercicios'] as List;
    if (listaEjercicios.any((e) => e['id_ejercicio'] == null)) {
      _mostrarMensaje('Primero elige el ejercicio que ya está abierto.', exito: false);
      return;
    }
    setState(() {
      listaEjercicios.add(EjercicioRutinaModel.mapaPantallaVacio());
    });
  }

  // POST /rutinas (tipo semanal). Solo se envían los días que tienen ejercicios.
  Future<void> _guardarPlanSemanalBackend() async {
    if (_guardando) return;

    if (_nombrePlanController.text.trim().isEmpty) {
      _mostrarMensaje('El nombre del plan semanal es obligatorio', exito: false);
      return;
    }

    final RutinaNuevaModel rutina;
    try {
      final dias = <DiaRutinaModel>[];
      for (final entrada in _estructuraSemanal.entries) {
        final ejercicios = entrada.value['ejercicios'] as List;
        if (ejercicios.isEmpty) continue;

        final nombreDia = (entrada.value['nombre_rutina'] as String).trim();
        final etiquetaDia = _nombresDiasCompletos[entrada.key] ?? entrada.key;
        if (nombreDia.isEmpty) {
          throw FormatException('Escribe el nombre de la rutina del $etiquetaDia.');
        }

        final List<EjercicioRutinaModel> lista;
        try {
          lista = EjercicioRutinaModel.listaDesdePantalla(ejercicios);
        } on FormatException catch (e) {
          throw FormatException('$etiquetaDia: ${e.message}');
        }

        dias.add(
          DiaRutinaModel(
            diaSemana: etiquetaDia.toLowerCase(), // el backend espera "lunes", "miércoles"...
            nombreDia: nombreDia,
            ejercicios: lista,
          ),
        );
      }

      rutina = RutinaNuevaModel.semanal(
        nombre: _nombrePlanController.text,
        fecha: _fechaController.text, // ya está en formato AAAA-MM-DD
        dias: dias,
      );
    } on FormatException catch (e) {
      _mostrarMensaje(e.message, exito: false);
      return;
    }

    setState(() => _guardando = true);
    final resultado = await RutinaService.crearRutina(rutina);
    if (!mounted) return;
    setState(() => _guardando = false);

    if (resultado['success'] != true) {
      _mostrarMensaje(resultado['message'].toString(), exito: false);
      return;
    }
    _mostrarMensaje(resultado['message'].toString(), exito: true);

    final Map<String, dynamic> payloadPlanSemanal = {
      "nombre_plan": _nombrePlanController.text.trim(),
      "tipo": _tipoRutina,
      "fecha": _fechaController.text.isNotEmpty ? _fechaController.text : null,
      "estructura_semanal": _estructuraSemanal.map((dia, datos) => MapEntry(
            dia,
            {
              "nombre_rutina": datos['nombre_rutina'],
              "ejercicios": (datos['ejercicios'] as List).map((ej) => {
                    "id_ejercicio": ej['id_ejercicio'],
                    "title": ej['title'],
                    "descanso_final": ej['descanso_final'],
                    "series": ej['series']
                  }).toList()
            },
          ))
    };

    // Ya quedó guardado: se reemplaza esta pantalla por el resumen para no guardarlo dos veces
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DetallePlanSemanalScreen(planData: payloadPlanSemanal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ejerciciosDelDia = _estructuraSemanal[_diaSeleccionado]!['ejercicios'] as List;

    return WillPopScope(
      onWillPop: () async {
        _manejarIntentoCancelar();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.fondoNegro,
        appBar: AppBar(
          backgroundColor: AppColors.fondoNegro,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
            onPressed: _manejarIntentoCancelar,
          ),
          title: Text('CREAR RUTINA', style: EstiloTexto.tekoTituloSeccion),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/images/loguito.png', width: 90, height: 90, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
        body: FondoApp(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CREA TU RUTINA', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 20)),
                  Text('Personaliza tu entrenamiento', style: EstiloTexto.subtituloRoboto),
                  const SizedBox(height: 20),

                  Text('Información general', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Radio<String>(
                        value: 'diaria',
                        groupValue: _tipoRutina,
                        activeColor: AppColors.verdePrimario,
                        onChanged: (val) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const CrearRutinaDiariaScreen()),
                          );
                        },
                      ),
                      const Text('Diaria', style: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 13)),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: 'semanal',
                        groupValue: _tipoRutina,
                        activeColor: AppColors.verdePrimario,
                        onChanged: (val) => setState(() => _tipoRutina = val!),
                      ),
                      const Text('Semanal', style: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text('Nombre del plan semanal', style: EstiloTexto.tekoEtiquetaForm),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _nombrePlanController,
                    style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rutina de Piernas...',
                      hintStyle: TextStyle(fontFamily: 'RobotoCondensed', color: Colors.grey.withOpacity(0.6)),
                      filled: true,
                      fillColor: AppColors.grisOscuro,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text('Fecha', style: EstiloTexto.tekoEtiquetaForm),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _fechaController,
                    readOnly: true,
                    style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'DD/MM/AA',
                      hintStyle: TextStyle(fontFamily: 'RobotoCondensed', color: Colors.grey.withOpacity(0.6)),
                      suffixIcon: const Icon(Icons.keyboard_arrow_down, color: AppColors.verdePrimario, size: 20),
                      filled: true,
                      fillColor: AppColors.grisOscuro,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _fechaController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  Text('ESTRUCTURA SEMANAL', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16, letterSpacing: 0.8)),
                  const SizedBox(height: 8),

                  SelectorDiasSemana(
                    diaSeleccionado: _diaSeleccionado,
                    onDiaSeleccionado: (dia) {
                      setState(() {
                        _diaSeleccionado = dia;
                        _actualizarControladorDia();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    _nombresDiasCompletos[_diaSeleccionado] ?? '',
                    style: const TextStyle(fontFamily: 'Teko', color: AppColors.verdePrimario, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Nombre de la rutina', style: EstiloTexto.tekoEtiquetaForm),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _nombreRutinaDiaController,
                    style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white, fontSize: 14),
                    onChanged: (value) {
                      _estructuraSemanal[_diaSeleccionado]!['nombre_rutina'] = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'ESPALDA...',
                      hintStyle: TextStyle(fontFamily: 'RobotoCondensed', color: Colors.grey.withOpacity(0.6)),
                      filled: true,
                      fillColor: AppColors.grisOscuro,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ejerciciosDelDia.isEmpty
                      ? BloquePrimerEjercicio(onAgregar: _agregarEjercicio)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ejerciciosDelDia.length,
                          itemBuilder: (context, index) {
                            final ejercicio = ejerciciosDelDia[index];
                            return TarjetaEjercicioAgregado(
                              numeroEjercicio: index + 1,
                              ejercicioData: ejercicio,
                              catalogo: _catalogo,
                              categorias: _categorias,
                              cargandoCatalogo: _cargandoCatalogo,
                              // El usuario eligió un ejercicio en el mini buscador
                              onSeleccionarEjercicio: (elegido) {
                                setState(() {
                                  ejercicio.addAll(elegido.toMapaSeleccion());
                                  ejercicio['cambiando'] = false;
                                });
                              },
                              onCancelarSeleccion: () {
                                setState(() {
                                  if (ejercicio['id_ejercicio'] == null) {
                                    ejerciciosDelDia.removeAt(index);
                                  } else {
                                    ejercicio['cambiando'] = false;
                                  }
                                });
                              },
                              onEditar: () {
                                setState(() => ejercicio['cambiando'] = true);
                              },
                              onAgregarSerie: () {
                                setState(() {
                                  final series = ejercicio['series'] as List;
                                  // La serie nueva copia el descanso de la anterior
                                  final descansoAnterior = series.isNotEmpty
                                      ? int.tryParse((series.last as Map)['descanso_entre_series'].toString())
                                      : null;
                                  series.add(SerieRutinaModel.mapaNuevo(descansoEntreSeries: descansoAnterior ?? 30));
                                });
                              },
                              onEliminarEjercicio: () {
                                setState(() {
                                  ejerciciosDelDia.removeAt(index);
                                });
                              },
                              onEliminarSerie: (serieIndex) {
                                setState(() {
                                  (ejercicio['series'] as List).removeAt(serieIndex);
                                });
                              },
                            );
                          },
                        ),

                  if (ejerciciosDelDia.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: ElevatedButton.icon(
                        onPressed: _agregarEjercicio,
                        icon: const Icon(Icons.add, color: Colors.black, size: 16),
                        label: const Text('AGREGAR EJERCICIO', style: TextStyle(fontFamily: 'Oswald', color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdePrimario,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: _guardando ? null : _guardarPlanSemanalBackend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdePrimario,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _guardando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                  )
                                : const Text('GUARDAR PLAN', style: TextStyle(fontFamily: 'Oswald', fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: _manejarIntentoCancelar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdePrimario,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('CANCELAR', style: TextStyle(fontFamily: 'Oswald', fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: const BurbujaMiniChatModal(),
      ),
    );
  }
}