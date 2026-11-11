// Primera barrera del chat (sin IA, siempre igual): detecta matemáticas sueltas.
// Sirve aunque el filtro con IA falle, y no cuesta nada ni tarda.
// Si el mensaje habla de gimnasio (series, kg, calorías, rutina...), NO se bloquea aquí.

const normalizar = (texto) =>
  texto
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/\s+/g, " ")
    .trim();

// Si aparece alguna de estas palabras, el mensaje tiene que ver con el gimnasio
const PALABRAS_GIMNASIO =
  /\b(gym|gimnasio|ejercicios?|rutinas?|series?|repeticion(?:es)?|reps?|kg|kilos?|libras?|pes[oa]\w*|pesas?|calorias?|kcal|proteinas?|carbohidratos?|grasa|macros?|imc|musculos?|pecho|piernas?|espalda|brazos?|hombros?|abdomen|abdominales|gluteos?|cardio|entren\w*|suplementos?|creatina|whey|dieta|membresias?|tienda|productos?|precios?|horarios?|promo\w*|descuentos?|ofertas?|fuerza|resistencia|masa|calentamiento|estiramiento|levant\w*|quem\w*|adelgaz\w*|engord\w*|volumen|definicion|descanso|altura|estatura|talla|meta|objetivo)\b/;

// Solo números y signos: "2x2", "7*8", "15+27="
const SOLO_OPERACION = /^[\s\d+\-*/x×÷^().,=%¿?¡!:]+$/;
const TIENE_OPERADOR = /[+\-*/x×÷^=%]/;

// Operación dentro de una frase: "cuánto es 7 por 8", "100 entre 4"
const OPERACION_EN_FRASE =
  /\d+(?:[.,]\d+)?\s*(?:por|x|\*|×|mas|\+|menos|-|entre|dividido(?: entre| por)?|\/|÷|\^)\s*\d+(?:[.,]\d+)?/;

// "cuánto es / calcula / suma ..." acompañado de números
const CALCULA_CON_NUMEROS =
  /\b(cuanto (?:es|da|son|seria|sale|vale)|calcula\w*|resultado de|suma\w*|resta\w*|resuelve\w*|resolver)\b.*\d/;

// Palabras típicas de matemáticas aunque no haya números
const PALABRAS_MATEMATICAS =
  /\b(multiplic\w*|dividir|division|ecuacion\w*|derivada|integral|raiz cuadrada|elevado a|logaritmo|tablas? del? \d+|tabla de multiplicar)\b/;

export const esMatematicaSuelta = (texto) => {
  if (typeof texto !== "string") return false;
  const t = normalizar(texto);
  if (!t) return false;

  // Si habla del gimnasio, lo decide el filtro con IA, no esta regla
  if (PALABRAS_GIMNASIO.test(t)) return false;

  if (SOLO_OPERACION.test(t) && /\d/.test(t) && TIENE_OPERADOR.test(t)) return true;
  if (OPERACION_EN_FRASE.test(t)) return true;
  if (CALCULA_CON_NUMEROS.test(t)) return true;
  if (PALABRAS_MATEMATICAS.test(t)) return true;
  return false;
};