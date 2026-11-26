
// Primera barrera del chat (sin IA).
// Detecta operaciones matemáticas sueltas y evita consultas innecesarias a Groq.

const normalizar = (texto) =>
  texto
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/\s+/g, " ")
    .trim();

// Palabras relacionadas con el gimnasio.
// Si aparece alguna, esta barrera no bloquea el mensaje.
const PALABRAS_GIMNASIO =
  /\b(gym|gimnasio|ejercicios?|rutinas?|series?|repeticiones?|reps?|kg|kilos?|libras?|peso|pesos|pesas?|calorias?|kcal|proteinas?|carbohidratos?|grasa|macros?|imc|musculos?|pecho|piernas?|espalda|brazos?|hombros?|abdomen|abdominales|gluteos?|cardio|entren\w*|suplementos?|creatina|whey|dieta|membresias?|tienda|productos?|precios?|horarios?|promociones?|descuentos?|ofertas?|fuerza|resistencia|masa|calentamiento|estiramiento|levant\w*|quem\w*|adelgaz\w*|engord\w*|volumen|definicion|descanso|altura|estatura|talla|meta|objetivo)\b/;

// Operaciones formadas únicamente por números y operadores.
const SOLO_OPERACION =
  /^[\s\d+\-*\/\\x×÷^().,=%¿?¡!:]+$/;

// Detecta operadores matemáticos.
const TIENE_OPERADOR = /[+\-*\/\\x×÷^=%]/;

// Operaciones dentro de una frase:
// "cuánto es 7 por 8", "100 entre 4", "15 + 20".
const OPERACION_EN_FRASE =
  /\d+(?:[.,]\d+)?\s*(?:por|x|×|mas|\+|menos|-|entre|dividido(?:\s+entre|\s+por)?|\/|÷|\^)\s*\d+(?:[.,]\d+)?/;

// Peticiones de cálculo acompañadas de números.
const CALCULA_CON_NUMEROS =
  /\b(cuanto\s+(?:es|da|son|seria|sale|vale)|calcula\w*|resultado\s+de|suma\w*|resta\w*|resuelve\w*|resolver)\b[\s\S]{0,40}\d/;

// Palabras típicas de matemáticas.
const PALABRAS_MATEMATICAS =
  /\b(multiplic\w*|dividir|division|ecuacion\w*|derivada|integral|raiz cuadrada|elevado a|logaritmo|tablas? del? \d+|tabla de multiplicar)\b/;

export const esMatematicaSuelta = (texto) => {
  if (typeof texto !== "string") return false;

  const t = normalizar(texto);

  if (!t) return false;

  // Si habla del gimnasio, dejamos que el filtro de IA lo evalúe.
  if (PALABRAS_GIMNASIO.test(t)) return false;

  // Ejemplos: 2+2, 7*8, 15/3, 100-50.
  if (
    SOLO_OPERACION.test(t) &&
    /\d/.test(t) &&
    TIENE_OPERADOR.test(t)
  ) {
    return true;
  }

  // Operaciones dentro de frases.
  if (OPERACION_EN_FRASE.test(t)) return true;

  // Ejemplos: calcula 20 + 30.
  if (CALCULA_CON_NUMEROS.test(t)) return true;

  // Ejemplos: multiplicación, división, ecuaciones.
  if (PALABRAS_MATEMATICAS.test(t)) return true;

  return false;
};
