import { supabase } from "../config/supabase.js";

// Calcula el índice de masa corporal basado en peso (kg) y altura (m)
const calcularIMC = (peso, altura) => {
    if (peso && altura && altura > 0) {
        return parseFloat((peso / (altura * altura)).toFixed(2));
    }
    return null;
};

// Proyección de campos en orden organizado para las respuestas JSON
const CAMPOS_ORDENADOS = `
    id_progreso,
    id_historial_medida,
    id_usuario,
    fecha_registro,
    peso_actual,
    altura,
    imc,
    pecho,
    cintura,
    cadera,
    brazo_izquierdo,
    brazo_derecho,
    muslo_izquierdo,
    muslo_derecho,
    pantorrilla_izquierda,
    pantorrilla_derecha
`;

// Obtiene el registro de progreso más reciente del usuario
export const obtenerProgresoActualBD = async (id_usuario) => {
    const { data, error } = await supabase
        .from("progreso")
        .select(CAMPOS_ORDENADOS)
        .eq("id_usuario", id_usuario)
        .order("id_progreso", { ascending: false })
        .limit(1)
        .maybeSingle();

    return { data, error };
};

// Registra el historial y las medidas de forma vinculada
export const registrarNuevaMedidaBD = async (id_usuario, datos) => {
    const ahora = new Date();
    const fechaActual = ahora.toISOString().split("T")[0]; // YYYY-MM-DD
    const horaActual = ahora.toTimeString().split(" ")[0]; // HH:MM:SS

    // Paso 1: Crear la cabecera en la tabla 'historial_medidas'
    const { data: historialData, error: historialError } = await supabase
        .from("historial_medidas")
        .insert([{
            id_usuario,
            fecha_registro: fechaActual,
            hora_registro: horaActual
        }])
        .select()
        .single();

    if (historialError) {
        return { data: null, error: historialError };
    }

    const id_historial_medida = historialData.id_historial_medida;
    const imc = calcularIMC(datos.peso_actual, datos.altura);

    // Paso 2: Insertar el detalle del progreso vinculado al historial creado
    const payloadProgreso = {
        id_usuario,
        id_historial_medida,
        ...datos,
        imc,
        fecha_registro: fechaActual
    };

    const { data, error } = await supabase
        .from("progreso")
        .insert([payloadProgreso])
        .select(CAMPOS_ORDENADOS)
        .single();

    return { data, error };
};

// Obtiene todas las medidas registradas del usuario ordenadas por fecha
export const obtenerHistorialMedidasBD = async (id_usuario) => {
    const { data, error } = await supabase
        .from("progreso")
        .select(CAMPOS_ORDENADOS)
        .eq("id_usuario", id_usuario)
        .order("id_progreso", { ascending: false });

    return { data, error };
};

// Elimina una medida específica del historial
export const eliminarMedidaHistorialBD = async (id_progreso, id_usuario) => {
    const { data, error } = await supabase
        .from("progreso")
        .delete()
        .eq("id_progreso", Number(id_progreso))
        .eq("id_usuario", Number(id_usuario))
        .select(CAMPOS_ORDENADOS);

    return { data: data?.[0] || null, error };
};

// Elimina todas las medidas del historial del usuario
export const vaciarHistorialBD = async (id_usuario) => {
    const { data, error } = await supabase
        .from("progreso")
        .delete()
        .eq("id_usuario", Number(id_usuario))
        .select(CAMPOS_ORDENADOS);

    return { data, error };
};