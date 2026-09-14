import { transporter, obtenerAdjuntoLogo } from "../../config/mailer.js";

/**
 * Plantilla para notificar al Cliente que un producto agotado vuelve a estar disponible.
 */
export const enviarCorreoStockDisponible = async ({ correoCliente, nombreCliente, producto }) => {
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
        .wrapper { max-width: 620px; margin: 0 auto; background: #121824; border-radius: 20px; overflow: hidden; border: 1px solid #1f293d; box-shadow: 0 20px 40px rgba(0,0,0,0.6); }
        
        /* ENCABEZADO NEGRO CON LÍNEA VERDE NEÓN */
        .header { background: linear-gradient(180deg, #000000 0%, #121212 100%); padding: 35px 20px; text-align: center; border-bottom: 3px solid #22c55e; }
        .logo { max-width: 140px; height: auto; display: block; margin: 0 auto; filter: drop-shadow(0 0 10px rgba(34,197,94,0.3)); }
        
        .content { padding: 40px 35px; color: #f8fafc; }
        
        /* BADGE DE STOCK DISPONIBLE */
        .badge-stock { display: inline-block; background-color: rgba(34, 197, 94, 0.15); border: 1px solid #22c55e; color: #4ade80; font-size: 11px; font-weight: 800; padding: 6px 14px; border-radius: 50px; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 15px; }
        
        .title { font-size: 24px; font-weight: 900; color: #ffffff; margin: 0 0 10px 0; letter-spacing: -0.5px; }
        .subtitle { font-size: 14px; color: #94a3b8; line-height: 1.6; margin: 0 0 25px 0; }
        
        /* CAJA DE DETALLES DEL PRODUCTO */
        .product-box { background: linear-gradient(135deg, #162a21 0%, #102018 100%); border: 1px solid #22c55e; border-radius: 16px; padding: 22px 25px; margin-bottom: 25px; box-shadow: 0 0 20px rgba(34, 197, 94, 0.12); }
        .product-box-title { font-size: 12px; color: #86efac; font-weight: 800; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px; border-bottom: 1px solid rgba(34, 197, 94, 0.2); padding-bottom: 8px; }
        .product-row { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 14px; color: #cbd5e1; }
        .product-row:last-child { margin-bottom: 0; }
        .product-label { color: #94a3b8; }
        .product-val { color: #ffffff; font-weight: 700; }
        .highlight-val { color: #22c55e; font-weight: 900; text-shadow: 0 0 8px rgba(34, 197, 94, 0.3); }

        .footer { text-align: center; padding: 20px; font-size: 12px; color: #64748b; background-color: #0d121d; border-top: 1px solid #1f293d; }
      </style>
    </head>
    <body>
      <div class="wrapper">
        <div class="header">
          ${tieneLogo ? '<img src="cid:logoActiveGym" alt="Active Sport Gym" class="logo" />' : ''}
        </div>

        <div class="content">
          <span class="badge-stock">🔥 Reabastecimiento</span>
          <h1 class="title">¡Tu producto ya está disponible!</h1>
          
          <p class="subtitle">
            Hola <strong style="color: #ffffff;">${nombreCliente || 'Atleta'}</strong>, el artículo que estabas esperando ya volvió a nuestro inventario.
          </p>

          <div class="product-box">
            <div class="product-box-title">Detalle del Producto</div>
            <div style="margin-bottom: 8px; font-size: 14px;">
              <span style="color: #94a3b8;">Producto: </span>
              <strong style="color: #ffffff; font-size: 16px;">${producto.nombre}</strong>
            </div>
            <div style="margin-bottom: 8px; font-size: 14px;">
              <span style="color: #94a3b8;">Precio: </span>
              <strong style="color: #ffffff;">$${Number(producto.precio).toLocaleString('es-CO')}</strong>
            </div>
            <div style="font-size: 14px;">
              <span style="color: #94a3b8;">Stock Disponible: </span>
              <strong style="color: #22c55e; font-size: 15px;">${producto.stock} unidades</strong>
            </div>
          </div>

          <p style="font-size: 13px; color: #64748b; margin: 0; line-height: 1.5; text-align: center;">
            Ingresa a la aplicación para realizar tu pedido antes de que se agoten nuevamente las unidades.
          </p>
        </div>

        <div class="footer">
          Active Sport Gym - Notificaciones de Producto
        </div>
      </div>
    </body>
    </html>
  `;

  const opciones = {
    from: `"Active Sport Gym" <${process.env.EMAIL_USER}>`,
    to: correoCliente,
    subject: `🔥 ¡Reabastecimiento! ${producto.nombre} ya está disponible`,
    html,
    attachments: adjuntos
  };

  return await transporter.sendMail(opciones);
};