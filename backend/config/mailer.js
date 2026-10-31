import nodemailer from "nodemailer";
import fs from "fs";
import path from "path";

// Configuración limpia y estandarizada para Nodemailer
export const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 587,
  secure: false, // false para puerto 587 (STARTTLS)
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  },
  tls: {
    rejectUnauthorized: false
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