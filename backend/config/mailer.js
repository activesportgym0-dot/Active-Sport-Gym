import nodemailer from "nodemailer";
import fs from "fs";
import path from "path";

// Transporte con las credenciales de tu .env
export const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// Helper para adjuntar el logo si existe el archivo
export const obtenerAdjuntoLogo = () => {
  const rutaLogo = path.resolve("./assets/images/logo.png");
  if (fs.existsSync(rutaLogo)) {
    return [
      {
        filename: "logo.png",
        path: rutaLogo,
        cid: "logoActiveGym"
      }
    ];
  }
  return [];
};