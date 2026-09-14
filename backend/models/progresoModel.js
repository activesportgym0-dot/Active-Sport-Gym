import { supabase } from "../config/supabase.js";

// Calcula el índice de masa corporal basado en peso (kg) y altura (m)
const calcularIMC = (peso, altura) => {
    if (peso && altura && altura > 0) {
        return parseFloat((peso / (altura * altura)).toFixed(2));
    }
    return null;
};

// Proyeccion de campos en orden organizado para las respuestas JSON
const CAMPOS_ORDENADOS = `
    id_progreso,
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
        .order("fecha_registro", { ascending: false })
        .limit(1)
        .maybeSingle();

    return { data, error };
};

// Registra una nueva medida de progreso en la base de datos
export const registrarNuevaMedidaBD = async (id_usuario, datos) => {
    const imc = calcularIMC(datos.peso_actual, datos.altura);

    const payload = {
        id_usuario,
        ...datos,
        imc,
        fecha_registro: new Date().toISOString()
    };

    const { data, error } = await supabase
        .from("progreso")
        .insert([payload])
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
        .order("fecha_registro", { ascending: false });

    return { data, error };
};

// Elimina una medida especifica del historial
export const eliminarMedidaHistorialBD = async (id_progreso, id_usuario) => {
    const { data, error } = await supabase
        .from("progreso")
        .delete()
        .eq("id_progreso", Number(id_progreso))
        .eq("id_usuario", Number(id_usuario))
        .select(CAMPOS_ORDENADOS)
        .single();

    return { data, error };
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