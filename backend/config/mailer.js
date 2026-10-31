import fs from "fs";
import path from "path";

// Helper optimizado para adjuntos inline en Brevo
export const obtenerAdjuntoLogo = () => {
  try {
    const rutaLogo = path.resolve("./assets/images/logo.png");
    if (fs.existsSync(rutaLogo)) {
      const archivoBuffer = fs.readFileSync(rutaLogo);
      return [
        {
          content: archivoBuffer.toString("base64"),
          name: "logo.png",
          cid: "logoActiveGym" // 👈 Brevo usa la propiedad cid estándar junto con el nombre del archivo
        }
      ];
    }
  } catch (error) {
    console.error("No se pudo cargar el logo adjunto:", error);
  }
  return [];
};