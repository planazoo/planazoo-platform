const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();

// Configurar SendGrid (se debe configurar en Firebase Functions config)
// firebase functions:config:set sendgrid.key="YOUR_SENDGRID_API_KEY"
// firebase functions:config:set sendgrid.from="noreply@planazoo.app"
const SENDGRID_API_KEY = functions.config().sendgrid?.key || process.env.SENDGRID_API_KEY;
const FROM_EMAIL = functions.config().sendgrid?.from || process.env.FROM_EMAIL || 'noreply@planazoo.app';
const APP_BASE_URL = functions.config().app?.base_url || process.env.APP_BASE_URL || 'https://planazoo.app';

if (SENDGRID_API_KEY) {
  sgMail.setApiKey(SENDGRID_API_KEY);
}

// Template HTML para email de invitación (T104)
function getInvitationEmailTemplate(invitationData) {
  const { planName, inviterName, email, token, customMessage, expiresAt } = invitationData;
  const invitationLink = `${APP_BASE_URL}/invitation/${token}`;
  const expiresDate = new Date(expiresAt).toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });

  return `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Invitación a Plan</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      background-color: #f5f5f5;
    }
    .container {
      background-color: #ffffff;
      border-radius: 8px;
      padding: 40px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .header {
      text-align: center;
      margin-bottom: 30px;
    }
    .header h1 {
      color: #4285f4;
      margin: 0;
      font-size: 28px;
    }
    .content {
      margin-bottom: 30px;
    }
    .plan-name {
      font-size: 20px;
      font-weight: bold;
      color: #202124;
      margin: 20px 0;
    }
    .message-box {
      background-color: #f8f9fa;
      border-left: 4px solid #4285f4;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
    }
    .button-container {
      text-align: center;
      margin: 30px 0;
    }
    .button {
      display: inline-block;
      padding: 14px 28px;
      margin: 8px;
      text-decoration: none;
      border-radius: 4px;
      font-weight: 500;
      font-size: 16px;
      transition: background-color 0.3s;
    }
    .button-primary {
      background-color: #34a853;
      color: #ffffff;
    }
    .button-primary:hover {
      background-color: #2d8e47;
    }
    .button-secondary {
      background-color: #ea4335;
      color: #ffffff;
    }
    .button-secondary:hover {
      background-color: #d33b2c;
    }
    .link-text {
      word-break: break-all;
      color: #4285f4;
      font-size: 12px;
      margin-top: 10px;
    }
    .footer {
      margin-top: 30px;
      padding-top: 20px;
      border-top: 1px solid #e0e0e0;
      font-size: 12px;
      color: #666;
      text-align: center;
    }
    .expiry-notice {
      background-color: #fff3cd;
      border: 1px solid #ffc107;
      border-radius: 4px;
      padding: 12px;
      margin-top: 20px;
      font-size: 13px;
      color: #856404;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📅 Planazoo</h1>
    </div>
    
    <div class="content">
      <p>Hola,</p>
      
      <p><strong>${inviterName || 'Un usuario'}</strong> te ha invitado a unirte al plan:</p>
      
      <div class="plan-name">${planName}</div>
      
      ${customMessage ? `
      <div class="message-box">
        <strong>Mensaje personalizado:</strong><br>
        ${customMessage}
      </div>
      ` : ''}
      
      <p>Haz clic en uno de los botones para responder a la invitación:</p>
      
      <div class="button-container">
        <a href="${invitationLink}?action=accept" class="button button-primary">
          ✓ Aceptar Invitación
        </a>
        <a href="${invitationLink}?action=reject" class="button button-secondary">
          ✗ Rechazar
        </a>
      </div>
      
      <p class="link-text">
        Si los botones no funcionan, copia y pega este enlace en tu navegador:<br>
        <a href="${invitationLink}">${invitationLink}</a>
      </p>
      
      <div class="expiry-notice">
        ⚠️ <strong>Importante:</strong> Esta invitación expira el ${expiresDate}. 
        Asegúrate de responder antes de esa fecha.
      </div>
    </div>
    
    <div class="footer">
      <p>Este es un email automático de Planazoo. Por favor, no respondas a este mensaje.</p>
      <p>Si no esperabas esta invitación, puedes ignorar este email.</p>
    </div>
  </div>
</body>
</html>
  `;
}

// Cloud Function: Enviar email cuando se crea una invitación (T104)
exports.sendInvitationEmail = functions.firestore
  .document('plan_invitations/{invitationId}')
  .onCreate(async (snap, context) => {
    const invitation = snap.data();
    const invitationId = context.params.invitationId;

    // Solo procesar si es una invitación nueva (status: pending)
    if (invitation.status !== 'pending') {
      console.log(`Skipping email for invitation ${invitationId}: status is not pending`);
      return null;
    }

    // Verificar que tenemos SendGrid configurado
    if (!SENDGRID_API_KEY) {
      console.warn('SendGrid API key not configured. Email will not be sent.');
      return null;
    }

    try {
      // Obtener información del plan
      const planDoc = await admin.firestore().collection('plans').doc(invitation.planId).get();
      if (!planDoc.exists) {
        console.error(`Plan ${invitation.planId} not found`);
        return null;
      }
      const plan = planDoc.data();
      const planName = plan.name || 'Un plan';

      // Obtener información del organizador (si existe)
      let inviterName = 'Un usuario';
      if (invitation.invitedBy) {
        try {
          const userDoc = await admin.firestore().collection('users').doc(invitation.invitedBy).get();
          if (userDoc.exists) {
            const user = userDoc.data();
            inviterName = user.displayName || user.email || inviterName;
          }
        } catch (error) {
          console.warn(`Could not fetch inviter info: ${error.message}`);
        }
      }

      // Preparar datos del email
      const emailData = {
        planName,
        inviterName,
        email: invitation.email,
        token: invitation.token,
        customMessage: invitation.customMessage || null,
        expiresAt: invitation.expiresAt.toDate ? invitation.expiresAt.toDate().toISOString() : invitation.expiresAt,
      };

      // Generar HTML del email
      const htmlContent = getInvitationEmailTemplate(emailData);

      // Configurar email
      const msg = {
        to: invitation.email,
        from: FROM_EMAIL,
        subject: `Invitación a "${planName}" en Planazoo`,
        text: `${inviterName} te ha invitado a unirte al plan "${planName}" en Planazoo. 
        
Haz clic en este enlace para aceptar o rechazar la invitación:
${APP_BASE_URL}/invitation/${invitation.token}

Esta invitación expira el ${emailData.expiresAt}.

Este es un email automático. Por favor, no respondas a este mensaje.`,
        html: htmlContent,
      };

      // Enviar email
      await sgMail.send(msg);
      console.log(`Invitation email sent successfully to ${invitation.email} for invitation ${invitationId}`);

      return null;
    } catch (error) {
      console.error(`Error sending invitation email for ${invitationId}:`, error);
      
      // Si hay errores de SendGrid, loggear detalles
      if (error.response) {
        console.error('SendGrid error response:', error.response.body);
      }
      
      // No lanzar el error para que la función no falle (la invitación ya está creada)
      return null;
    }
  });


