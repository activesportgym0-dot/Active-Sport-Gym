import nodemailer from "nodemailer";
import fs from "fs";
import path from "path";

// Transporte actualizado para evitar bloqueos en Render (Puerto 587)
export const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 587,
  secure: false, // false para el puerto 587 (usa STARTTLS)
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