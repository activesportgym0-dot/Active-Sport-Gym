import { transporter, obtenerAdjuntoLogo } from "../../config/mailer.js";

export const enviarCorreoNotificacionAdmin = async ({ nombreCliente, pedido, items }) => {
  const adjuntos = obtenerAdjuntoLogo();
  const tieneLogo = adjuntos.length > 0;

  // Garantizar el nombre del comprador si llega vacío o indefinido
  const comprador = nombreCliente && nombreCliente.trim() !== "" ? nombreCliente : "Usuario Registrado";

  let filasHtml = "";
  items.forEach((item) => {
    const nombre = item.productos?.nombre || "Producto";
    // Precio unitario individual de una sola unidad del producto
    const precioUnitario = item.productos?.precio || 0;

    filasHtml += `
      <tr>
        <td style="padding: 16px 18px; border-bottom: 1px solid #1f293d; font-size: 14px; color: #f8fafc; font-weight: 600;">${nombre}</td>
        <td style="padding: 16px 18px; border-bottom: 1px solid #1f293d; font-size: 14px; color: #94a3b8; text-align: center; font-weight: 700;">${item.cantidad}</td>
        <td style="padding: 16px 18px; border-bottom: 1px solid #1f293d; font-size: 14px; color: #22c55e; text-align: right; font-weight: 800;">$${Number(precioUnitario).toLocaleString("es-CO")}</td>
      </tr>
    `;
  });

  const html = `
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #0b0f17; margin: 0; padding: 40px 10px; }
        .wrapper { max-width: 620px; margin: 0 auto; background: #121824; border-radius: 20px; overflow: hidden; border: 1px solid #1f293d; box-shadow: 0 20px 40px rgba(0,0,0,0.6); }
        
        /* ENCABEZADO NEGRO CON BORDE VERDE NEÓN */
        .header { background: linear-gradient(180deg, #000000 0%, #121212 100%); padding: 35px 20px; text-align: center; border-bottom: 3px solid #22c55e; }
        .logo { max-width: 140px; height: auto; display: block; margin: 0 auto; filter: drop-shadow(0 0 10px rgba(34,197,94,0.3)); }
        
        .content { padding: 40px 35px; color: #f8fafc; }
        
        /* BADGE DE NOTIFICACIÓN ADMIN */
        .badge-admin { display: inline-block; background-color: rgba(34, 197, 94, 0.15); border: 1px solid #22c55e; color: #4ade80; font-size: 11px; font-weight: 800; padding: 6px 14px; border-radius: 50px; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 15px; }
        
        .title { font-size: 24px; font-weight: 900; color: #ffffff; margin: 0 0 20px 0; letter-spacing: -0.5px; }
        
        /* CARD DATOS DEL CLIENTE */
        .info-card { background: #1a2332; border: 1px solid rgba(34, 197, 94, 0.3); border-radius: 14px; padding: 18px 20px; margin-bottom: 25px; box-shadow: inset 0 0 15px rgba(34, 197, 94, 0.03); }
        
        /* TABLA DE PRODUCTOS */
        table { width: 100%; border-collapse: collapse; margin-top: 15px; background-color: #1a2332; border-radius: 14px; overflow: hidden; border: 1px solid #28354d; }
        th { background-color: #161e2e; padding: 14px 18px; font-size: 11px; font-weight: 800; color: #64748b; text-transform: uppercase; letter-spacing: 1px; border-bottom: 1px solid #28354d; }
        
        /* CAJA TOTAL */
        .total-box { background: linear-gradient(135deg, #162a21 0%, #102018 100%); border: 1px solid #22c55e; border-radius: 14px; padding: 20px; margin-top: 25px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 0 20px rgba(34, 197, 94, 0.1); }
        .total-val { font-size: 26px; font-weight: 900; color: #22c55e; text-shadow: 0 0 12px rgba(34, 197, 94, 0.4); margin: 0; }
        
        /* BOTÓN ESTÁTICO SIN ENLACE */
        .btn-admin { display: block; background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%); color: #000000; padding: 18px 25px; border-radius: 12px; font-weight: 900; font-size: 15px; margin-top: 30px; text-align: center; box-shadow: 0 6px 20px rgba(34, 197, 94, 0.3); text-transform: uppercase; letter-spacing: 1px; user-select: none; }
        
        .footer { text-align: center; padding: 20px; font-size: 12px; color: #64748b; background-color: #0d121d; border-top: 1px solid #1f293d; }
      </style>
    </head>
    <body>
      <div class="wrapper">
        <div class="header">
          ${tieneLogo ? '<img src="cid:logoActiveGym" alt="Active Sport Gym" class="logo" />' : ''}
        </div>

        <div class="content">
          <span class="badge-admin">Alerta de Ventas</span>
          <h1 class="title">🚨 ¡Nuevo Pedido Recibido!</h1>

          <div class="info-card">
            <p style="margin: 0 0 8px 0; font-size: 14px; color: #94a3b8;"><b style="color: #ffffff;">Cliente / Comprador:</b> ${comprador}</p>
            <p style="margin: 0; font-size: 14px; color: #94a3b8;"><b style="color: #ffffff;">Estado:</b> <span style="color: #f39c12; font-weight: 700;">⏳ Pendiente de revisión</span></p>
          </div>

          <p style="font-size: 13px; color: #22c55e; font-weight: 800; margin-bottom: 12px; text-transform: uppercase; letter-spacing: 1px;">
            Detalle del Pedido #${pedido.id_pedido}
          </p>

          <table>
            <thead>
              <tr>
                <th style="text-align: left;">Producto</th>
                <th style="text-align: center;">Cant.</th>
                <th style="text-align: right;">Precio C/U</th>
              </tr>
            </thead>
            <tbody>
              ${filasHtml}
            </tbody>
          </table>

          <div class="total-box">
            <span style="font-size: 12px; color: #86efac; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px;">Total a Cobrar:</span>
            <p class="total-val">$${Number(pedido.total).toLocaleString("es-CO")}</p>
          </div>

          <div class="btn-admin">
            ⚡ GESTIONAR PEDIDO EN EL PANEL
          </div>
        </div>

        <div class="footer">
          Notificación automática enviada por el Sistema Backend de Active Sport Gym.
        </div>
      </div>
    </body>
    </html>
  `;

  return await transporter.sendMail({
    from: `"Active Sport Gym System" <${process.env.EMAIL_USER}>`,
    to: process.env.EMAIL_ADMIN || process.env.EMAIL_USER,
    subject: `🚨 Nuevo Pedido #${pedido.id_pedido} - ${comprador}`,
    html,
    attachments: adjuntos
  });
};