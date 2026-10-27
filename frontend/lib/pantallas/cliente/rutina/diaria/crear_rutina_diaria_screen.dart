import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/componentes/fondo.dart';
import 'package:frontend/componentes/cliente/rutina/diaria/modal_buscador_ejercicios.dart';
import 'package:frontend/componentes/cliente/rutina/diaria/tarjeta_ejercicio_agregado.dart';
import 'package:frontend/componentes/cliente/rutina/diaria/dialog_confirmar_cancelar.dart';
import 'package:frontend/pantallas/cliente/rutina/detalle_rutina_diaria_screen.dart';
import 'package:frontend/pantallas/cliente/rutina/semanal/crear_rutina_semanal_screen.dart';
import 'package:frontend/componentes/cliente/asistente/burbuja_mini_chat_modal.dart';

class CrearRutinaDiariaScreen extends StatefulWidget {
  const CrearRutinaDiariaScreen({super.key});

  @override
  State<CrearRutinaDiariaScreen> createState() => _CrearRutinaDiariaScreenState();
}

class _CrearRutinaDiariaScreenState extends State<CrearRutinaDiariaScreen> {
  final TextEditingController _nombreRutinaController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  final List<Map<String, dynamic>> _catalogoGlobalAdmin = [
    {
      'id_ejercicio': 1,
      'title': 'Remo horizontal con mancuernas',
      'category': 'Glúteos',
      'description': 'Mantén la espalda recta y trata de llevar los codos al techo.',
      'imagePath': 'assets/images/3.jpg',
    },
    {
      'id_ejercicio': 2,
      'title': 'Crunch abdominal',
      'category': 'Tren superior',
      'description': 'Sirve específicamente para aislar y fortalecer el recto abdominal.',
      'imagePath': 'assets/images/4.jpg',
    },
  ];

  final List<Map<String, dynamic>> _ejerciciosSeleccionados = [];

  @override
  void dispose() {
    _nombreRutinaController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  void _manejarIntentoCancelar() {
    if (_ejerciciosSeleccionados.isNotEmpty || _nombreRutinaController.text.trim().isNotEmpty) {
      DialogConfirmarCancelar.mostrar(
        context,
        onConfirmar: () => Navigator.pop(context),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _abrirBuscadorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalBuscadorEjercicios(
        catalogoEjercicios: _catalogoGlobalAdmin,
        onEjercicioSeleccionado: (ejercicioElegido) {
          setState(() {
            _ejerciciosSeleccionados.add({
              'id_ejercicio': ejercicioElegido['id_ejercicio'],
              'title': ejercicioElegido['title'],
              'category': ejercicioElegido['category'],
              'description': ejercicioElegido['description'],
              'imagePath': ejercicioElegido['imagePath'],
              'descanso_final': 60,
              'series': [
                {'repeticiones': 10, 'peso': 0, 'descanso_entre_series': 30}
              ]
            });
          });
        },
      ),
    );
  }

  void _guardarRutinaLocal() {
    if (_nombreRutinaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para la rutina')),
      );
      return;
    }

    if (_ejerciciosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un ejercicio')),
      );
      return;
    }

    // Estructura de datos idéntica a la que espera el detalle diario
    final Map<String, dynamic> payloadDiario = {
      "nombre_rutina": _nombreRutinaController.text.trim(),
      "fecha": _fechaController.text.isNotEmpty ? _fechaController.text : null,
      "ejercicios": _ejerciciosSeleccionados,
    };

    // Navegación hacia la vista de detalle/resumen de la rutina diaria
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleRutinaDiariaScreen(rutinaData: payloadDiario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(
            'CREAR RUTINA',
            style: EstiloTexto.tekoTituloSeccion,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Image.asset('assets/images/loguito.png', width: 90, height: 90, fit: BoxFit.cover),
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

                  // Radio buttons (Diaria / Semanal)
                  Row(
                    children: [
                      Radio<String>(
                        value: 'diaria',
                        groupValue: 'diaria',
                        activeColor: AppColors.verdePrimario,
                        onChanged: (val) {},
                      ),
                      const Text('Diaria', style: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 13)),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: 'semanal',
                        groupValue: 'diaria',
                        activeColor: AppColors.verdePrimario,
                        onChanged: (val) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const CrearRutinaSemanalScreen()),
                          );
                        },
                      ),
                      const Text('Semanal', style: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text('Nombre', style: EstiloTexto.tekoEtiquetaForm),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _nombreRutinaController,
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
                          _fechaController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  Text('EJERCICIOS', style: EstiloTexto.tekoSubtituloSeccion.copyWith(fontSize: 16)),
                  const SizedBox(height: 10),

                  _ejerciciosSeleccionados.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.grisOscuro.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: _abrirBuscadorModal,
                                child: const Icon(Icons.add_circle_outline, color: AppColors.verdePrimario, size: 50),
                              ),
                              const SizedBox(height: 12),
                              Text('AGREGAR TU PRIMER EJERCICIO', style: TextStyle(fontFamily: 'Oswald', color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                'Toca el botón para empezar a construir tu rutina',
                                style: EstiloTexto.textoAyudaRoboto,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: _abrirBuscadorModal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: const BorderSide(color: AppColors.verdePrimario),
                                    ),
                                  ),
                                  child: const Text('AGREGAR EJERCICIO', style: TextStyle(fontFamily: 'Oswald', fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _ejerciciosSeleccionados.length,
                          itemBuilder: (context, index) {
                            final ejercicio = _ejerciciosSeleccionados[index];
                            return TarjetaEjercicioAgregado(
                              numeroEjercicio: index + 1,
                              ejercicioData: ejercicio,
                              onAgregarSerie: () {
                                setState(() {
                                  (ejercicio['series'] as List).add({
                                    'repeticiones': 10,
                                    'peso': 0,
                                    'descanso_entre_series': 30
                                  });
                                });
                              },
                              onEliminarEjercicio: () {
                                setState(() {
                                  _ejerciciosSeleccionados.removeAt(index);
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

                  if (_ejerciciosSeleccionados.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: ElevatedButton.icon(
                        onPressed: _abrirBuscadorModal,
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
                            onPressed: _guardarRutinaLocal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdePrimario,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('GUARDAR RUTINA', style: TextStyle(fontFamily: 'Oswald', fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
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