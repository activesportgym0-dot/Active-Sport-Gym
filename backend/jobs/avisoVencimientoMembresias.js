import cron from "node-cron";
import { supabase } from "../config/supabase.js";
import { enviarAvisoVencimientoMembresia } from "../utils/emails/emailAvisoVencimientoMembresia.js";

// Cuántos días antes de que venza se avisa (a los 5 días o menos, una sola vez por membresía)
const DIAS_AVISO = 5;
const ZONA_HORARIA = "America/Bogota";

// Fecha de hoy en Colombia + un desplazamiento en días, como "YYYY-MM-DD"
const fechaColombia = (desplazamientoDias = 0) => {
    const base = new Date(new Date().toLocaleString("en-US", { timeZone: ZONA_HORARIA }));
    base.setDate(base.getDate() + desplazamientoDias);
    const a = base.getFullYear();
    const m = String(base.getMonth() + 1).padStart(2, "0");
    const d = String(base.getDate()).padStart(2, "0");
    return `${a}-${m}-${d}`;
};

const diasEntre = (desde, hasta) =>
    Math.round((Date.parse(`${hasta}T00:00:00Z`) - Date.parse(`${desde}T00:00:00Z`)) / 86400000);

/**
 * Busca las membresías activas a las que les quedan 5 días o menos y avisa por correo al cliente.
 * - Funciona igual para planes de meses o de años: solo mira la fecha de fin.
 * - Cada membresía se avisa una sola vez (se marca en aviso_vencimiento_en). Si el administrador
 *   renueva, se crea otra membresía y esa tendrá su propio aviso.
 * - Si el correo falla, no se marca y se reintenta en la siguiente revisión.
 */
export const revisarMembresiasPorVencer = async () => {
    const hoy = fechaColombia(0);
    const limite = fechaColombia(DIAS_AVISO);

    // 1. Membresías activas que todavía no vencen
    const { data: membresias, error } = await supabase
        .from("membresias")
        .select("id_membresia, id_usuario, fecha_fin, aviso_vencimiento_en")
        .eq("estado", "activa")
        .gte("fecha_fin", hoy);

    if (error) {
        console.error("Avisos de vencimiento: error al consultar membresías:", error);
        return { revisadas: 0, enviados: 0, fallidos: 0, error: error.message };
    }

    // 2. De cada cliente solo cuenta la que vence más tarde: si ya renovó, la anterior no avisa
    const ultimaPorUsuario = new Map();
    for (const m of membresias || []) {
        const actual = ultimaPorUsuario.get(m.id_usuario);
        if (!actual || String(m.fecha_fin) > String(actual.fecha_fin)) {
            ultimaPorUsuario.set(m.id_usuario, m);
        }
    }

    // 3. Solo las que están dentro de los 5 días y todavía no se avisaron
    const pendientes = [...ultimaPorUsuario.values()].filter(
        (m) => String(m.fecha_fin).slice(0, 10) <= limite && !m.aviso_vencimiento_en
    );

    if (pendientes.length === 0) {
        return { revisadas: ultimaPorUsuario.size, enviados: 0, fallidos: 0 };
    }

    // 4. Datos de los clientes a los que hay que avisar
    const { data: usuarios, error: errorUsuarios } = await supabase
        .from("usuarios")
        .select("id_usuario, nombre, correo, is_active")
        .in("id_usuario", pendientes.map((m) => m.id_usuario));

    if (errorUsuarios) {
        console.error("Avisos de vencimiento: error al consultar usuarios:", errorUsuarios);
        return { revisadas: ultimaPorUsuario.size, enviados: 0, fallidos: 0, error: errorUsuarios.message };
    }

    const usuariosPorId = new Map((usuarios || []).map((u) => [u.id_usuario, u]));
    let enviados = 0;
    let fallidos = 0;

    for (const membresia of pendientes) {
        const usuario = usuariosPorId.get(membresia.id_usuario);
        // Sin usuario, sin correo o con la cuenta desactivada no se envía nada
        if (!usuario || !usuario.correo || usuario.is_active === false) continue;

        const fechaFin = String(membresia.fecha_fin).slice(0, 10);
        const resultado = await enviarAvisoVencimientoMembresia({
            correo: usuario.correo,
            nombre: usuario.nombre,
            fechaFin,
            diasRestantes: diasEntre(hoy, fechaFin)
        });

        if (!resultado.exito) {
            fallidos++;
            continue;
        }

        const { error: errorMarca } = await supabase
            .from("membresias")
            .update({ aviso_vencimiento_en: new Date().toISOString() })
            .eq("id_membresia", membresia.id_membresia);

        if (errorMarca) {
            // Se envió pero no se pudo marcar: podría repetirse en la próxima revisión
            console.error("Avisos de vencimiento: no se pudo marcar el aviso:", errorMarca);
        }
        enviados++;
    }

    console.log(`Avisos de vencimiento: ${enviados} enviados, ${fallidos} fallidos`);
    return { revisadas: ultimaPorUsuario.size, enviados, fallidos };
};

/**
 * Deja programada la revisión todos los días a las 8:00 a. m. (hora de Colombia).
 * También hace una revisión poco después de arrancar el servidor, por si estaba apagado a esa hora.
 */
export const iniciarAvisosVencimiento = () => {
    cron.schedule(
        "0 8 * * *",
        () => {
            revisarMembresiasPorVencer().catch((e) =>
                console.error("Avisos de vencimiento: error inesperado:", e)
            );
        },
        { timezone: ZONA_HORARIA }
    );

    setTimeout(() => {
        revisarMembresiasPorVencer().catch((e) =>
            console.error("Avisos de vencimiento: error inesperado:", e)
        );
    }, 30 * 1000);

    console.log("Avisos de vencimiento de membresías programados (todos los días a las 8:00 a. m.)");
};
