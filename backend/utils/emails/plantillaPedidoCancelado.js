import { transporter, obtenerAdjuntoLogo } from "../../config/mailer.js";

export const enviarCorreoPedidoCancelado = async ({ correoCliente, nombreCliente, id_pedido, motivo }) => {
  const adjuntos = obtenerAdjuntoLogo();
  const tieneLogo = adjuntos.length > 0;

  const clienteNombre = nombreCliente && nombreCliente.trim() !== "" ? nombreCliente : "Cliente";

  const html = `
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #0b0f17; margin: 0; padding: 40px 10px; }
        .wrapper { max-width: 620px; margin: 0 auto; background: #121824; border-radius: 20px; overflow: hidden; border: 1px solid #1f293d; box-shadow: 0 20px 40px rgba(0,0,0,0.6); }
        
        /* ENCABEZADO NEGRO CON LÍNEA VERDE NEÓN */
        .header { background: linear-gradient(180deg, #000000 0%, #121212 100%); padding: 35px 20px; text-align: center; border-bottom: 3px solid #22c55e; }
        .logo { max-width: 140px; height: auto; display: block; margin: 0 auto; filter: drop-shadow(0 0 10px rgba(34,197,94,0.3)); }
        
        .content { padding: 40px 35px; color: #f8fafc; }
        
        /* BADGE DE CANCELACIÓN */
        .badge-cancel { display: inline-block; background-color: rgba(239, 68, 68, 0.15); border: 1px solid #ef4444; color: #fca5a5; font-size: 11px; font-weight: 800; padding: 6px 14px; border-radius: 50px; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 15px; }
        
        .title { font-size: 24px; font-weight: 900; color: #ffffff; margin: 0 0 10px 0; letter-spacing: -0.5px; }
        .subtitle { font-size: 14px; color: #94a3b8; line-height: 1.6; margin: 0 0 25px 0; }
        
        /* CAJA DE MOTIVO DE CANCELACIÓN */
        .reason-box { background: rgba(239, 68, 68, 0.08); border-left: 4px solid #ef4444; border-radius: 12px; padding: 20px; margin-bottom: 25px; border-top: 1px solid rgba(239, 68, 68, 0.2); border-right: 1px solid rgba(239, 68, 68, 0.2); border-bottom: 1px solid rgba(239, 68, 68, 0.2); }
        .reason-title { font-size: 12px; color: #fca5a5; font-weight: 800; text-transform: uppercase; letter-spacing: 1px; margin: 0 0 6px 0; }
        .reason-text { font-size: 14px; color: #f8fafc; margin: 0; line-height: 1.5; font-weight: 600; }
        
        .footer { text-align: center; padding: 20px; font-size: 12px; color: #64748b; background-color: #0d121d; border-top: 1px solid #1f293d; }
      </style>
    </head>
    <body>
      <div class="wrapper">
        <div class="header">
          ${tieneLogo ? '<img src="cid:logoActiveGym" alt="Active Sport Gym" class="logo" />' : ''}
        </div>

        <div class="content">
          <span class="badge-cancel">❌ Pedido Cancelado</span>
          <h1 class="title">Actualización sobre tu Pedido #${id_pedido}</h1>
          
          <p class="subtitle">
            Hola, <strong style="color: #ffffff;">${clienteNombre}</strong>. Lamentamos informarte que tu pedido <strong style="color: #ffffff;">#${id_pedido}</strong> no pudo ser procesado y ha sido cancelado.
          </p>

          <div class="reason-box">
            <p class="reason-title">Motivo de la cancelación:</p>
            <p class="reason-text">${motivo || "Agotamiento de inventario o inconveniente con los datos del pedido."}</p>
          </div>

          <p style="font-size: 13px; color: #64748b; margin: 0; line-height: 1.5; text-align: center;">
            Si deseas realizar una nueva compra o revisar alternativas disponibles, no dudes en ingresar nuevamente a la aplicación.
          </p>
        </div>

        <div class="footer">
          Active Sport Gym - Gracias por tu comprensión.
        </div>
      </div>
    </body>
    </html>
  `;

  return await transporter.sendMail({
    from: `"Active Sport Gym" <${process.env.EMAIL_USER}>`,
    to: correoCliente,
    subject: `❌ Pedido #${id_pedido} Cancelado - Active Sport Gym`,
    html,
    attachments: adjuntos
  });
};