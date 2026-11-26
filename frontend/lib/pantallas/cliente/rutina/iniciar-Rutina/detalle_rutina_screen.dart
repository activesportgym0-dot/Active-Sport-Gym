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
  '"Entrena en silencio y deja que tus resultados hablen."',
  '"El hierro no miente: te da exactamente lo que pones."',
  '"Cada día es una nueva oportunidad para ser más fuerte."',
  '"No te rindas, el principio siempre es lo más difícil."',
  '"La grandeza se forja cuando nadie está mirando."',
  '"Haz hoy lo que otros no quieren para vivir mañana como otros no pueden."',
  '"Tu mente es tu mayor aliada o tu peor enemiga."',
  '"Un paso más cerca de la meta, sin importar qué tan lento vaya."',
  '"El cansancio pasa, el orgullo se queda."',
  '"Construye tu fuerza, construye tu futuro."',
  '"La constancia gana donde la prisa pierde."',
  '"No es suerte, es trabajo duro diario."',
  '"Hoy es un gran día para superar tu récord."',
  '"La confianza nace del esfuerzo cumplido."',
  '"Menos excusas, más acción."',
  '"Tu versión más fuerte te está esperando."',
  '"Cada serie cuenta, cada segundo suma."',
  '"El progreso real toma tiempo, no te apresures."',
  '"Levanta pesado, piensa claro, avanza firme."',
  '"La pasión enciende el motor, la disciplina lo mantiene andando."',
  '"No compitas con los demás, compite con quien eras ayer."',
  '"Las cicatrices y el sudor son pruebas de que lo intentaste."',
  '"El éxito es la suma de pequeños esfuerzos repetidos día tras día."',
  '"Haz de tu entrenamiento tu momento favorito del día."',
  '"La determinación convierte los sueños en realidad."',
  '"Si duele, es porque está cambiando."',
  '"Nunca subestimes el poder de un buen hábito."',
  '"Fuerza en los músculos, calma en la mente."',
  '"El sacrificio de hoy es la libertad de mañana."',
  '"Sé constante incluso cuando no tengas ganas."',
  '"Cada gota de sudor vale la pena."',
  '"No busques atajos, construye bases sólidas."',
  '"Tu actitud define tu altitud."',
  '"La paciencia y el esfuerzo siempre dan frutos."',
  '"Hoy sumamos, nunca restamos."',
  '"El límite lo pones tú, rómpelo."',
  '"Entrena con propósito, no solo por cumplir."',
  '"La verdadera fuerza está en no rendirse."',
  '"Pequeños pasos, grandes transformaciones."',
  '"Cree en el proceso, confía en tu trabajo."',
  '"El esfuerzo diario es el puente hacia tus metas."',
  '"Haz que cada entrenamiento cuente."',
  '"La disciplina es amar lo que haces incluso en los días difíciles."',
  '"No te compares, enfócate en tu propio camino."',
  '"Una repetición más cuando crees que ya no puedes."',
  '"El cuerpo sigue a una mente decidida."',
  '"Transforma el cansancio en combustible."',
  '"La victoria pertenece a los constantes."',
  '"Hoy construyes la salud que disfrutarás mañana."',
  '"Sin excusas, sin pretextos, solo acción."',
  '"Cada día cuenta en el camino a tu mejor versión."',
  '"La resiliencia te hace imparable."',
  '"Entrena duro, descansa bien, repite."',
  '"Los resultados llegan cuando no te rindes."',
  '"Hazlo por ti, por tu salud, por tu mente."',
  '"La fuerza interior se despierta en los retos."',
  '"No esperes motivación, crea disciplina."',
  '"Un buen hábito hoy cambia tu historia mañana."',
  '"El enfoque lo cambia todo."',
  '"Sigue avanzando, aunque sea despacio."',
  '"La voluntad es más fuerte que cualquier obstáculo."',
  '"Cada entrenamiento es un voto por la persona que quieres ser."',
  '"El sudor es el precio de la superación."',
  '"No retrocedas ni para tomar impulso si ya estás en camino."',
  '"Tu esfuerzo de hoy es tu tranquilidad mañana."',
  '"La energía que das es la fuerza que ganas."',
  '"Mantén la calma y sigue empujando."',
  '"El crecimiento ocurre fuera de lo cómodo."',
  '"Sé implacable con tus metas y amable con tu proceso."',
  '"Hoy es el día para dar tu máximo."',
  '"La constancia es la madre de los grandes cambios."',
  '"Cada reto superado te hace más capaz."',
  '"No te detengas ante el primer tropiezo."',
  '"Entrena tu mente tanto como tu cuerpo."',
  '"La grandeza empieza con una decisión."',
  '"Haz que tu esfuerzo hable más fuerte que tus palabras."',
  '"Un día difícil no arruina un buen proceso."',
  '"La perseverancia vence a cualquier duda."',
  '"Construye hábitos que te lleven lejos."',
  '"El trabajo silencioso siempre se nota."',
  '"Cree en tu capacidad de mejorar cada día."',
  '"La disciplina es el puente entre metas y logros."',
  '"Nunca es tarde para empezar a cuidarte."',
  '"Cada repetición es una promesa cumplida."',
  '"El éxito se cocina a fuego lento y con constancia."',
  '"No te conformes con menos de lo que mereces."',
  '"Tu mejor versión se construye ladrillo a ladrillo."',
  '"La fuerza no es solo física, es mental."',
  '"Hoy das un paso más, mañana verás el cambio."',
  '"La motivación va y viene, el compromiso queda."',
  '"Enfócate en lo que sí puedes controlar: tu esfuerzo."',
  '"Cada entrenamiento es una inversión segura."',
  '"La valentía también es empezar de nuevo."',
  '"No dejes para mañana la fuerza que puedes ganar hoy."',
  '"El progreso es progreso, sin importar el tamaño."',
  '"Sé tu propio motor cada mañana."',
  '"La constancia convierte lo difícil en natural."',
  '"Tu cuerpo puede más de lo que imaginas."',
  '"Haz de la superación un estilo de vida."',
  '"Hoy más fuerte que ayer, mañana más que hoy."',
  '"La disciplina te da libertad."',
  '"No aflojes cuando estés tan cerca."',
  '"Cada gota de esfuerzo acerca el resultado."',
  '"El compromiso diario construye resultados reales."',
  '"Superarte a ti mismo es la mejor victoria."',
  '"Entrena con hambre de mejorar."',
  '"La mente decide, el cuerpo responde."',
  '"No busques perfección, busca constancia."',
  '"Un entrenamiento más, una excusa menos."',
  '"La fuerza nace de enfrentar lo que cuesta."',
  '"Haz que cada día sume a tu meta."',
  '"El verdadero cambio empieza por dentro."',
  '"La paciencia también es parte del entrenamiento."',
  '"Sigue firme, los resultados están en camino."',
  '"Tu constancia inspira más de lo que crees."',
  '"Cada serie es un paso hacia la confianza."',
  '"No te rindas justo antes de ver el avance."',
  '"La disciplina es hacer lo necesario sin excusas."',
  '"Hoy eliges avanzar, no quedarte atrás."',
  '"El esfuerzo sostenido vence cualquier resistencia."',
  '"Construye un cuerpo fuerte y una mente serena."',
  '"La determinación no negocia con el cansancio."',
  '"Pequeñas victorias diarias hacen grandes historias."',
  '"Cree en lo que estás construyendo."',
  '"Cada día entrenas tu cuerpo y forjas tu carácter."',
  '"No hay logro grande sin constancia diaria."',
  '"Sé fiel a tu meta incluso en los días grises."',
  '"La fuerza de voluntad se entrena como un músculo."',
  '"Haz hoy lo que te hará sentir orgulloso esta noche."',
  '"El progreso real se mide en constancia."',
  '"Avanza con paso firme hacia lo que quieres."',
  '"La superación personal es un viaje, no una meta aislada."',
  '"Cada entrenamiento limpia el ruido mental."',
  '"No te detengas por miedo a fallar, aprende y sigue."',
  '"El compromiso contigo no tiene pausa."',
  '"Hoy sumas fuerza, salud y confianza."',
  '"La disciplina transforma deseos en hechos."',
  '"Tu mejor momento llega con el trabajo constante."',
  '"Sigue empujando, estás más cerca de lo que parece."',
  '"La constancia es el secreto detrás de todo avance."',
  '"Cada esfuerzo hoy es un regalo para tu futuro."',
  '"No pierdas de vista por qué empezaste."',
  '"Entrena con energía, enfócate con calma."',
  '"La fortaleza se construye día tras día."',
  '"Haz de tu rutina tu mejor aliada."',
  '"El avance lento también es avance."',
  '"Cree en tu proceso y respeta tus tiempos."',
  '"La disciplina es elegir el largo plazo."',
  '"Hoy das otro paso hacia tu meta."',
  '"El esfuerzo diario nunca se desperdicia."',
  '"Sé constante y verás de qué eres capaz."',
  '"Cada repetición te recuerda que no te rendiste."',
  '"La mente fuerte sostiene cualquier reto."',
  '"No esperes aplausos, celebra tu constancia."',
  '"Construye fuerza hoy, disfruta vitalidad mañana."',
  '"La perseverancia convierte lo imposible en posible."',
  '"Haz que cada entrenamiento tenga intención."',
  '"El cambio real exige paciencia y acción."',
  '"Sigue adelante, tu esfuerzo tiene sentido."',
  '"La disciplina es el combustible del éxito."',
  '"Hoy es otra oportunidad para mejorar."',
  '"Tu constancia define hasta dónde llegas."',
  '"Cada paso firme te acerca a tu objetivo."',
  '"No te rindas, estás formando tu mejor versión."',
  '"La fuerza se revela cuando decides continuar."',
  '"Entrena hoy con orgullo, avanza mañana con más fuerza."',
  '"La constancia diaria es tu mayor ventaja."',
  '"Haz lo que toca hoy, sin mirar atrás."',
  '"El progreso se construye con cada decisión diaria."',
  '"Sé valiente, sé constante, sé imparable."',
  '"Cada entrenamiento te hace un poco más fuerte."',
  '"La disciplina es más poderosa que la prisa."',
  '"Hoy das lo mejor que tienes, mañana das aún más."',
  '"El trabajo constante siempre deja huella."',
  '"No subestimes el valor de un día bien aprovechado."',
  '"La mente enfocada supera cualquier barrera."',
  '"Construye tu meta con paciencia y fuerza."',
  '"Cada repetición es un paso más cerca del objetivo."',
  '"La constancia hace que todo valga la pena."',
  '"Sigue avanzando, tu proceso está dando frutos."',
  '"Hoy eliges crecer, moverte y superarte."',
  '"La fuerza verdadera se sostiene en el tiempo."',
  '"Haz que tu constancia hable por ti."',
  '"El esfuerzo de hoy sostiene los logros de mañana."',
  '"No te detengas, lo mejor está por venir."',
  '"Cada día es un ladrillo más en tu meta."',
  '"La disciplina construye lo que la ilusión imagina."',
  '"Entrena con determinación y cierra con orgullo."',
  '"La perseverancia es la firma de quienes logran."',
  '"Hoy das otro paso sólido hacia tu mejor versión."',
  '"El progreso constante siempre supera al inicio explosivo."',
  '"Cree en tu fuerza, confía en tu ritmo."',
  '"Cada entrenamiento fortalece cuerpo, mente y carácter."',
  '"No bajes el ritmo, estás construyendo algo grande."',
  '"La constancia diaria transforma tu realidad."',
  '"Haz de cada día una prueba de tu compromiso."',
  '"La fuerza que buscas ya está en tu decisión de seguir."',
  '"Hoy entrenas tu presente y aseguras tu futuro."',
  '"La disciplina convierte cada intento en aprendizaje."',
  '"Sigue firme, cada paso cuenta en tu camino."',
  '"La superación diaria es la mejor recompensa."',
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
    _timerFrases = Timer.periodic(const Duration(seconds: 15), (timer) {
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
    final String nombreDia = (widget.diaRutina['nombre_dia'] ?? 'ENTRENAMIENTO').toString().toUpperCase();

    // Datos reales de la rutina que se va a entrenar (los que armó el usuario al crearla)
    final List ejercicios = widget.diaRutina['ejercicios'] as List? ?? [];
    final int totalSeries = ejercicios.fold<int>(0, (suma, e) => suma + ((e['series'] as List?)?.length ?? 0));
    final bool hayEjercicios = ejercicios.isNotEmpty;

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
                        const SizedBox(height: 10),

                        // Resumen de la rutina real: cuántos ejercicios y series tiene
                        Text(
                          hayEjercicios
                              ? '${ejercicios.length} ${ejercicios.length == 1 ? 'ejercicio' : 'ejercicios'}  •  $totalSeries ${totalSeries == 1 ? 'serie' : 'series'}'
                              : 'Esta rutina todavía no tiene ejercicios',
                          style: TextStyle(
                            color: hayEjercicios ? AppColors.verdePrimario : Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

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
                      onPressed: !hayEjercicios
                          ? null
                          : () {
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