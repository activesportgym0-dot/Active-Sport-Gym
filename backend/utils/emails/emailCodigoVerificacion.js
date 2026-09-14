import { BrevoClient } from '@getbrevo/brevo';
import { obtenerAdjuntoLogo } from "../../config/mailer.js";

export const enviarCodigoVerificacion = async (correoDestino, nombreDestino, codigo) => {
  try {
    const brevo = new BrevoClient({
      apiKey: process.env.BREVO_API_KEY
    });

    const adjuntos = obtenerAdjuntoLogo();

    // Estructura de envío de correo
    const payload = {
      subject: `${codigo} es tu código de verificación - Active Sport Gym`,
      sender: {
        name: process.env.EMAIL_FROM_NAME || 'Active Sport Gym',
        email: process.env.EMAIL_USER
      },
      to: [
        {
          email: correoDestino,
          name: nombreDestino
        }
      ],
      htmlContent: `
        <!DOCTYPE html>
        <html lang="es">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: 'Inter', sans-serif; background-color: #0b0f17; margin: 0; padding: 40px 10px; }
            .wrapper { max-width: 480px; margin: 0 auto; background: #121824; border-radius: 20px; border: 1px solid #1f293d; }
            .header { background: #000; padding: 30px; text-align: center; border-bottom: 3px solid #22c55e; }
            .content { padding: 40px 30px; text-align: center; color: #f8fafc; }
            .code-box { background: #1a2332; border: 2px dashed #22c55e; border-radius: 14px; padding: 20px; margin: 25px 0; }
            .code-text { font-size: 36px; font-weight: 900; letter-spacing: 10px; color: #22c55e; }
          </style>
        </head>
        <body>
          <div class="wrapper">
            <div class="header">
              <h2 style="color: #22c55e; margin: 0;">ACTIVE SPORT GYM</h2>
            </div>
            <div class="content">
              <h1>Verifica tu Correo</h1>
              <p>Hola <strong>${nombreDestino}</strong>, usa el siguiente código para completar tu registro:</p>
              <div class="code-box">
                <span class="code-text">${codigo}</span>
              </div>
              <p>Este código expira en 15 minutos.</p>
            </div>
          </div>
        </body>
        </html>
      `
    };

    // Solo agregar attachments si contiene elementos válidos con url o content
    if (Array.isArray(adjuntos) && adjuntos.length > 0 && (adjuntos[0].url || adjuntos[0].content)) {
      payload.attachment = adjuntos;
    }

    const resultado = await brevo.transactionalEmails.sendTransacEmail(payload);

    console.log('Correo enviado con éxito');
    return { exito: true, resultado };
  } catch (error) {
    console.error('Error enviando correo con Brevo:', error);
    return { exito: false, error };
  }
};