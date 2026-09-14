import { transporter, obtenerAdjuntoLogo } from "../../config/mailer.js";

export const enviarCorreoConfirmacionPedido = async ({ correoCliente, nombreCliente, pedido, items }) => {
  const adjuntos = obtenerAdjuntoLogo();
  const tieneLogo = adjuntos.length > 0;

  // Garantizar el nombre del cliente si llega vacío o indefinido
  const clienteNombre = nombreCliente && nombreCliente.trim() !== "" ? nombreCliente : "Cliente";

  // Configuración del enlace de WhatsApp Directo
  const numeroWhatsapp = (process.env.TELEFONO_GYM || "573115313005").replace(/\D/g, "");
  const mensajeWA = encodeURIComponent(
    `🏋️ ¡Hola Active Sport Gym! Acabo de hacer el pedido #${pedido.id_pedido} desde la app por un total de $${Number(pedido.total).toLocaleString("es-CO")}.`
  );
  const urlWhatsappDirecto = `https://wa.me/${numeroWhatsapp}?text=${mensajeWA}`;

  let filasHtml = "";
  items.forEach((item) => {
    const nombre = item.productos?.nombre || "Producto";
    const precioUnitario = item.productos?.precio || 0;

    filasHtml += `
      <tr>
        <td style="padding: 12px 14px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #1e293b; font-weight: 600;">${nombre}</td>
        <td style="padding: 12px 14px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #475569; text-align: center; font-weight: 700;">${item.cantidad}</td>
        <td style="padding: 12px 14px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #0f172a; text-align: right; font-weight: 700;">$${Number(precioUnitario).toLocaleString("es-CO")}</td>
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
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #0f172a; margin: 0; padding: 30px 10px; }
        .wrapper { max-width: 600px; margin: 0 auto; }
        .card { background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3); }
        .header { background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); padding: 35px 30px; text-align: center; border-bottom: 4px solid #22c55e; }
        .logo { max-width: 140px; margin-bottom: 12px; }
        .header-title { color: #ffffff; font-size: 22px; font-weight: 800; margin: 0; text-transform: uppercase; }
        .content { padding: 35px 30px; }
        .greeting { font-size: 18px; color: #0f172a; font-weight: 700; margin-top: 0; }
        table { width: 100%; border-collapse: separate; border-spacing: 0; margin-top: 15px; border-radius: 10px; overflow: hidden; border: 1px solid #e2e8f0; }
        th { background-color: #f8fafc; padding: 12px 14px; font-size: 11px; font-weight: 800; color: #475569; text-transform: uppercase; border-bottom: 1px solid #e2e8f0; }
        .total-box { background-color: #f1f5f9; border-radius: 10px; padding: 15px 20px; margin-top: 20px; text-align: right; }
        .total-val { font-size: 22px; font-weight: 800; color: #22c55e; margin: 0; }
        .btn-wa { display: inline-block; background-color: #25D366; color: #ffffff; padding: 16px 32px; text-decoration: none; border-radius: 50px; font-weight: 800; font-size: 15px; margin-top: 25px; box-shadow: 0 10px 15px -3px rgba(37, 211, 102, 0.4); text-transform: uppercase; }
        .footer { text-align: center; padding: 25px 20px; font-size: 12px; color: #94a3b8; }
      </style>
    </head>
    <body>
      <div class="wrapper">
        <div class="card">
          <div class="header">
            ${tieneLogo ? '<img src="cid:logoActiveGym" alt="Active Sport Gym" class="logo" />' : ''}
            <h1 class="header-title">¡Hemos recibido tu Pedido!</h1>
          </div>
          <div class="content">
            <p class="greeting">¡Hola, ${clienteNombre}! 👋</p>
            <p style="color: #475569; font-size: 15px; line-height: 1.5;">
              Gracias por tu compra en <b>Active Sport Gym</b>. Hemos registrado tu pedido <b>#${pedido.id_pedido}</b> y en breve un administrador lo revisará.
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
              <span style="font-size: 12px; color: #64748b; font-weight: 700; text-transform: uppercase;">Total Registrado:</span>
              <p class="total-val">$${Number(pedido.total).toLocaleString("es-CO")}</p>
            </div>

            <div style="text-align: center;">
              <a href="${urlWhatsappDirecto}" target="_blank" class="btn-wa">
                💬 Agilizar Pedido por WhatsApp
              </a>
            </div>
          </div>
        </div>
        <div class="footer">
          Active Sport Gym - Gracias por ser parte de nuestra comunidad.
        </div>
      </div>
    </body>
    </html>
  `;

  return await transporter.sendMail({
    from: `"Active Sport Gym" <${process.env.EMAIL_USER}>`,
    to: correoCliente,
    subject: `🛒 Pedido #${pedido.id_pedido} Recibido - Active Sport Gym`,
    html,
    attachments: adjuntos
  });
};