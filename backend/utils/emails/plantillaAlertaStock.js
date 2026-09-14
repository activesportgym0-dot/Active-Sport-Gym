import { transporter, obtenerAdjuntoLogo } from "../../config/mailer.js";

/**
 * Plantilla para notificar al Administrador cuando un producto se está agotando.
 */
export const enviarAlertaStockBajo = async ({ producto, stockActual, limiteMinimo }) => {
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
        .wrapper { max-width: 580px; margin: 0 auto; background: #121824; border-radius: 20px; overflow: hidden; border: 1px solid #1f293d; box-shadow: 0 20px 40px rgba(0,0,0,0.6); }
        
        /* ENCABEZADO NEGRO CON LÍNEA VERDE NEÓN */
        .header { background: linear-gradient(180deg, #000000 0%, #121212 100%); padding: 35px 20px; text-align: center; border-bottom: 3px solid #22c55e; }
        .logo { max-width: 140px; height: auto; display: block; margin: 0 auto; filter: drop-shadow(0 0 10px rgba(34,197,94,0.3)); }
        
        .content { padding: 40px 35px; color: #f8fafc; }
        
        /* BADGE ALERTA */
        .badge-alert { display: inline-block; background-color: rgba(239, 68, 68, 0.15); border: 1px solid #ef4444; color: #fca5a5; font-size: 11px; font-weight: 800; padding: 6px 14px; border-radius: 50px; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 15px; }
        
        .title { font-size: 24px; font-weight: 900; color: #ffffff; margin: 0 0 10px 0; letter-spacing: -0.5px; }
        .subtitle { font-size: 14px; color: #94a3b8; margin: 0 0 25px 0; line-height: 1.6; }
        
        /* TARJETA CON BORDE VERDE NEÓN */
        .card { background: #1a2332; border: 1px solid rgba(34, 197, 94, 0.3); border-radius: 16px; padding: 25px; box-shadow: inset 0 0 20px rgba(34, 197, 94, 0.05); }
        .card-header-text { font-size: 12px; font-weight: 800; color: #22c55e; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 15px; border-bottom: 1px solid #28354d; padding-bottom: 8px; }
        
        .stock-highlight { font-size: 20px; font-weight: 900; color: #ef4444; text-shadow: 0 0 10px rgba(239,68,68,0.4); }
        
        .footer { text-align: center; padding: 20px; font-size: 12px; color: #64748b; background-color: #0d121d; border-top: 1px solid #1f293d; }
      </style>
    </head>
    <body>
      <div class="wrapper">
        <div class="header">
          ${tieneLogo ? '<img src="cid:logoActiveGym" alt="Active Sport Gym" class="logo" />' : ''}
        </div>
        
        <div class="content">
          <div style="text-align: center;">
            <span class="badge-alert">⚠️ Alerta de Inventario</span>
            <h1 class="title">Stock Mínimo Alcanzado</h1>
            <p class="subtitle">Se requiere reabastecimiento para asegurar la disponibilidad de inventario en la tienda.</p>
          </div>

          <div class="card">
            <div class="card-header-text">📋 Detalles del Producto</div>
            
            <table style="width: 100%; border-collapse: collapse;">
              <tr style="border-bottom: 1px solid #28354d;">
                <td style="padding: 10px 0; color: #94a3b8; font-size: 14px; font-weight: 600;">Producto:</td>
                <td style="padding: 10px 0; color: #ffffff; font-size: 14px; font-weight: 800; text-align: right;">${producto.nombre}</td>
              </tr>
              <tr style="border-bottom: 1px solid #28354d;">
                <td style="padding: 10px 0; color: #94a3b8; font-size: 14px; font-weight: 600;">Categoría:</td>
                <td style="padding: 10px 0; color: #ffffff; font-size: 14px; font-weight: 700; text-align: right;">${producto.categoria || "General"}</td>
              </tr>
              <tr style="border-bottom: 1px solid #28354d;">
                <td style="padding: 10px 0; color: #94a3b8; font-size: 14px; font-weight: 600;">Stock Actual:</td>
                <td style="padding: 10px 0; text-align: right;" class="stock-highlight">${stockActual} ${stockActual === 1 ? 'unidad' : 'unidades'}</td>
              </tr>
              <tr>
                <td style="padding: 10px 0; color: #94a3b8; font-size: 14px; font-weight: 600;">Límite Permitido:</td>
                <td style="padding: 10px 0; color: #94a3b8; font-size: 14px; font-weight: 700; text-align: right;">${limiteMinimo} unidades</td>
              </tr>
            </table>
          </div>

          <p style="font-size: 13px; color: #64748b; margin-top: 25px; text-align: center; line-height: 1.5;">
            💡 Ingresa al panel de administración para reponer las existencias de este artículo.
          </p>
        </div>

        <div class="footer">
          Active Sport Gym - Sistema de Gestión de Inventarios
        </div>
      </div>
    </body>
    </html>
  `;

  const destinatario = process.env.EMAIL_ADMIN || process.env.EMAIL_USER;

  const opciones = {
    from: `"Active Sport Gym System" <${process.env.EMAIL_USER}>`,
    to: destinatario,
    subject: `⚠️ ALERTA: Stock Bajo en ${producto.nombre}`,
    html,
    attachments: adjuntos
  };

  return await transporter.sendMail(opciones);
};