import fs from "fs";
import path from "path";

// Helper para leer el logo y convertirlo en un adjunto compatible con la API de Brevo
export const obtenerAdjuntoLogo = () => {
  try {
    const rutaLogo = path.resolve("./assets/images/logo.png");
    if (fs.existsSync(rutaLogo)) {
      const archivoBuffer = fs.readFileSync(rutaLogo);
      return [
        {
          content: archivoBuffer.toString("base64"), // 👈 Brevo necesita el contenido en base64
          name: "logo.png",
          inline: true, // Indica que es un archivo incrustado
          cid: "logoActiveGym" // El mismo ID que usas en el HTML src="cid:logoActiveGym"
        }
      ];
    }
  } catch (error) {
    console.error("No se pudo cargar el logo adjunto:", error);
  }
  return [];
};