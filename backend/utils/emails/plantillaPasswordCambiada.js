import { BrevoClient } from '@getbrevo/brevo';
import { obtenerAdjuntoLogo } from "../../config/mailer.js";

export const enviarCorreoPasswordCambiada = async (correoDestino, nombreUsuario) => {
  try {
    const brevo = new BrevoClient({
      apiKey: process.env.BREVO_API_KEY
    });

    const adjuntos = obtenerAdjuntoLogo();
    const tieneLogo = adjuntos.length > 0;

    const html = `
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #0b0f17; margin: 0; padding: 40px 10px; }
          .wrapper { max-width: 480px; margin: 0 auto; background: #121824; border-radius: 20px; overflow: hidden; border: 1px solid #1f293d; box-shadow: 0 20px 40px rgba(0,0,0,0.6); }
          .header { background: linear-gradient(180deg, #000000 0%, #121212 100%); padding: 30px 20px; text-align: center; border-bottom: 3px solid #22c55e; }
          .content { padding: 40px 30px; color: #f8fafc; text-align: center; }
          .badge-success { display: inline-block; background-color: rgba(34, 197, 94, 0.15); border: 1px solid #22c55e; color: #4ade80; font-size: 11px; font-weight: 800; padding: 6px 14px; border-radius: 50px; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 15px; }
          .title { font-size: 22px; font-weight: 900; color: #ffffff; margin: 0 0 12px 0; letter-spacing: -0.5px; }
          .subtitle { font-size: 14px; color: #94a3b8; margin: 0 0 25px 0; line-height: 1.6; }
          .warning-card { background: rgba(239, 68, 68, 0.08); border-left: 4px solid #ef4444; border-radius: 8px; padding: 14px 18px; text-align: left; margin-top: 25px; }
          .warning-text { font-size: 12px; color: #fca5a5; margin: 0; line-height: 1.5; }
          .footer { text-align: center; padding: 20px; font-size: 12px; color: #64748b; background-color: #0d121d; border-top: 1px solid #1f293d; }
        </style>
      </head>
      <body>
        <div class="wrapper">
          <div class="header">
            ${tieneLogo ? '<img src="cid:logoActiveGym" alt="Active Sport Gym" width="140" style="display: block; margin: 0 auto; border: 0; outline: none; text-decoration: none; width: 140px; height: auto;" />' : ''}
          </div>

          <div class="content">
            <span class="badge-success">✓ Seguridad Actualizada</span>
            <h1 class="title">Contraseña Modificada</h1>

            <p class="subtitle">
              Hola <strong style="color: #ffffff;">${nombreUsuario}</strong>, te confirmamos que la contraseña de tu cuenta ha sido modificada con éxito. Ya puedes iniciar sesión en la aplicación con tu nueva clave.
            </p>

            <div class="warning-card">
              <p class="warning-text">
                <strong style="color: #ffffff;">¿No fuiste tú?</strong> Si no realizaste esta acción, ponte en contacto de inmediato con el equipo de soporte para proteger tu cuenta.
              </p>
            </div>
          </div>

          <div class="footer">
            &copy; Active Sport Gym &bull; Todos los derechos reservados.
          </div>
        </div>
      </body>
      </html>
    `;

    const payload = {
      sender: {
        name: process.env.EMAIL_FROM_NAME || 'Active Sport Gym',
        email: process.env.EMAIL_USER
      },
      to: [{ email: correoDestino, name: nombreUsuario }],
      subject: "Contraseña actualizada exitosamente - Active Sport Gym",
      htmlContent: html
    };

    if (Array.isArray(adjuntos) && adjuntos.length > 0 && adjuntos[0].content) {
      payload.attachment = adjuntos;
    }

    const resultado = await brevo.transactionalEmails.sendTransacEmail(payload);
    return { exito: true, resultado };
  } catch (error) {
    console.error('Error enviando correo de contraseña cambiada con Brevo:', error);
    return { exito: false, error };
  }
};
