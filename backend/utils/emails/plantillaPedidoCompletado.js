import { transporter, obtenerAdjuntoLogo } from "../../config/mailer.js";

export const enviarCorreoPedidoCompletado = async ({ correoCliente, nombreCliente, id_pedido }) => {
  const adjuntos = obtenerAdjuntoLogo();
  const tieneLogo = adjuntos.length > 0;

  const numeroWhatsapp = (process.env.TELEFONO_GYM || "573115313005").replace(/\D/g, "");
  const mensajeWA = encodeURIComponent(
    `🏋️ ¡Hola Active Sport Gym! Recibí la notificación de que mi pedido #${id_pedido} está completado. ¡Gracias!`
  );
  const urlWhatsappDirecto = `https://wa.me/${numeroWhatsapp}?text=${mensajeWA}`;

  const html = `
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #0b0f17; margin: 0; padding: 40px 10px; }
        .wrapper { max-width: 620px; margin: 0 auto; background: #121824; border-radius: 20px; overflow: hidden; border: 1px solid #1f293d; box-shadow: 0 20px 40px rgba(0,0,0,0.6); }
        
        /* ENCABEZADO NEGRO CON LÍNEA AZUL/VERDE NEÓN */
        .header { background: linear-gradient(180deg, #000000 0%, #121212 100%); padding: 35px 20px; text-align: center; border-bottom: 3px solid #3b82f6; }
        .logo { max-width: 140px; height: auto; display: block; margin: 0 auto; filter: drop-shadow(0 0 10px rgba(59,130,246,0.3)); }
        
        .content { padding: 40px 35px; color: #f8fafc; }
        
        /* BADGE DE ESTADO */
        .badge-completed { display: inline-block; background-color: rgba(59, 130, 246, 0.15); border: 1px solid #3b82f6; color: #60a5fa; font-size: 11px; font-weight: 800; padding: 6px 14px; border-radius: 50px; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 15px; }
        
        .title { font-size: 24px; font-weight: 900; color: #ffffff; margin: 0 0 10px 0; letter-spacing: -0.5px; }
        .subtitle { font-size: 14px; color: #94a3b8; line-height: 1.6; margin: 0 0 25px 0; }
        
        /* CAJA DE DETALLES RESPLANDECIENTE */
        .details-box { background: linear-gradient(135deg, #101f38 0%, #0d172a 100%); border: 1px solid #3b82f6; border-radius: 16px; padding: 22px 25px; margin-bottom: 25px; text-align: center; box-shadow: 0 0 20px rgba(59, 130, 246, 0.12); }
        .label { font-size: 12px; color: #93c5fd; font-weight: 800; text-transform: uppercase; letter-spacing: 1px; margin: 0 0 6px 0; }
        .val { font-size: 28px; color: #3b82f6; font-weight: 900; margin: 0; text-shadow: 0 0 12px rgba(59, 130, 246, 0.4); }
        
        /* BOTÓN WHATSAPP */
        .btn-whatsapp { display: block; background: linear-gradient(135deg, #25D366 0%, #1da851 100%); color: #ffffff; padding: 18px 25px; text-decoration: none; border-radius: 12px; font-weight: 900; font-size: 15px; text-align: center; box-shadow: 0 6px 20px rgba(37, 211, 102, 0.25); text-transform: uppercase; letter-spacing: 1px; }
        
        .footer { text-align: center; padding: 20px; font-size: 12px; color: #64748b; background-color: #0d121d; border-top: 1px solid #1f293d; }
      </style>
    </head>
    <body>
      <div class="wrapper">
        <div class="header">
          ${tieneLogo ? '<img src="cid:logoActiveGym" alt="Active Sport Gym" class="logo" />' : ''}
        </div>

        <div class="content">
          <span class="badge-completed">🎉 Pedido Entregado</span>
          <h1 class="title">🎉 ¡Tu pedido ha sido Completado!</h1>
          
          <p class="subtitle">
            ¡Hola, <strong style="color: #ffffff;">${nombreCliente}</strong>! Te informamos que tu pedido en <strong style="color: #ffffff;">Active Sport Gym</strong> ha sido entregado exitosamente. ¡Esperamos que disfrutes al máximo tus productos!
          </p>

          <div class="details-box">
            <p class="label">Estado del Pedido #${id_pedido}</p>
            <p class="val">ENTREGADO CON ÉXITO</p>
          </div>

          <p style="font-size: 13px; color: #64748b; margin-bottom: 20px; text-align: center; line-height: 1.5;">
            Si tienes alguna inquietud sobre tus productos o necesitas ayuda adicional, escríbenos a nuestro WhatsApp:
          </p>

          <a href="${urlWhatsappDirecto}" target="_blank" class="btn-whatsapp">
            💬 Soporte / Contactar por WhatsApp
          </a>
        </div>

        <div class="footer">
          Active Sport Gym - Tu entrenamiento, nuestro compromiso.
        </div>
      </div>
    </body>
    </html>
  `;

  return await transporter.sendMail({
    from: `"Active Sport Gym" <${process.env.EMAIL_USER}>`,
    to: correoCliente,
    subject: `🎉 ¡Tu Pedido #${id_pedido} ha sido Completado! - Active Sport Gym`,
    html,
    attachments: adjuntos
  });
};