import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Tarjeta con una frase motivadora. Cambia cada día (según la fecha del teléfono),
/// así que no necesita internet ni base de datos.
class FraseDelDiaHome extends StatelessWidget {
  const FraseDelDiaHome({super.key});

  static const List<String> _frases = [
"El dolor que sientes hoy es la fuerza que sentirás mañana.",
    "No te detengas cuando estés cansado, detente cuando hayas terminado.",
    "La disciplina es hacer lo que tienes que hacer, incluso cuando no quieres.",
    "Tu único límite eres tú mismo.",
    "La constancia supera al talento cuando el talento no se esfuerza.",
    "No cuentes los días, haz que los días cuenten.",
    "El éxito no se da de la noche a la mañana. Es cuando cada día eres un poco mejor.",
    "Si no desafía tus límites, no te cambiará.",
    "Cuida tu cuerpo, es el único lugar que tienes para vivir.",
    "La diferencia entre lo imposible y lo posible reside en la determinación.",
    "Trabaja duro en silencio, deja que tu éxito haga todo el ruido.",
    "El cuerpo logra lo que la mente cree.",
    "Haz hoy lo que otros no harán, para que mañana puedas hacer lo que otros no pueden.",
    "No compitas con nadie, supera tu versión de ayer.",
    "El único entrenamiento malo es el que no se hace.",
    "La motivación te pone en marcha, el hábito te mantiene avanzando.",
    "La fuerza no viene de la capacidad física, sino de una voluntad indomable.",
    "Cada repetición te acerca a tu meta.",
    "No cuentes las calorías, haz que cada sesión valga la pena.",
    "Rendirse no es una opción cuando quieres ver resultados.",
    "El sudor de hoy es la recompensa de mañana.",
    "La mente siempre falla antes que el cuerpo.",
    "Prefiero sufrir el dolor de la disciplina que el dolor del arrepentimiento.",
    "Una hora de entrenamiento es solo el 4% de tu día. No hay excusas.",
    "Transforma el 'no puedo' en 'voy a demostrar que sí'.",
    "Lo que parece imposible hoy, mañana será tu calentamiento.",
    "El esfuerzo no se negocia.",
    "Construye tu cuerpo con paciencia, constancia y determinación.",
    "Cae siete veces, levántate ocho.",
    "Tu cuerpo soporta casi cualquier cosa, es a tu mente a la que tienes que convencer.",
    "Sé más fuerte que tus excusas.",
    "El progreso lento sigue siendo progreso.",
    "Los campeones se construyen cuando nadie los está mirando.",
    "La actitud determina la altitud de tus resultados.",
    "Entrena pesado, come sano, descansa bien y repite.",
    "No bajes la meta, aumenta el esfuerzo.",
    "La victoria pertenece a los que perseveran.",
    "Cada gota de sudor te acerca a tu mejor versión.",
    "El cambio no empieza en el gimnasio, empieza en tu cabeza.",
    "El dolor es temporal, el orgullo de haberlo logrado es para siempre.",
    "No busques tiempo, créalo.",
    "Un mal día en el gym sigue siendo mejor que un buen día en el sofá.",
    "La grandeza requiere sacrificio.",
    "Supera tus miedos y romperás tus marcas.",
    "No mires el reloj, haz lo que él hace: sigue adelante.",
    "Tus metas son más grandes que tu pereza.",
    "El hierro no miente. Las pesas siempre te darán lo que mereces.",
    "La disciplina te lleva a donde la motivación no alcanza.",
    "Concéntrate en la técnica, la fuerza llegará sola.",
    "Hazlo por ti, por tu salud y por tu paz mental.",
    "No hay atajos para los lugares a los que vale la pena llegar.",
    "Entrena con un propósito, no por obligación.",
    "Cada paso, por pequeño que sea, te acerca a tu destino.",
    "Acepta el desafío para que puedas sentir la euforia de la victoria.",
    "El único límite es el que te pones tú.",
    "El gimnasio es mi templo de disciplina.",
    "No desees que sea fácil, desea ser mejor.",
    "El secreto de avanzar es comenzar.",
    "Si caes en el camino, levántate con más peso en la barra.",
    "Conviértete en alguien que inspire a los demás.",
    "La perseverancia convierte el carbón en diamante.",
    "Hoy es un gran día para romper tu récord personal.",
    "Que tu esfuerzo sea más fuerte que tus dudas.",
    "Entrena duro hoy o sufre la derrota mañana.",
    "No te conformes con lo que necesitas, lucha por lo que mereces.",
    "Tu cuerpo es tu templo, mantenlo fuerte.",
    "Cada entrenamiento cuenta, cada repetición importa.",
    "El único día malo es aquel en el que no intentaste dar lo mejor.",
    "La constancia es la llave del éxito físico y mental.",
    "Tus excusas no queman calorías.",
    "El éxito empieza con la decisión de intentarlo.",
    "Levántate con determinación, acuéstate con satisfacción.",
    "Sé la versión de ti que siempre quisiste ser.",
    "No hay fuerza sin resistencia.",
    "El camino puede ser duro, pero el resultado vale la pena.",
    "Focus, fuerza y fe en el proceso.",
    "Entrena la mente para dominar el cuerpo.",
    "Las mejores batallas se ganan con constancia.",
    "Conquista tus mañanas y conquistarás tu día.",
    "La fuerza bruta no sirve si no hay enfoque mental.",
    "No pares hasta estar orgulloso.",
    "Pon a prueba tus límites cada día.",
    "El dolor pasa, el resultado se queda.",
    "Hoy vas a ser más fuerte que ayer.",
    "Un día a la vez, una serie a la vez.",
    "Nada que valga la pena se consigue fácil.",
    "Haz del ejercicio un hábito inolvidable.",
    "Convierte tus debilidades en tu mayor fortaleza.",
    "Tu determinación define tu destino.",
    "La paciencia y el esfuerzo construyen imperios.",
    "Entrena como un atleta, piensa como un campeón.",
    "No compitas con el de al lado, compite con tu versión previa.",
    "Siembra disciplina hoy para cosechar salud mañana.",
    "El verdadero cambio ocurre fuera de tu zona de confort.",
    "Tu cuerpo te agradecerá cada gota de esfuerzo.",
    "Nunca subestimes el poder de un entrenamiento constante.",
    "El enfoque constante disuelve cualquier obstáculo.",
    "Hoy es el mejor momento para empezar a construir tu meta.",
    "Fuerza, corazón y mente en cada repetición."
  ];

  String get _fraseDeHoy {
    final hoy = DateTime.now();
    final diaDelAnio = hoy.difference(DateTime(hoy.year, 1, 1)).inDays;
    return _frases[diaDelAnio % _frases.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.verdePrimario,
            AppColors.verdePrimario.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.verdePrimario.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Comillas grandes de adorno
          Positioned(
            right: -2,
            top: -14,
            child: Text(
              '”',
              style: TextStyle(
                fontSize: 90,
                height: 1,
                fontWeight: FontWeight.w900,
                color: AppColors.fondoNegro.withOpacity(0.15),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: AppColors.fondoNegro, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'FRASE DEL DÍA',
                    style: TextStyle(
                      color: AppColors.fondoNegro,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _fraseDeHoy.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Oswald',
                  color: AppColors.fondoNegro,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
