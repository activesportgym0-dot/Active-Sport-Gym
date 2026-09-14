import { obtenerAdjuntoLogo } from "../../config/mailer.js";

export const plantillaCodigoRecuperacion = (nombreUsuario, codigo) => {
  return {
    subject: `${codigo} es tu código de verificación - Active Sport Gym`,
    attachments: obtenerAdjuntoLogo(),
    html: `
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #0b0f17; margin: 0; padding: 40px 10px; }
          .wrapper { max-width: 480px; margin: 0 auto; background: #121824; border-radius: 20px; overflow: hidden; border: 1px solid #1f293d; box-shadow: 0 20px 40px rgba(0,0,0,0.6); }
          
          /* ENCABEZADO Y CONTENEDOR DEL LOGO */
          .header { background: linear-gradient(180deg, #000000 0%, #121212 100%); padding: 30px 20px; text-align: center; border-bottom: 3px solid #22c55e; }
          .logo-container { width: 100%; text-align: center; margin: 0 auto; }
          .logo { max-width: 140px; height: auto; width: 100%; display: inline-block; filter: drop-shadow(0 0 10px rgba(34,197,94,0.3)); }
          
          .content { padding: 40px 30px; text-align: center; color: #f8fafc; }
          
          .badge-security { display: inline-block; background-color: rgba(34, 197, 94, 0.12); border: 1px solid #22c55e; color: #4ade80; font-size: 11px; font-weight: 800; padding: 6px 14px; border-radius: 50px; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 15px; }
          
          .title { font-size: 22px; font-weight: 900; color: #ffffff; margin: 0 0 10px 0; letter-spacing: -0.5px; }
          .subtitle { font-size: 14px; color: #94a3b8; margin: 0 0 25px 0; line-height: 1.6; }
          
          .code-box { background: linear-gradient(145deg, #1a2332 0%, #0d131f 100%); border: 2px dashed #22c55e; border-radius: 14px; padding: 20px 25px; margin: 25px 0; display: inline-block; box-shadow: 0 0 20px rgba(34, 197, 94, 0.15); }
          .code-text { font-size: 36px; font-weight: 900; letter-spacing: 10px; color: #22c55e; font-family: 'Courier New', Courier, monospace; text-shadow: 0 0 12px rgba(34, 197, 94, 0.5); }
          
          .footer-note { font-size: 12px; color: #64748b; margin-top: 25px; line-height: 1.5; }
          .footer { text-align: center; padding: 20px; font-size: 12px; color: #64748b; background-color: #0d121d; border-top: 1px solid #1f293d; }
        </style>
      </head>
      <body>
        <div class="wrapper">
          <div class="header">
            <div class="logo-container">
              <img src="cid:logoActiveGym" alt="Active Sport Gym" class="logo" />
            </div>
          </div>

          <div class="content">
            <span class="badge-security">🔒 Verificación de Cuenta</span>
            <h1 class="title">Código de Recuperación</h1>

            <p class="subtitle">
              Hola <strong style="color: #ffffff;">${nombreUsuario}</strong>, usa el siguiente código para restablecer la contraseña de tu cuenta:
            </p>

            <div class="code-box">
              <span class="code-text">${codigo}</span>
            </div>

            <p class="footer-note">
              ⏱️ Este código es válido durante <strong>15 minutos</strong>.<br>
              Si no realizaste esta solicitud, puedes ignorar este mensaje de forma segura.
            </p>
          </div>

          <div class="footer">
            &copy; Active Sport Gym &bull; Todos los derechos reservados.
          </div>
        </div>
      </body>
      </html>
    `
  };
};