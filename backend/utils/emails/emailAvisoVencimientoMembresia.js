import { BrevoClient } from '@getbrevo/brevo';
import { obtenerLogoEmailUrl } from "../../config/mailer.js";

// Evita que un nombre con caracteres especiales rompa el HTML del correo
const escaparHtml = (texto) =>
  String(texto ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");

// "2026-12-24" -> "24/12/2026"
const formatearFecha = (iso) => {
  const [a, m, d] = String(iso).slice(0, 10).split("-");
  return a && m && d ? `${d}/${m}/${a}` : String(iso);
};

const textoDias = (dias) => {
  if (dias <= 0) return "vence hoy";
  if (dias === 1) return "vence mañana";
  return `vence en ${dias} días`;
};

/**
 * Plantilla para avisar al CLIENTE que su membresía está por vencer.
 * Se envía cuando faltan 5 días o menos para la fecha de fin.
 */
export const enviarAvisoVencimientoMembresia = async ({ correo, nombre, fechaFin, diasRestantes }) => {
  try {
    const brevo = new BrevoClient({
      apiKey: process.env.BREVO_API_KEY
    });

    const logoUrl = await obtenerLogoEmailUrl();
    const cuando = textoDias(diasRestantes);
    const diasTexto =
      diasRestantes <= 0 ? "Hoy" : `${diasRestantes} ${diasRestantes === 1 ? "día" : "días"}`;

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

          /* BADGE DE AVISO */
          .badge-aviso { display: inline-block; background-color: rgba(245, 158, 11, 0.15); border: 1px solid #f59e0b; color: #fcd34d; font-size: 11px; font-weight: 800; padding: 6px 14px; border-radius: 50px; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 15px; }

          .title { font-size: 24px; font-weight: 900; color: #ffffff; margin: 0 0 10px 0; letter-spacing: -0.5px; }
          .subtitle { font-size: 14px; color: #94a3b8; margin: 0 0 25px 0; line-height: 1.6; }

          /* TARJETA CON BORDE VERDE NEÓN */
          .card { background: #1a2332; border: 1px solid rgba(34, 197, 94, 0.3); border-radius: 16px; padding: 25px; box-shadow: inset 0 0 20px rgba(34, 197, 94, 0.05); }
          .card-header-text { font-size: 12px; font-weight: 800; color: #22c55e; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 15px; border-bottom: 1px solid #28354d; padding-bottom: 8px; }

          .dias-highlight { font-size: 20px; font-weight: 900; color: #f59e0b; text-shadow: 0 0 10px rgba(245,158,11,0.4); }

          .footer { text-align: center; padding: 20px; font-size: 12px; color: #64748b; background-color: #0d121d; border-top: 1px solid #1f293d; }
        </style>
      </head>
      <body>
        <div class="wrapper">
          <div class="header">
            ${logoUrl ? `<img src="${logoUrl}" alt="Active Sport Gym" class="logo" />` : ""}
          </div>

          <div class="content">
            <div style="text-align: center;">
              <span class="badge-aviso">⏰ Aviso de Membresía</span>
              <h1 class="title">Tu membresía está por vencer</h1>
              <p class="subtitle">Hola ${escaparHtml(nombre)}, tu membresía en Active Sport Gym ${cuando}. Renuévala a tiempo para seguir entrenando sin interrupciones.</p>
            </div>

            <div class="card">
              <div class="card-header-text">📋 Detalles de tu membresía</div>

              <table style="width: 100%; border-collapse: collapse;">
                <tr style="border-bottom: 1px solid #28354d;">
                  <td style="padding: 10px 0; color: #94a3b8; font-size: 14px; font-weight: 600;">Fecha de vencimiento:</td>
                  <td style="padding: 10px 0; color: #ffffff; font-size: 14px; font-weight: 800; text-align: right;">${formatearFecha(fechaFin)}</td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; color: #94a3b8; font-size: 14px; font-weight: 600;">Tiempo restante:</td>
                  <td style="padding: 10px 0; text-align: right;" class="dias-highlight">${diasTexto}</td>
                </tr>
              </table>
            </div>

            <p style="font-size: 13px; color: #64748b; margin-top: 25px; text-align: center; line-height: 1.5;">
              💡 Acércate al gimnasio para renovar tu membresía. Cuando el administrador la actualice, la verás reflejada en la aplicación.
            </p>
          </div>

          <div class="footer">
            Active Sport Gym - Aviso automático de membresías
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
      to: [
        {
          email: correo,
          name: nombre
        }
      ],
      subject: `⏰ Tu membresía ${cuando} - Active Sport Gym`,
      htmlContent: html
    };

    const resultado = await brevo.transactionalEmails.sendTransacEmail(payload);
    console.log(`Aviso de vencimiento enviado a ${correo}`);
    return { exito: true, resultado };

  } catch (error) {
    console.error('Error enviando aviso de vencimiento con Brevo:', error);
    return { exito: false, error };
  }
};
