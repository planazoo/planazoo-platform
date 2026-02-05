const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Configuración: Prioridad Gmail SMTP > SendGrid
// Gmail SMTP (recomendado - solo Google)
const GMAIL_USER = functions.config().gmail?.user || process.env.GMAIL_USER;
const GMAIL_PASSWORD = functions.config().gmail?.password || process.env.GMAIL_PASSWORD;
const GMAIL_FROM = functions.config().gmail?.from || process.env.GMAIL_FROM || GMAIL_USER;

// SendGrid (alternativa externa)
const SENDGRID_API_KEY = functions.config().sendgrid?.key || process.env.SENDGRID_API_KEY;
const SENDGRID_FROM = functions.config().sendgrid?.from || process.env.SENDGRID_FROM;

// Email remitente (prioridad: Gmail > SendGrid > default)
const FROM_EMAIL = GMAIL_FROM || SENDGRID_FROM || 'noreply@planazoo.app';
const APP_BASE_URL = functions.config().app?.base_url || process.env.APP_BASE_URL || 'https://planazoo.app';

// Configurar SendGrid (si está disponible)
if (SENDGRID_API_KEY) {
  sgMail.setApiKey(SENDGRID_API_KEY);
}

// Configurar Nodemailer con Gmail SMTP (si está disponible)
let gmailTransporter = null;
if (GMAIL_USER && GMAIL_PASSWORD) {
  gmailTransporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: GMAIL_USER,
      pass: GMAIL_PASSWORD, // App Password de Gmail (16 caracteres)
    },
  });
  console.log('Gmail SMTP configurado correctamente');
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

    // Verificar que tenemos algún servicio de email configurado
    const useGmail = GMAIL_USER && GMAIL_PASSWORD && gmailTransporter;
    const useSendGrid = SENDGRID_API_KEY;
    
    if (!useGmail && !useSendGrid) {
      console.warn('No hay servicio de email configurado. Configura Gmail SMTP o SendGrid.');
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

      // Preparar contenido del email
      const emailSubject = `Invitación a "${planName}" en Planazoo`;
      const emailText = `${inviterName} te ha invitado a unirte al plan "${planName}" en Planazoo. 
        
Haz clic en este enlace para aceptar o rechazar la invitación:
${APP_BASE_URL}/invitation/${invitation.token}

Esta invitación expira el ${emailData.expiresAt}.

Este es un email automático. Por favor, no respondas a este mensaje.`;

      // Enviar email usando Gmail SMTP (prioridad) o SendGrid
      if (useGmail) {
        // Usar Gmail SMTP (solo Google)
        await gmailTransporter.sendMail({
          from: FROM_EMAIL,
          to: invitation.email,
          subject: emailSubject,
          text: emailText,
          html: htmlContent,
        });
        console.log(`Invitation email sent via Gmail SMTP to ${invitation.email} for invitation ${invitationId}`);
      } else if (useSendGrid) {
        // Usar SendGrid (alternativa externa)
        const msg = {
          to: invitation.email,
          from: FROM_EMAIL,
          subject: emailSubject,
          text: emailText,
          html: htmlContent,
        };
        await sgMail.send(msg);
        console.log(`Invitation email sent via SendGrid to ${invitation.email} for invitation ${invitationId}`);
      }

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

// Cloud Function: Enviar notificación push (Fase 1 - FCM Básico)
// 
// Uso: Llamar desde otra función o desde el cliente (con permisos admin)
// Parámetros:
//   - userId: ID del usuario que recibirá la notificación
//   - title: Título de la notificación
//   - body: Cuerpo del mensaje
//   - data: (opcional) Datos adicionales para la app
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  // Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Debes estar autenticado para enviar notificaciones'
    );
  }

  const { userId, title, body, data: notificationData } = data;

  // Validar parámetros requeridos
  if (!userId || !title || !body) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'userId, title y body son requeridos'
    );
  }

  try {
    // Obtener tokens FCM del usuario
    const tokensSnapshot = await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('fcmTokens')
      .get();

    if (tokensSnapshot.empty) {
      console.log(`No se encontraron tokens FCM para el usuario ${userId}`);
      return { success: false, message: 'Usuario no tiene tokens FCM registrados' };
    }

    // Extraer todos los tokens
    const tokens = tokensSnapshot.docs.map(doc => doc.data().token);

    // Preparar mensaje
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: notificationData || {},
      tokens: tokens, // Enviar a todos los dispositivos del usuario
    };

    // Enviar notificación usando Firebase Admin SDK
    const response = await admin.messaging().sendEachForMulticast(message);

    console.log(`Notificación enviada a ${response.successCount} de ${tokens.length} dispositivos`);

    if (response.failureCount > 0) {
      const failedTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
          console.error(`Error enviando a token ${tokens[idx]}: ${resp.error}`);
        }
      });

      // Eliminar tokens inválidos de Firestore
      if (failedTokens.length > 0) {
        const batch = admin.firestore().batch();
        failedTokens.forEach(token => {
          const tokenRef = admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('fcmTokens')
            .doc(token);
          batch.delete(tokenRef);
        });
        await batch.commit();
        console.log(`Eliminados ${failedTokens.length} tokens inválidos`);
      }
    }

    return {
      success: true,
      sent: response.successCount,
      failed: response.failureCount,
      total: tokens.length,
    };
  } catch (error) {
    console.error(`Error enviando notificación push a ${userId}:`, error);
    throw new functions.https.HttpsError(
      'internal',
      `Error enviando notificación: ${error.message}`
    );
  }
});


