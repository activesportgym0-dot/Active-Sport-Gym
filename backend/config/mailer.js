import fs from "fs";
import path from "path";

// Helper para leer el logo y adaptarlo correctamente para Brevo (inline)
export const obtenerAdjuntoLogo = () => {
  try {
    const rutaLogo = path.resolve("./assets/images/logo.png");
    if (fs.existsSync(rutaLogo)) {
      const archivoBuffer = fs.readFileSync(rutaLogo);
      return [
        {
          content: archivoBuffer.toString("base64"),
          name: "logo.png",
          // 👈 Estas propiedades son vitales para que Brevo lo incruste en el HTML
          inline: true,
          contentId: "logoActiveGym" 
        }
      ];
    }
  } catch (error) {
    console.error("No se pudo cargar el logo adjunto:", error);
  }
  return [];
};