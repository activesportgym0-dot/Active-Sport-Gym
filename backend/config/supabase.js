//IMPORTAMOS LAS VARIABLES DEL ENTORNO

import dotenv from 'dotenv/config'; //6.4k (gzipped: 2.8k)
import { createClient } from '@supabase/supabase-js'; //210.9K (gzipped: 52.9k)
//CREACION DE LA CONEXION CON SUPABASE
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

//VARIABLES DE CONEXION
if (!supabaseUrl || !supabaseKey) {
    console.error("❌Error: Las variables de entorno SUPABASE_URL y SUPABASE_KEY son requeridas.");
    process.exit(1); // Salir del proceso con un código de error
}
//CONEXION CON SUPABASE
export const supabase = createClient(supabaseUrl, supabaseKey);

export const conectaDB=()=>{
    console.log("✅Conexión a Supabase establecida correctamente.");
};