import nodemailer from "nodemailer";
import fs from "fs";
import path from "path";

// Transporte con IPv4 forzado para evitar el bloqueo en Render
export const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 587,
  secure: false,
  family: 4, // 👈 Esta línea fuerza el uso de IPv4 y evita el error ENETUNREACH
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  },
  tls: {
    rejectUnauthorized: false
  }
});

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