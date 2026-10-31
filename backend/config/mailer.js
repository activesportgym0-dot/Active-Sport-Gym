import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { cloudinary } from "./cloudinary.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Logo local del proyecto: backend/assets/images/logo.png
const rutaLogo = path.resolve(__dirname, "../assets/images/logo.png");

// Se conserva la URL en memoria para no subir el mismo logo en cada correo.
let logoUrlEnCache = null;
let cargaLogoEnCurso = null;

export const obtenerLogoEmailUrl = async () => {
  if (process.env.LOGO_EMAIL_URL) {
    return process.env.LOGO_EMAIL_URL;
  }

  if (logoUrlEnCache) {
    return logoUrlEnCache;
  }

  if (cargaLogoEnCurso) {
    return cargaLogoEnCurso;
  }

  cargaLogoEnCurso = (async () => {
    if (!fs.existsSync(rutaLogo)) {
      console.error(`No se encontró el logo para los correos en: ${rutaLogo}`);
      return null;
    }

    const resultado = await cloudinary.uploader.upload(rutaLogo, {
      folder: "active_sport_gym",
      public_id: "logo_email",
      resource_type: "image",
      overwrite: true,
      use_filename: false,
      unique_filename: false
    });

    logoUrlEnCache = resultado.secure_url;
    return logoUrlEnCache;
  })();

  try {
    return await cargaLogoEnCurso;
  } catch (error) {
    console.error("No se pudo subir el logo de los correos a Cloudinary:", error);
    return null;
  } finally {
    cargaLogoEnCurso = null;
  }
};
