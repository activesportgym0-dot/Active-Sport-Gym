import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/cliente/rutina/iniciar-Rutina/ejecucion_entrenamiento_screen.dart';

class DetalleRutinaScreen extends StatefulWidget {
  final Map<String, dynamic> rutina;
  final Map<String, dynamic> diaRutina;

  const DetalleRutinaScreen({
    super.key,
    required this.rutina,
    required this.diaRutina,
  });

  @override
  State<DetalleRutinaScreen> createState() => _DetalleRutinaScreenState();
}

class _DetalleRutinaScreenState extends State<DetalleRutinaScreen> {
  // Banco de frases motivacionales gym & disciplina
  final List<String> _frasesMotivacionales = [
'"Una mente fuerte construye un cuerpo imposible."',
  '"El dolor de hoy será tu fuerza de mañana."',
  '"No cuentes los días, haz que los días cuenten."',
  '"Supera tus límites antes de que tus límites te definan."',
  '"La disciplina vence al talento cuando el talento no se disciplina."',
  '"Un entrenamiento más cerca de tu mejor versión."',
  '"Rompe tus barreras en cada repetición."',
  '"Conviértete en la versión que juraste alcanzar."',
  '"Caerse está permitido, rendirse no es una opción."',
  '"El sudor es la grasa llorando la victoria."',
  '"El único entrenamiento malo es el que no se hace."',
  '"Tu único límite eres tú mismo."',
  '"No busques excusas, busca resultados."',
  '"La constancia transforma el esfuerzo en hábito."',
  '"El éxito no se regala, se entrena."',
  '"Donde la motivación se acaba, la disciplina empieza."',
  '"Cada repetición te acerca a la meta."',
  '"Hoy duele, mañana te fortalece."',
  '"El dolor es temporal, el orgullo de no rendirte es para siempre."',
  '"Transforma tus excusas en tus mayores fortalezas."',
  ];

  late String _fraseActual;
  Timer? _timerFrases;

  @override
  void initState() {
    super.initState();
    // 1. Elegir una frase aleatoria al iniciar la pantalla
    final random = Random();
    _fraseActual = _frasesMotivacionales[random.nextInt(_frasesMotivacionales.length)];

    // 2. Opcional: Cambiar la frase automáticamente cada 5 segundos de forma dinámica
    _timerFrases = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          int nuevoIndex;
          do {
            nuevoIndex = random.nextInt(_frasesMotivacionales.length);
          } while (_frasesMotivacionales[nuevoIndex] == _fraseActual && _frasesMotivacionales.length > 1);

          _fraseActual = _frasesMotivacionales[nuevoIndex];
        });
      }
    });
  }

  @override
  void dispose() {
    _timerFrases?.cancel(); // Cancelamos el temporizador al salir de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String nombreDia = (widget.diaRutina['nombre_dia'] ?? 'ESPALDA + BÍCEPS').toString().toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.fondoNegro,
      body: Stack(
        children: [
          // Imagen de fondo con el personaje (8.png)
          Positioned.fill(
            child: Image.asset(
              'assets/images/8.png',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: AppColors.fondoNegro),
            ),
          ),

          // Sombra/Gradiente inferior para contraste de textos
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón de volver atrás estilo minimalista
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
                  ),

                  const Spacer(),

                  // Título principal del día
                  Center(
                    child: Column(
                      children: [
                        Text(
                          nombreDia,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Oswald',
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.verdePrimario,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ✨ FRASE DINÁMICA CON ANIMACIÓN DE TRANSICIÓN SUAVE (Fade)
                        SizedBox(
                          height: 36, // Altura fija para evitar saltos en el layout
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: Text(
                              _fraseActual,
                              key: ValueKey<String>(_fraseActual),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Botón INICIAR RUTINA -> Navega a ejecucion_entrenamiento_screen.dart
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdePrimario,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.verdePrimario.withOpacity(0.4),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EjecucionEntrenamientoScreen(
                              rutina: widget.rutina,
                              diaRutina: widget.diaRutina,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'INICIAR RUTINA',
                        style: TextStyle(
                          fontFamily: 'Oswald',
                          color: AppColors.fondoNegro,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}