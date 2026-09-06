const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
// googleapis se carga solo en getGmailClientForMailbox (eventos desde correo) para no bloquear el deploy si no está instalado
admin.initializeApp();

// --- Constantes para eventos desde correo (T134) ---
const RATE_LIMIT_EMAILS_PER_DAY = 50;
const PENDING_EMAIL_EVENTS_COLLECTION = 'pending_email_events';
const USERS_COLLECTION = 'users';
const EMAIL_TEMPLATES_COLLECTION = 'email_templates';

/**
 * Excepción temporal de unicidad (QA T134). Quitar: LISTA 142.
 * Extra hotmail en cuenta +cricla aunque sea principal del power admin.
 */
const INBOUND_EMAIL_UNIQUENESS_EXCEPTIONS = [
  { extraEmail: 'cricla@hotmail.com', primaryEmail: 'unplanazoo+cricla@gmail.com' },
];

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
const APP_BASE_URL = functions.config().app?.base_url || process.env.APP_BASE_URL || 'https://app.planoon.com';

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

// Template HTML para email de invitación (T104 + ficha de plan tipo InvitationPage)
function escapeHtml(value) {
  if (value == null || value === '') return '';
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function formatInviteDate(value) {
  try {
    const d = value && value.toDate ? value.toDate() : new Date(value);
    if (Number.isNaN(d.getTime())) return '';
    return d.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  } catch (_) {
    return '';
  }
}

function getInvitationEmailTemplate(invitationData) {
  const {
    planName,
    planDescription,
    planStartDate,
    planEndDate,
    inviterName,
    email,
    token,
    customMessage,
    expiresAt,
  } = invitationData;
  const invitationLink = `${APP_BASE_URL}/invitation/${token}`;
  const expiresDate = formatInviteDate(expiresAt) || formatInviteDate(new Date(expiresAt));
  const startLabel = formatInviteDate(planStartDate);
  const endLabel = formatInviteDate(planEndDate);
  const safeName = escapeHtml(planName || 'Un plan');
  const safeInviter = escapeHtml(inviterName || 'Un usuario');
  const safeEmail = escapeHtml(email || '');
  const safeDescription = escapeHtml(planDescription || '');
  const safeMessage = escapeHtml(customMessage || '');

  const detailsRows = [
    `<tr><td style="padding:8px 0;color:#5f6368;font-size:13px;">Plan</td><td style="padding:8px 0;font-weight:600;color:#202124;">${safeName}</td></tr>`,
  ];
  if (safeDescription) {
    detailsRows.push(
      `<tr><td style="padding:8px 0;color:#5f6368;font-size:13px;vertical-align:top;">Descripción</td><td style="padding:8px 0;color:#202124;">${safeDescription}</td></tr>`
    );
  }
  if (startLabel) {
    detailsRows.push(
      `<tr><td style="padding:8px 0;color:#5f6368;font-size:13px;">Inicio</td><td style="padding:8px 0;color:#202124;">${escapeHtml(startLabel)}</td></tr>`
    );
  }
  if (endLabel) {
    detailsRows.push(
      `<tr><td style="padding:8px 0;color:#5f6368;font-size:13px;">Fin</td><td style="padding:8px 0;color:#202124;">${escapeHtml(endLabel)}</td></tr>`
    );
  }
  if (safeEmail) {
    detailsRows.push(
      `<tr><td style="padding:8px 0;color:#5f6368;font-size:13px;">Invitado</td><td style="padding:8px 0;color:#202124;">${safeEmail}</td></tr>`
    );
  }

  return `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Invitación a ${safeName}</title>
</head>
<body style="margin:0;padding:0;background-color:#f0f2f5;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;line-height:1.5;color:#202124;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f0f2f5;padding:24px 12px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:560px;background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
          <tr>
            <td style="background:#1a5f4a;padding:28px 32px;text-align:center;">
              <div style="font-size:22px;font-weight:700;color:#ffffff;letter-spacing:0.02em;">Planoon</div>
              <div style="margin-top:8px;font-size:14px;color:rgba(255,255,255,0.85);">Te han invitado a un plan</div>
            </td>
          </tr>
          <tr>
            <td style="padding:32px;">
              <p style="margin:0 0 16px;font-size:16px;">Hola,</p>
              <p style="margin:0 0 20px;font-size:16px;"><strong>${safeInviter}</strong> te invita a unirte a este plan:</p>

              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#f8faf9;border:1px solid #dce8e3;border-radius:10px;padding:4px 16px;margin:0 0 24px;">
                ${detailsRows.join('')}
              </table>

              ${safeMessage ? `
              <div style="background:#eef6ff;border-left:4px solid #1a73e8;padding:14px 16px;margin:0 0 24px;border-radius:4px;">
                <div style="font-size:13px;font-weight:600;color:#174ea6;margin-bottom:6px;">Mensaje</div>
                <div style="font-size:15px;color:#174ea6;">${safeMessage}</div>
              </div>
              ` : ''}

              <p style="margin:0 0 16px;font-size:15px;color:#5f6368;">Responde con un clic:</p>
              <table role="presentation" cellspacing="0" cellpadding="0" style="margin:0 auto 16px;">
                <tr>
                  <td style="padding:6px;" align="center">
                    <a href="${invitationLink}?action=accept" style="display:inline-block;padding:14px 22px;background:#1a5f4a;color:#ffffff;text-decoration:none;border-radius:8px;font-weight:600;font-size:15px;">Aceptar invitación</a>
                  </td>
                  <td style="padding:6px;" align="center">
                    <a href="${invitationLink}?action=reject" style="display:inline-block;padding:14px 22px;background:#ffffff;color:#c5221f;text-decoration:none;border-radius:8px;font-weight:600;font-size:15px;border:1px solid #f5c2c0;">Rechazar</a>
                  </td>
                </tr>
              </table>
              <p style="margin:0 0 24px;text-align:center;">
                <a href="${invitationLink}" style="display:inline-block;padding:12px 20px;background:#f8faf9;color:#1a5f4a;text-decoration:none;border-radius:8px;font-weight:600;font-size:14px;border:1px solid #dce8e3;">Ver el plan</a>
              </p>

              <p style="margin:0 0 8px;font-size:12px;color:#80868b;word-break:break-all;">
                Si los botones no funcionan, usa este enlace al plan:<br>
                <a href="${invitationLink}" style="color:#1a5f4a;">${invitationLink}</a>
              </p>

              ${expiresDate ? `
              <div style="margin-top:20px;padding:12px 14px;background:#fff8e1;border:1px solid #ffe082;border-radius:8px;font-size:13px;color:#6d4c00;">
                Esta invitación caduca el <strong>${escapeHtml(expiresDate)}</strong>.
              </div>
              ` : ''}
            </td>
          </tr>
          <tr>
            <td style="padding:16px 32px 28px;border-top:1px solid #e8eaed;text-align:center;font-size:12px;color:#80868b;">
              <p style="margin:0 0 6px;">Email automático de Planoon. No respondas a este mensaje.</p>
              <p style="margin:0;">Si no esperabas esta invitación, puedes ignorarla.</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
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

      // Preparar datos del email (ficha alineada con InvitationPage)
      const emailData = {
        planName,
        planDescription: plan.description || null,
        planStartDate: plan.startDate || null,
        planEndDate: plan.endDate || null,
        inviterName,
        email: invitation.email,
        token: invitation.token,
        customMessage: invitation.customMessage || null,
        expiresAt: invitation.expiresAt,
      };

      // Generar HTML del email
      const htmlContent = getInvitationEmailTemplate(emailData);

      // Preparar contenido del email
      const emailSubject = `Invitación a "${planName}" en Planoon`;
      const startTxt = formatInviteDate(plan.startDate);
      const endTxt = formatInviteDate(plan.endDate);
      const datesTxt = startTxt && endTxt ? `\nFechas: ${startTxt} – ${endTxt}` : '';
      const descTxt = plan.description ? `\n${plan.description}` : '';
      const emailText = `${inviterName} te ha invitado a unirte al plan "${planName}" en Planoon.${datesTxt}${descTxt}

Ver el plan: ${APP_BASE_URL}/invitation/${invitation.token}
Aceptar: ${APP_BASE_URL}/invitation/${invitation.token}?action=accept
Rechazar: ${APP_BASE_URL}/invitation/${invitation.token}?action=reject

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

// Resolver invitación por token (Admin SDK) — lectura tras accept cuando rules niegan el doc.
exports.resolveInvitationByToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes estar autenticado.');
  }
  const token = data?.token;
  if (!token || typeof token !== 'string' || token.length < 10) {
    throw new functions.https.HttpsError('invalid-argument', 'Se requiere token de invitación.');
  }

  const db = admin.firestore();
  const uid = context.auth.uid;
  const authEmail = (context.auth.token.email || '').toLowerCase().trim();

  let invDoc = await db.collection('plan_invitations').doc(token).get();
  if (!invDoc.exists) {
    const snap = await db.collection('plan_invitations')
      .where('token', '==', token)
      .limit(1)
      .get();
    if (snap.empty) {
      return { found: false };
    }
    invDoc = snap.docs[0];
  }

  const inv = invDoc.data() || {};
  const invEmail = (inv.email || '').toLowerCase().trim();
  let emailMatches = authEmail === invEmail;
  if (!emailMatches) {
    const userDoc = await db.collection('users').doc(uid).get();
    if (userDoc.exists) {
      emailMatches = (userDoc.data().email || '').toLowerCase().trim() === invEmail;
    }
  }
  const planDoc = await db.collection('plans').doc(inv.planId).get();
  const isOwner = planDoc.exists && planDoc.data().userId === uid;
  if (!emailMatches && !isOwner) {
    throw new functions.https.HttpsError('permission-denied', 'No autorizado para esta invitación.');
  }

  const toIso = (v) => {
    if (!v) return null;
    if (v.toDate) return v.toDate().toISOString();
    try { return new Date(v).toISOString(); } catch (_) { return null; }
  };

  return {
    found: true,
    id: invDoc.id,
    planId: inv.planId || '',
    email: inv.email || '',
    token: inv.token || token,
    invitedBy: inv.invitedBy || null,
    role: inv.role || 'participant',
    customMessage: inv.customMessage || null,
    status: inv.status || 'pending',
    createdAt: toIso(inv.createdAt),
    expiresAt: toIso(inv.expiresAt),
    respondedAt: toIso(inv.respondedAt),
  };
});

// Cloud Function: Marcar invitación como aceptada (Admin SDK, evita reglas de cliente)
// El cliente crea la participación y luego llama a esta función para actualizar plan_invitations.
exports.markInvitationAccepted = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes estar autenticado.');
  }
  const token = data?.token;
  if (!token || typeof token !== 'string' || token.length < 10) {
    throw new functions.https.HttpsError('invalid-argument', 'Se requiere token de invitación.');
  }

  const db = admin.firestore();
  const uid = context.auth.uid;
  const authEmail = (context.auth.token.email || '').toLowerCase().trim();

  // Preferir doc ID = token (modelo actual)
  let invDoc = await db.collection('plan_invitations').doc(token).get();
  if (!invDoc.exists) {
    const invitationsSnap = await db.collection('plan_invitations')
      .where('token', '==', token)
      .limit(1)
      .get();
    if (invitationsSnap.empty) {
      throw new functions.https.HttpsError('not-found', 'Invitación no encontrada.');
    }
    invDoc = invitationsSnap.docs[0];
  }

  const inv = invDoc.data();
  const invEmail = (inv.email || '').toLowerCase().trim();

  let emailMatches = authEmail === invEmail;
  if (!emailMatches) {
    const userDoc = await db.collection('users').doc(uid).get();
    if (userDoc.exists) {
      const userEmail = (userDoc.data().email || '').toLowerCase().trim();
      emailMatches = userEmail === invEmail;
    }
  }
  if (!emailMatches) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'El email del usuario no coincide con el de la invitación.'
    );
  }

  // Idempotente: ya aceptada → éxito (re-tap del link del mail).
  if (inv.status === 'accepted') {
    return {
      success: true,
      alreadyProcessed: true,
      invitationId: invDoc.id,
      planId: inv.planId || null,
    };
  }

  if (inv.status !== 'pending') {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Invitación no está pendiente.'
    );
  }

  await invDoc.ref.update({
    status: 'accepted',
    respondedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log(`Invitation ${invDoc.id} marked accepted by ${uid}`);
  return { success: true, invitationId: invDoc.id, planId: inv.planId || null };
});

// Cloud Function: Marcar invitación como rechazada (Admin SDK, evita reglas de cliente)
exports.markInvitationRejected = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes estar autenticado.');
  }
  const token = data?.token;
  const planId = data?.planId;
  const db = admin.firestore();
  const uid = context.auth.uid;
  const authEmail = (context.auth.token.email || '').toLowerCase().trim();

  let invDoc = null;
  let inv = null;

  if (token && typeof token === 'string' && token.length >= 10) {
    // Preferir doc ID = token (modelo actual)
    const byId = await db.collection('plan_invitations').doc(token).get();
    if (byId.exists && byId.data().status === 'pending') {
      invDoc = byId;
      inv = byId.data();
    } else {
      const invitationsSnap = await db.collection('plan_invitations')
        .where('token', '==', token)
        .where('status', '==', 'pending')
        .limit(1)
        .get();
      if (!invitationsSnap.empty) {
        invDoc = invitationsSnap.docs[0];
        inv = invDoc.data();
      }
    }
  } else if (planId && typeof planId === 'string') {
    let userEmail = authEmail;
    if (!userEmail) {
      const userDoc = await db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userEmail = (userDoc.data().email || '').toLowerCase().trim();
      }
    }
    if (!userEmail) {
      throw new functions.https.HttpsError('failed-precondition', 'No se pudo resolver el email del usuario.');
    }
    const invitationsSnap = await db.collection('plan_invitations')
      .where('planId', '==', planId)
      .where('email', '==', userEmail)
      .where('status', '==', 'pending')
      .limit(1)
      .get();
    if (!invitationsSnap.empty) {
      invDoc = invitationsSnap.docs[0];
      inv = invDoc.data();
    }
  } else {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Se requiere token o planId de invitación.'
    );
  }

  if (!invDoc || !inv) {
    // Sin doc de invitación: puede ser solo participación pending (invitación directa).
    return { success: true, invitationId: null, skipped: true };
  }

  const invEmail = (inv.email || '').toLowerCase().trim();
  let emailMatches = authEmail === invEmail;
  if (!emailMatches) {
    const userDoc = await db.collection('users').doc(uid).get();
    if (userDoc.exists) {
      const userEmail = (userDoc.data().email || '').toLowerCase().trim();
      emailMatches = userEmail === invEmail;
    }
  }
  // También permitir si el uid tiene participación pending en ese plan
  let participationMatches = false;
  if (!emailMatches && inv.planId) {
    const partSnap = await db.collection('plan_participations')
      .where('planId', '==', inv.planId)
      .where('userId', '==', uid)
      .where('status', '==', 'pending')
      .limit(1)
      .get();
    participationMatches = !partSnap.empty;
  }
  if (!emailMatches && !participationMatches) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'El email del usuario no coincide con el de la invitación.'
    );
  }

  await invDoc.ref.update({
    status: 'rejected',
    respondedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log(`Invitation ${invDoc.id} marked rejected by ${uid}`);
  return { success: true, invitationId: invDoc.id };
});

// Cloud Function: Crear notificaciones in-app cuando se publica un aviso en un plan
// Las reglas de Firestore solo permiten que cada usuario cree en users/{userId}/notifications,
// por tanto el cliente no puede crear notificaciones para otros; esta función usa Admin SDK.
exports.onCreateAnnouncementNotifyParticipants = functions.firestore
  .document('plans/{planId}/announcements/{announcementId}')
  .onCreate(async (snap, context) => {
    const { planId, announcementId } = context.params;
    const announcement = snap.data();
    const authorUserId = announcement.userId || '';
    const message = announcement.message || '';
    const type = announcement.type || 'info';
    const createdAt = announcement.createdAt || admin.firestore.Timestamp.now();

    if (!authorUserId || !message) {
      console.warn(`Announcement ${announcementId} missing userId or message, skipping notifications`);
      return null;
    }

    const db = admin.firestore();

    try {
      const planDoc = await db.collection('plans').doc(planId).get();
      const planName = planDoc.exists && planDoc.data().name ? planDoc.data().name : 'Un plan';

      const participationsSnap = await db.collection('plan_participations')
        .where('planId', '==', planId)
        .where('isActive', '==', true)
        .get();

      const participantIds = [];
      participationsSnap.docs.forEach((doc) => {
        const uid = doc.data().userId;
        if (uid && uid !== authorUserId) participantIds.push(uid);
      });

      if (participantIds.length === 0) {
        console.log(`No other participants to notify for announcement ${announcementId}`);
        return null;
      }

      let title;
      const body = message.length > 100 ? message.substring(0, 100) + '...' : message;
      if (type === 'urgent') {
        title = `🚨 Aviso urgente en "${planName}"`;
      } else if (type === 'important') {
        title = `⚠️ Aviso importante en "${planName}"`;
      } else {
        title = `📢 Nuevo aviso en "${planName}"`;
      }

      const batch = db.batch();
      for (const userId of participantIds) {
        const notifRef = db.collection('users').doc(userId).collection('notifications').doc();
        batch.set(notifRef, {
          userId,
          type: 'announcement',
          title,
          body,
          planId,
          isRead: false,
          createdAt,
          data: {
            announcementType: type,
            announcementUserId: authorUserId,
          },
        });
      }
      await batch.commit();
      console.log(`Created ${participantIds.length} notification(s) for announcement ${announcementId} in plan ${planId}`);
      return null;
    } catch (error) {
      console.error(`Error creating notifications for announcement ${announcementId}:`, error);
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
// T225: Proxy Places API (New) para evitar CORS en Flutter web
const PLACES_API_KEY = functions.config().places?.api_key || process.env.PLACES_API_KEY;
const PLACES_BASE = 'https://places.googleapis.com/v1';

exports.placesAutocomplete = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes estar autenticado.');
  }
  if (!PLACES_API_KEY) {
    throw new functions.https.HttpsError('failed-precondition', 'Places API key no configurada (functions.config().places.api_key).');
  }
  const { input, sessionToken, languageCode, includedPrimaryTypes } = data || {};
  if (!input || typeof input !== 'string' || input.trim().length < 2) {
    return { suggestions: [] };
  }
  const body = {
    input: input.trim(),
    ...(sessionToken && { sessionToken }),
    ...(languageCode && { languageCode }),
    ...(includedPrimaryTypes && includedPrimaryTypes.length && { includedPrimaryTypes }),
  };
  const res = await fetch(`${PLACES_BASE}/places:autocomplete`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'X-Goog-Api-Key': PLACES_API_KEY },
    body: JSON.stringify(body),
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    console.warn('Places autocomplete error', res.status, JSON.stringify(json).slice(0, 300));
    return { suggestions: [] };
  }
  return json;
});

exports.placesDetails = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes estar autenticado.');
  }
  if (!PLACES_API_KEY) {
    throw new functions.https.HttpsError('failed-precondition', 'Places API key no configurada.');
  }
  const { placeId, sessionToken, languageCode } = data || {};
  if (!placeId || typeof placeId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'placeId es requerido.');
  }
  const params = new URLSearchParams();
  if (sessionToken) params.set('sessionToken', sessionToken);
  if (languageCode) params.set('languageCode', languageCode);
  const url = `${PLACES_BASE}/places/${encodeURIComponent(placeId)}${params.toString() ? `?${params}` : ''}`;
  const headers = {
    'X-Goog-Api-Key': PLACES_API_KEY,
    'X-Goog-FieldMask': 'id,name,displayName,formattedAddress,location,websiteUri,nationalPhoneNumber,internationalPhoneNumber',
  };
  const res = await fetch(url, { headers });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    const errMsg = json.error?.message || json.message || JSON.stringify(json).slice(0, 200);
    console.warn('Places details error', res.status, errMsg, json);
    throw new functions.https.HttpsError(
      'internal',
      `Error al obtener detalles del lugar (${res.status}): ${errMsg}`,
    );
  }
  return json;
});

exports.placesTimezone = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes estar autenticado.');
  }
  if (!PLACES_API_KEY) {
    throw new functions.https.HttpsError('failed-precondition', 'Places API key no configurada.');
  }
  const { lat, lng, timestamp } = data || {};
  if (typeof lat !== 'number' || typeof lng !== 'number') {
    throw new functions.https.HttpsError('invalid-argument', 'lat y lng son requeridos.');
  }

  const ts = Number.isFinite(timestamp) ? Math.floor(timestamp) : Math.floor(Date.now() / 1000);
  const params = new URLSearchParams({
    location: `${lat},${lng}`,
    timestamp: `${ts}`,
    key: PLACES_API_KEY,
  });
  const url = `https://maps.googleapis.com/maps/api/timezone/json?${params.toString()}`;
  const res = await fetch(url);
  const json = await res.json().catch(() => ({}));
  if (!res.ok || json.status !== 'OK') {
    const errMsg = json.errorMessage || json.status || `HTTP ${res.status}`;
    console.warn('Places timezone error', errMsg, json);
    throw new functions.https.HttpsError(
      'internal',
      `Error al obtener timezone (${res.status}): ${errMsg}`,
    );
  }
  return {
    timeZoneId: json.timeZoneId || null,
    timeZoneName: json.timeZoneName || null,
    rawOffset: json.rawOffset ?? null,
    dstOffset: json.dstOffset ?? null,
  };
});

// T246: Amadeus On-Demand Flight Status — rellenar evento desplazamiento por número de vuelo
const AMADEUS_CLIENT_ID = functions.config().amadeus?.client_id || process.env.AMADEUS_CLIENT_ID;
const AMADEUS_CLIENT_SECRET = functions.config().amadeus?.client_secret || process.env.AMADEUS_CLIENT_SECRET;
const AMADEUS_BASE = functions.config().amadeus?.base || process.env.AMADEUS_BASE || 'https://test.api.amadeus.com';

function parseFlightNumber(input) {
  if (!input || typeof input !== 'string') return null;
  const s = input.trim().toUpperCase();
  const match = s.match(/^([A-Z0-9]{2})(\d{1,5})$/);
  if (match) return { carrierCode: match[1], flightNumber: match[2] };
  return null;
}

async function getAmadeusToken() {
  const body = new URLSearchParams({
    grant_type: 'client_credentials',
    client_id: AMADEUS_CLIENT_ID,
    client_secret: AMADEUS_CLIENT_SECRET,
  });
  const res = await fetch(`${AMADEUS_BASE}/v1/security/oauth2/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: body.toString(),
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok || !json.access_token) {
    console.warn('Amadeus token error', res.status, json);
    return null;
  }
  return json.access_token;
}

exports.flightStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes estar autenticado.');
  }
  if (!AMADEUS_CLIENT_ID || !AMADEUS_CLIENT_SECRET) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Amadeus API no configurada (functions.config().amadeus.client_id y client_secret).'
    );
  }
  const { flightNumber: flightNumberInput, date: dateStr } = data || {};
  if (!flightNumberInput || typeof flightNumberInput !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'flightNumber es requerido (ej: IB6842).');
  }
  const parsed = parseFlightNumber(flightNumberInput);
  if (!parsed) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Formato de número de vuelo no válido. Usa código IATA (ej: IB6842, AF1135).'
    );
  }
  const scheduledDate = dateStr && /^\d{4}-\d{2}-\d{2}$/.test(String(dateStr).trim())
    ? String(dateStr).trim()
    : new Date().toISOString().slice(0, 10);
  const token = await getAmadeusToken();
  if (!token) {
    throw new functions.https.HttpsError('internal', 'No se pudo obtener token de Amadeus.');
  }
  const params = new URLSearchParams({
    carrierCode: parsed.carrierCode,
    flightNumber: parsed.flightNumber,
    scheduledDepartureDate: scheduledDate,
  });
  const url = `${AMADEUS_BASE}/v2/schedule/flights?${params.toString()}`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    const errMsg = json.errors?.[0]?.detail || json.error_description || JSON.stringify(json).slice(0, 200);
    console.warn('Amadeus flight status error', res.status, errMsg);
    throw new functions.https.HttpsError(
      'internal',
      `Error al obtener datos del vuelo (${res.status}): ${errMsg}`
    );
  }
  const dataList = Array.isArray(json.data) ? json.data : (json.data ? [json.data] : []);
  const flight = dataList[0];
  if (!flight) {
    throw new functions.https.HttpsError('not-found', 'No se encontraron datos para este vuelo y fecha.');
  }

  // Amadeus v2 schedule/flights devuelve estructura DatedFlight con flightPoints[]
  const flightPoints = Array.isArray(flight.flightPoints) ? flight.flightPoints : [];
  const originPoint = flightPoints[0] || {};
  const destinationPoint = flightPoints[flightPoints.length - 1] || {};

  const depSection = originPoint.departure || originPoint.departureInfo || {};
  const arrSection = destinationPoint.arrival || destinationPoint.arrivalInfo || {};

  const depTimings = Array.isArray(depSection.timings) ? depSection.timings : [];
  const arrTimings = Array.isArray(arrSection.timings) ? arrSection.timings : [];

  const stdDep = depTimings.find(t => t.qualifier === 'STD') || depTimings[0] || {};
  const stdArr = arrTimings.find(t => t.qualifier === 'STA') || arrTimings[0] || {};

  const depTime = stdDep.value || depSection.scheduledTime || depSection.scheduledAt || depSection.time;
  const arrTime = stdArr.value || arrSection.scheduledTime || arrSection.scheduledAt || arrSection.time;

  const depIata = originPoint.iataCode || depSection.iataCode || depSection.airport || flight.departureAirport;
  const arrIata = destinationPoint.iataCode || arrSection.iataCode || arrSection.airport || flight.arrivalAirport;

  const carrier = (flight.flightDesignator && flight.flightDesignator.carrierCode) || flight.carrierCode || parsed.carrierCode;
  const number = (flight.flightDesignator && flight.flightDesignator.flightNumber) || flight.number || parsed.flightNumber;

  const duration = flight.duration || flight.durationMinutes;
  return {
    flightNumber: `${carrier}${number}`,
    carrierCode: carrier,
    originIata: depIata || null,
    destinationIata: arrIata || null,
    originName: depSection.terminal ? `${depIata || ''} (T${depSection.terminal})` : (depIata || null),
    destinationName: arrSection.terminal ? `${arrIata || ''} (T${arrSection.terminal})` : (arrIata || null),
    departureScheduled: depTime || null,
    arrivalScheduled: arrTime || null,
    durationMinutes: typeof duration === 'number' ? duration : null,
    airlineName: flight.airlineName || carrier,
  };
});

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

/**
 * Push FCM al invitado cuando el invitador dispara una invitación con participación pending.
 * Valida que [context.auth.uid] sea el [invitedBy] de esa participación (no permite spam a userIds arbitrarios).
 */
exports.sendInvitationPush = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Debes estar autenticado'
    );
  }
  const caller = context.auth.uid;
  const { invitedUserId, planId, title, body } = data || {};

  if (!invitedUserId || !planId || !title || !body) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'invitedUserId, planId, title y body son requeridos'
    );
  }
  if (caller === invitedUserId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Invitación inválida'
    );
  }

  const db = admin.firestore();
  const pq = await db
    .collection('plan_participations')
    .where('planId', '==', planId)
    .where('userId', '==', invitedUserId)
    .limit(5)
    .get();

  if (pq.empty) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'No existe participación para este plan e invitado'
    );
  }

  let ok = false;
  pq.forEach((doc) => {
    const p = doc.data();
    if (
      p.invitedBy === caller &&
      p.status === 'pending' &&
      p.isActive !== false
    ) {
      ok = true;
    }
  });

  if (!ok) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'No tienes permiso para notificar a este usuario en este plan'
    );
  }

  const tokensSnapshot = await db
    .collection('users')
    .doc(invitedUserId)
    .collection('fcmTokens')
    .get();

  if (tokensSnapshot.empty) {
    console.log(`sendInvitationPush: sin tokens FCM para ${invitedUserId}`);
    return { success: false, message: 'Usuario sin tokens FCM' };
  }

  const tokens = tokensSnapshot.docs.map((d) => d.data().token).filter(Boolean);
  if (!tokens.length) {
    console.log(`sendInvitationPush: tokens vacíos para ${invitedUserId}`);
    return { success: false, message: 'Usuario sin tokens FCM válidos' };
  }

  const dataPayload = {
    planId: String(planId),
    type: 'invitation',
    tab: 'participants',
  };

  // iOS: sin cabeceras APNs alert el sistema puede tragar el mensaje o tratarlo como silencioso.
  const message = {
    notification: { title: String(title), body: String(body) },
    data: dataPayload,
    tokens,
    apns: {
      headers: {
        'apns-priority': '10',
        'apns-push-type': 'alert',
      },
      payload: {
        aps: {
          alert: {
            title: String(title),
            body: String(body),
          },
          sound: 'default',
          badge: 1,
        },
      },
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'planazoo_default',
        sound: 'default',
      },
    },
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(
      `sendInvitationPush: enviados ${response.successCount}/${tokens.length} a ${invitedUserId}`
    );
    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        console.error(
          `sendInvitationPush fail token#${idx}:`,
          resp.error?.code,
          resp.error?.message
        );
      } else {
        console.log(`sendInvitationPush ok token#${idx} messageId=${resp.messageId}`);
      }
    });
    if (response.failureCount > 0) {
      const batch = db.batch();
      response.responses.forEach((resp, idx) => {
        if (!resp.success && tokens[idx]) {
          batch.delete(
            db.collection('users').doc(invitedUserId).collection('fcmTokens').doc(tokens[idx])
          );
        }
      });
      await batch.commit();
    }
    return {
      success: response.successCount > 0,
      sent: response.successCount,
      failed: response.failureCount,
      total: tokens.length,
    };
  } catch (error) {
    console.error('sendInvitationPush error:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Error enviando push: ${error.message}`
    );
  }
});

// ============================================
// Eventos desde correo (T134): recepción y validación
// POST body: { from: string, subject: string, text?: string, html?: string }
// - Valida From = usuario registrado (email o alias)
// - Rate limit 50/día por usuario
// - Crea documento en users/{userId}/pending_email_events como "sin parsear"
// ============================================

function parseJsonBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', (chunk) => { body += chunk; });
    req.on('end', () => {
      try {
        if (!body.trim()) return resolve({});
        resolve(JSON.parse(body));
      } catch (e) {
        reject(e);
      }
    });
    req.on('error', reject);
  });
}

/** Normaliza email a minúsculas. Para Gmail alias (user+alias@gmail.com) devuelve también la "base" user@gmail.com. */
function normalizeEmailAndBase(email) {
  const normalized = (email || '').toLowerCase().trim();
  const at = normalized.indexOf('@');
  if (at <= 0) return { normalized, base: normalized };
  const local = normalized.substring(0, at);
  const domain = normalized.substring(at);
  const plus = local.indexOf('+');
  const base = plus > 0 ? local.substring(0, plus) + domain : normalized;
  return { normalized, base };
}

function isInboundUniquenessException(primaryEmail, extraEmail) {
  return INBOUND_EMAIL_UNIQUENESS_EXCEPTIONS.some(
    (e) => e.primaryEmail === primaryEmail && e.extraEmail === extraEmail,
  );
}

function isInboundExceptionExtra(extraEmail) {
  return INBOUND_EMAIL_UNIQUENESS_EXCEPTIONS.some((e) => e.extraEmail === extraEmail);
}

/** Busca userId por email principal (exacto, T216) o extra inbound verificado. */
async function findUserIdByEmail(db, fromEmail) {
  const normalized = (fromEmail || '').toLowerCase().trim();
  if (!normalized) return null;
  const lookup = await db.collection('inbound_from_lookup').doc(normalized).get();
  const lookupData = lookup.exists ? (lookup.data() || {}) : {};
  const extraUid = lookupData.verified === true && lookupData.userId ? lookupData.userId : null;
  // LISTA 142: extra de excepción gana al principal (hotmail = PA).
  if (isInboundExceptionExtra(normalized) && extraUid) {
    return extraUid;
  }
  const snap = await db.collection(USERS_COLLECTION).where('email', '==', normalized).limit(1).get();
  if (!snap.empty) return snap.docs[0].id;
  return extraUid || null;
}

/** Cuenta cuántos pending_email_events ha creado el usuario desde medianoche UTC (hoy). */
async function countPendingEmailsToday(db, userId) {
  const now = new Date();
  const startOfDay = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 0, 0, 0, 0));
  const ref = db.collection(USERS_COLLECTION).doc(userId).collection(PENDING_EMAIL_EVENTS_COLLECTION);
  const snap = await ref.where('createdAt', '>=', admin.firestore.Timestamp.fromDate(startOfDay)).get();
  return snap.size;
}

/** Obtiene cuerpo en texto plano: prefiere text, si no hay usa html (sin convertir por ahora). */
function getBodyPlain(data) {
  const text = (data.text || '').trim();
  if (text.length > 0) return text;
  const html = (data.html || '').trim();
  if (html.length > 0) return html.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
  return '';
}

// ============================================
// Motor de plantillas (email_templates): match por triggers y extracción de campos
// ============================================

function templateTriggersMatch(template, subject, bodyPlain) {
  const triggers = template.triggers || [];
  const sub = (subject || '').toLowerCase();
  const body = (bodyPlain || '').toLowerCase();
  for (const t of triggers) {
    const type = (t.type || '').toLowerCase();
    const value = (t.value || '').toLowerCase();
    if (!value) continue;
    if (type === 'subject_contains' && !sub.includes(value)) return false;
    if (type === 'body_contains' && !body.includes(value)) return false;
  }
  return triggers.length > 0;
}

function extractFieldRegex(field, subject, bodyPlain) {
  const source = ((field.source || 'body').toLowerCase() === 'subject') ? subject : bodyPlain;
  const pattern = field.pattern;
  if (!pattern) return null;
  try {
    const re = new RegExp(pattern, 'i');
    const m = re.exec(source);
    if (!m) return null;
    const group = field.group != null ? field.group : 1;
    const val = m[group];
    return val != null ? String(val).trim() : null;
  } catch (e) {
    return null;
  }
}

function extractFieldAfterLabel(field, bodyPlain) {
  const body = bodyPlain || '';
  const label = (field.label || '').trim();
  const stopAt = (field.stop_at || '').trim();
  const maxLines = field.max_lines != null ? Math.max(1, parseInt(field.max_lines, 10)) : 10;
  if (!label) return null;
  const labelIdx = body.toLowerCase().indexOf(label.toLowerCase());
  if (labelIdx < 0) return null;
  let start = body.indexOf('\n', labelIdx);
  if (start < 0) start = labelIdx + label.length;
  else start += 1;
  let block = body.slice(start);
  if (stopAt) {
    const stopIdx = block.toLowerCase().indexOf(stopAt.toLowerCase());
    if (stopIdx >= 0) block = block.slice(0, stopIdx);
  }
  const lines = block.split(/\r?\n/).map(l => l.trim()).filter(Boolean).slice(0, maxLines);
  return lines.length > 0 ? lines.join(' ').trim() : null;
}

function extractFieldComposite(field, extracted) {
  const template = field.template;
  const deps = field.dependencies || [];
  if (!template || typeof template !== 'string') return null;
  let out = template;
  for (const dep of deps) {
    const val = extracted[dep] != null ? String(extracted[dep]).trim() : '';
    out = out.replace(new RegExp(`\\{${dep}\\}`, 'gi'), val);
  }
  return out.trim() || null;
}

function extractFieldsWithTemplate(template, subject, bodyPlain) {
  const fields = template.fields || {};
  const fieldOrder = template.field_order || Object.keys(fields);
  const extracted = {};
  for (const key of fieldOrder) {
    const field = fields[key];
    if (!field || typeof field !== 'object') continue;
    const type = (field.type || '').toLowerCase();
    let value = null;
    if (type === 'regex') value = extractFieldRegex(field, subject, bodyPlain);
    else if (type === 'after_label') value = extractFieldAfterLabel(field, bodyPlain);
    else if (type === 'composite') value = extractFieldComposite(field, extracted);
    if (value != null && value !== '') extracted[key] = value;
  }
  if (template.event_type) extracted.event_type = template.event_type;
  return extracted;
}

/**
 * Carga plantillas activas, matchea la primera por triggers y extrae campos.
 * @returns {{ templateId: string, parsed: object } | { templateId: null, parsed: null }}
 */
async function runTemplateEngine(db, subject, bodyPlain) {
  try {
    const snap = await db.collection(EMAIL_TEMPLATES_COLLECTION).where('active', '==', true).get();
    if (snap.empty) return { templateId: null, parsed: null };
    const templates = snap.docs.sort((a, b) => {
      const pA = a.data().priority != null ? a.data().priority : 10;
      const pB = b.data().priority != null ? b.data().priority : 10;
      return pA - pB;
    });
    for (const doc of templates) {
      const data = doc.data();
      if (!templateTriggersMatch(data, subject, bodyPlain)) continue;
      const parsed = extractFieldsWithTemplate(data, subject, bodyPlain);
      return { templateId: doc.id, parsed: Object.keys(parsed).length ? parsed : null };
    }
    return { templateId: null, parsed: null };
  } catch (e) {
    console.warn('runTemplateEngine error', e);
    return { templateId: null, parsed: null };
  }
}

/**
 * Lógica compartida: valida From + rate limit y crea evento pendiente.
 * Usado por inboundEmail (HTTP) y processInboundGmail (Gmail API).
 * @returns {{ success: true, pendingEventId: string, userId: string }} | {{ success: false, error: string, code: string }}
 */
async function processInboundEmail(db, {from, subject, bodyPlain, bodyHtml, gmail, messageId, payload}) {
  const fromTrimmed = (from || '').trim();
  const subjectTrimmed = (subject || '').trim();
  if (!fromTrimmed || !subjectTrimmed) {
    return {success: false, error: 'from and subject required', code: 'invalid_argument'};
  }
  const plain = (bodyPlain !== undefined && bodyPlain !== null) ? String(bodyPlain) : '';
  const html = bodyHtml ? sanitizeEmailHtml(bodyHtml) : '';

  const userId = await findUserIdByEmail(db, fromTrimmed);
  if (!userId) {
    console.warn(`processInboundEmail: From not registered: ${fromTrimmed}`);
    return {success: false, error: 'Sender email is not a registered user', code: 'from_not_registered'};
  }

  const countToday = await countPendingEmailsToday(db, userId);
  if (countToday >= RATE_LIMIT_EMAILS_PER_DAY) {
    console.warn(`processInboundEmail: Rate limit exceeded for user ${userId}`);
    return {success: false, error: 'Daily limit reached', code: 'rate_limit_exceeded'};
  }

  const {templateId, parsed} = await runTemplateEngine(db, subjectTrimmed, plain);

  const ref = db.collection(USERS_COLLECTION).doc(userId).collection(PENDING_EMAIL_EVENTS_COLLECTION).doc();
  const now = admin.firestore.FieldValue.serverTimestamp();
  const doc = {
    subject: subjectTrimmed,
    bodyPlain: plain,
    fromEmail: fromTrimmed,
    parsed: parsed || null,
    templateId: templateId || null,
    status: 'pending',
    createdAt: now,
    updatedAt: now,
  };
  if (html) doc.bodyHtml = html;
  doc.kind = 'email';
  await ref.set(doc);
  if (gmail && messageId && payload) {
    try {
      const ingested = await ingestGmailAttachments({
        gmail,
        messageId,
        payload,
        userId,
        pendingId: ref.id,
        html: html || '',
      });
      const patch = {};
      if (ingested.attachments.length) patch.attachments = ingested.attachments;
      if (ingested.html) patch.bodyHtml = ingested.html;
      if (Object.keys(patch).length) await ref.update(patch);
    } catch (e) {
      console.warn('processInboundEmail: attachments failed', e.message);
    }
  }
  if (templateId) console.log(`processInboundEmail: Created pending_email_event ${ref.id} for user ${userId} (template ${templateId})`);
  else console.log(`processInboundEmail: Created pending_email_event ${ref.id} for user ${userId}`);
  return { success: true, pendingEventId: ref.id, userId };
}

exports.inboundEmail = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type, X-Email-Inbound-Secret');
    res.status(204).end();
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }

  const secret = process.env.EMAIL_INBOUND_SECRET || functions.config().email_inbound?.secret;
  if (secret && req.get('X-Email-Inbound-Secret') !== secret) {
    res.status(403).json({ error: 'forbidden', message: 'Invalid or missing secret' });
    return;
  }

  let data;
  try {
    data = await parseJsonBody(req);
  } catch (e) {
    res.status(400).json({ error: 'invalid_body', message: 'Invalid JSON' });
    return;
  }

  const from = (data.from || '').trim();
  const subject = (data.subject || '').trim();
  if (!from || !subject) {
    res.status(400).json({ error: 'invalid_argument', message: 'from and subject required' });
    return;
  }

  const bodyPlain = getBodyPlain(data);
  const bodyHtml = data.html ? sanitizeEmailHtml(String(data.html)) : '';
  const db = admin.firestore();
  const result = await processInboundEmail(db, {from, subject, bodyPlain, bodyHtml});

  if (result.success) {
    res.status(200).json({ success: true, pendingEventId: result.pendingEventId, userId: result.userId });
    return;
  }
  if (result.code === 'from_not_registered') res.status(403).json({ error: result.code, message: result.error });
  else if (result.code === 'rate_limit_exceeded') res.status(429).json({ error: result.code, message: result.error });
  else if (result.code === 'invalid_argument') res.status(400).json({ error: result.code, message: result.error });
  else res.status(500).json({ error: result.code || 'internal', message: result.error });
});

// ============================================
// Eventos desde correo (T134): lectura del buzón con Gmail API (100% Google)
// Gmail consumidor = OAuth refresh token; Workspace = SA + domain-wide delegation.
// Cloud Scheduler llama a processInboundGmail cada X minutos.
// ============================================

const GMAIL_SCOPES = ['https://www.googleapis.com/auth/gmail.readonly', 'https://www.googleapis.com/auth/gmail.modify'];
/** Buzón de lanzamiento (mismo valor que `kPlanoonInboundMailbox` en la app). */
const DEFAULT_GMAIL_INBOUND_MAILBOX = 'unplanazoo+eventos@gmail.com';

function gmailInboundConfig() {
  return functions.config().gmail_inbound || {};
}

/** Devuelve la lista de buzones a procesar. Soporta uno (string) o varios (coma-separados o JSON array). */
function getMailboxList() {
  const cfg = gmailInboundConfig();
  const single = process.env.GMAIL_INBOUND_MAILBOX || cfg.mailbox;
  const listRaw = process.env.GMAIL_INBOUND_MAILBOX_LIST || cfg.mailbox_list;
  if (listRaw) {
    if (typeof listRaw === 'string' && listRaw.trim().startsWith('[')) {
      try {
        const arr = JSON.parse(listRaw);
        return Array.isArray(arr) ? arr.map(m => (m || '').trim()).filter(Boolean) : [];
      } catch (e) {
        return listRaw.split(',').map(m => m.trim()).filter(Boolean);
      }
    }
    return listRaw.split(',').map(m => m.trim()).filter(Boolean);
  }
  if (single) return [single.trim()];
  return [DEFAULT_GMAIL_INBOUND_MAILBOX];
}

/** Gmail consumidor: OAuth con refresh token (no aplica domain-wide delegation). */
function getGmailClientFromOAuth() {
  const cfg = gmailInboundConfig();
  const clientId = process.env.GMAIL_INBOUND_OAUTH_CLIENT_ID || cfg.oauth_client_id;
  const clientSecret = process.env.GMAIL_INBOUND_OAUTH_CLIENT_SECRET || cfg.oauth_client_secret;
  const refreshToken = process.env.GMAIL_INBOUND_OAUTH_REFRESH_TOKEN || cfg.oauth_refresh_token;
  if (!clientId || !clientSecret || !refreshToken) return null;
  const {google} = require('googleapis');
  const auth = new google.auth.OAuth2(clientId, clientSecret);
  auth.setCredentials({refresh_token: refreshToken});
  return google.gmail({version: 'v1', auth});
}

function getGmailClientForMailbox(mailbox) {
  if (!mailbox) return null;
  const oauthClient = getGmailClientFromOAuth();
  if (oauthClient) return oauthClient;

  let clientEmail;
  let privateKey;
  const cfg = gmailInboundConfig();
  const saJson = process.env.GMAIL_INBOUND_SA_JSON || cfg.service_account_json;
  if (saJson) {
    try {
      const key = typeof saJson === 'string' ? JSON.parse(saJson) : saJson;
      clientEmail = key.client_email;
      privateKey = key.private_key;
    } catch (e) {
      console.error('processInboundGmail: Invalid GMAIL_INBOUND_SA_JSON', e);
      return null;
    }
  } else {
    clientEmail = process.env.GMAIL_INBOUND_SA_CLIENT_EMAIL || cfg.client_email;
    privateKey = process.env.GMAIL_INBOUND_SA_PRIVATE_KEY || cfg.private_key;
    if (privateKey && typeof privateKey === 'string') privateKey = privateKey.replace(/\\n/g, '\n');
  }
  if (!clientEmail || !privateKey) return null;
  const {google} = require('googleapis');
  const auth = new google.auth.JWT({
    email: clientEmail,
    key: privateKey,
    subject: mailbox,
    scopes: GMAIL_SCOPES,
  });
  return google.gmail({version: 'v1', auth});
}

/** Gmail trata `+` como AND; no filtramos el alias en `q`. El corte por destinatario va en cabeceras. */
function gmailUnreadQuery() {
  const custom = process.env.GMAIL_INBOUND_QUERY || gmailInboundConfig().query;
  if (custom && String(custom).trim()) return String(custom).trim();
  return 'is:unread newer_than:30d';
}

function messageAddressedToMailbox(payload, mailbox) {
  const want = (mailbox || '').trim().toLowerCase();
  if (!want) return false;
  const blob = ['To', 'Delivered-To', 'X-Original-To', 'X-Forwarded-To', 'Cc', 'Envelope-To']
      .map((h) => getHeader(payload, h))
      .join(' ')
      .toLowerCase();
  return blob.includes(want);
}

function getHeader(payload, name) {
  const header = (payload.headers || []).find(h => (h.name || '').toLowerCase() === name.toLowerCase());
  return header ? header.value : '';
}

/** Extrae la dirección de email del valor de la cabecera From (p. ej. "Name <user@domain.com>" -> "user@domain.com"). */
function extractEmailFromHeader(fromHeader) {
  const s = (fromHeader || '').trim();
  const match = s.match(/<([^>]+)>/);
  if (match) return match[1].trim();
  return s;
}

function decodeBase64url(str) {
  if (!str) return '';
  const base64 = str.replace(/-/g, '+').replace(/_/g, '/');
  try {
    return Buffer.from(base64, 'base64').toString('utf8');
  } catch (e) {
    return '';
  }
}

function collectMimeBodies(part, acc) {
  if (!part) return;
  const mime = (part.mimeType || '').toLowerCase();
  if (part.body && part.body.data) {
    const decoded = decodeBase64url(part.body.data);
    if (mime === 'text/plain' && !acc.textPlain) acc.textPlain = decoded;
    else if (mime === 'text/html' && !acc.html) acc.html = decoded;
    else if (!mime.startsWith('multipart/') && !acc.textPlain && decoded) acc.textPlain = decoded;
  } else if (part.body && part.body.attachmentId) {
    acc.pending.push({mime, attachmentId: part.body.attachmentId});
  }
  (part.parts || []).forEach((child) => collectMimeBodies(child, acc));
}

function htmlToPlain(html) {
  return String(html || '').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
}

/** Outlook/Hotmail: `manage reservation <https://…>` → `<a href="…">manage reservation</a>`. */
function outlookPlainToHtml(plain) {
  const text = String(plain || '');
  if (!text) return '';
  const re = /\[(https?:\/\/[^\s\]]+)\]|([^\n<]{1,80}?)\s*<((?:https?|tel|mailto):[^>]+)>|(https?:\/\/[^\s<>]+)/gi;
  let out = '';
  let last = 0;
  let m;
  while ((m = re.exec(text)) !== null) {
    out += escapeHtml(text.slice(last, m.index)).replace(/\n/g, '<br>');
    if (m[1]) {
      const url = m[1];
      if (/\.(png|jpe?g|gif|webp)(\?|$)/i.test(url)) {
        out += `<img src="${escapeHtml(url)}" alt="">`;
      } else {
        out += `<a href="${escapeHtml(url)}">${escapeHtml(url)}</a>`;
      }
    } else if (m[3]) {
      let label = (m[2] || '').trim().replace(/^[|\-–—]+\s*/, '');
      if (label.includes('\n')) label = label.split('\n').pop().trim();
      if (!label) label = m[3];
      out += `<a href="${escapeHtml(m[3])}">${escapeHtml(label)}</a>`;
    } else if (m[4]) {
      out += `<a href="${escapeHtml(m[4])}">${escapeHtml(m[4])}</a>`;
    }
    last = m.index + m[0].length;
  }
  out += escapeHtml(text.slice(last)).replace(/\n/g, '<br>');
  return out;
}

function sanitizeEmailHtml(html) {
  let s = String(html || '');
  s = s.replace(/<script[\s\S]*?<\/script>/gi, '');
  s = s.replace(/<style[\s\S]*?<\/style>/gi, '');
  s = s.replace(/<head[\s\S]*?<\/head>/gi, '');
  s = s.replace(/\son\w+\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)/gi, '');
  s = s.replace(/javascript:/gi, '');
  // data: embebido puede ser enorme; cid se reescribe a Storage después.
  s = s.replace(/<img\b[^>]*\bsrc\s*=\s*["']?data:[^>]*>/gi, '');
  // Colores del HTML del hotel chocan con el sheet oscuro de la app.
  s = s.replace(/color\s*:\s*[^;}"']+;?/gi, '');
  s = s.replace(/background(?:-color)?\s*:\s*[^;}"']+;?/gi, '');
  s = s.replace(/\s(?:bg)?color\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)/gi, '');
  const max = 120000;
  if (s.length > max) s = s.slice(0, max);
  return s.trim();
}

async function getBodiesFromPayload(gmail, messageId, payload) {
  const acc = {textPlain: '', html: '', pending: []};
  collectMimeBodies(payload, acc);
  if (gmail && messageId && acc.pending.length) {
    for (const p of acc.pending) {
      try {
        const att = await gmail.users.messages.attachments.get({
          userId: 'me',
          messageId,
          id: p.attachmentId,
        });
        const decoded = decodeBase64url(att.data && att.data.data);
        if (!decoded) continue;
        if (p.mime === 'text/html' && !acc.html) acc.html = decoded;
        else if (p.mime === 'text/plain' && !acc.textPlain) acc.textPlain = decoded;
      } catch (e) {
        console.warn('getBodiesFromPayload: attachment fetch failed', e.message);
      }
    }
  }
  let html = sanitizeEmailHtml(acc.html);
  if (!html && acc.textPlain) html = outlookPlainToHtml(acc.textPlain);
  const textPlain = acc.textPlain.trim() || htmlToPlain(html);
  return {textPlain, html};
}

function getBodyFromPayload(payload) {
  const acc = {textPlain: '', html: '', pending: []};
  collectMimeBodies(payload, acc);
  return acc.textPlain.trim() || htmlToPlain(acc.html);
}

const MAX_COMM_ATTACHMENT_BYTES = 8 * 1024 * 1024;
const MAX_COMM_ATTACHMENTS = 8;

function decodeBase64urlToBuffer(str) {
  if (!str) return Buffer.alloc(0);
  const base64 = String(str).replace(/-/g, '+').replace(/_/g, '/');
  try {
    return Buffer.from(base64, 'base64');
  } catch (e) {
    return Buffer.alloc(0);
  }
}

function collectAttachmentParts(part, list) {
  if (!part) return;
  const mime = (part.mimeType || '').toLowerCase();
  if (!mime.startsWith('multipart/')) {
    const filename = part.filename || '';
    const cid = (getHeader(part, 'Content-ID') || '').replace(/[<>]/g, '').trim();
    const disp = (getHeader(part, 'Content-Disposition') || '').toLowerCase();
    const isTextBody = (mime === 'text/plain' || mime === 'text/html') && !filename && !cid;
    if (!isTextBody && part.body && (part.body.data || part.body.attachmentId)) {
      if (filename || cid || mime.startsWith('image/') || disp.includes('attachment')) {
        list.push({
          mime,
          filename,
          cid,
          attachmentId: (part.body && part.body.attachmentId) || '',
          data: (part.body && part.body.data) || '',
          size: (part.body && part.body.size) || 0,
        });
      }
    }
  }
  (part.parts || []).forEach((child) => collectAttachmentParts(child, list));
}

function extensionFromMime(mime, filename) {
  if (filename && filename.includes('.')) {
    return filename.split('.').pop().toLowerCase();
  }
  if (mime === 'image/jpeg') return 'jpg';
  if (mime === 'image/png') return 'png';
  if (mime === 'image/gif') return 'gif';
  if (mime === 'image/webp') return 'webp';
  if (mime === 'application/pdf') return 'pdf';
  if (mime === 'text/calendar') return 'ics';
  return 'bin';
}

function isAllowedCommAttachment(mime, filename) {
  const ext = extensionFromMime(mime, filename);
  const allowed = new Set(['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'ics']);
  if (allowed.has(ext)) return true;
  if ((mime || '').startsWith('image/')) return true;
  if (mime === 'application/pdf' || mime === 'text/calendar') return true;
  return false;
}

function rewriteCidInHtml(html, cid, url) {
  const clean = String(cid || '').replace(/[<>]/g, '').trim();
  if (!clean) return html;
  const variants = [clean];
  if (clean.includes('@')) variants.push(clean.split('@')[0]);
  let out = html;
  for (const v of variants) {
    const escaped = v.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    out = out.replace(new RegExp(`cid:${escaped}`, 'gi'), url);
  }
  return out;
}

async function ingestGmailAttachments({gmail, messageId, payload, userId, pendingId, html}) {
  const parts = [];
  collectAttachmentParts(payload, parts);
  const attachments = [];
  let rewritten = html || '';
  const bucket = admin.storage().bucket();
  for (const p of parts) {
    if (attachments.length >= MAX_COMM_ATTACHMENTS) break;
    if (!isAllowedCommAttachment(p.mime, p.filename)) continue;
    if (p.size && p.size > MAX_COMM_ATTACHMENT_BYTES) continue;
    let raw = p.data ? decodeBase64urlToBuffer(p.data) : Buffer.alloc(0);
    if ((!raw || !raw.length) && p.attachmentId) {
      try {
        const att = await gmail.users.messages.attachments.get({
          userId: 'me',
          messageId,
          id: p.attachmentId,
        });
        raw = decodeBase64urlToBuffer(att.data && att.data.data);
      } catch (e) {
        console.warn('ingestGmailAttachments: fetch failed', e.message);
        continue;
      }
    }
    if (!raw || !raw.length || raw.length > MAX_COMM_ATTACHMENT_BYTES) continue;
    const ext = extensionFromMime(p.mime, p.filename);
    const baseName = (p.filename || `inline-${p.cid || attachments.length}`).replace(/[^a-zA-Z0-9._-]/g, '_');
    const fileName = baseName.includes('.')
      ? `${Date.now()}_${attachments.length}_${baseName}`
      : `${Date.now()}_${attachments.length}_${baseName}.${ext}`;
    const path = `communication_files/${userId}/${pendingId}/${fileName}`;
    const token = crypto.randomUUID();
    const file = bucket.file(path);
    await file.save(raw, {
      resumable: false,
      metadata: {
        contentType: p.mime || 'application/octet-stream',
        metadata: {
          firebaseStorageDownloadTokens: token,
          originalName: p.filename || baseName,
        },
      },
    });
    const url = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
    const item = {
      name: p.filename || fileName,
      url,
      type: p.mime || 'application/octet-stream',
      size: raw.length,
    };
    if (p.cid) item.contentId = p.cid;
    attachments.push(item);
    if (p.cid) rewritten = rewriteCidInHtml(rewritten, p.cid, url);
  }
  rewritten = rewritten.replace(/<img\b[^>]*\bsrc\s*=\s*["']?cid:[^>]*>/gi, '');
  return {attachments, html: rewritten};
}

/**
 * Procesa un solo buzón: lista no leídos, crea eventos pendientes, marca como leído.
 * Si el buzón falla (cuenta deshabilitada, auth, etc.) lanza; el caller puede seguir con el siguiente.
 */
async function processOneMailbox(gmail, mailboxLabel, db) {
  let processed = 0;
  let errors = 0;
  let skippedOther = 0;
  let authenticatedAs = null;
  try {
    const profile = await gmail.users.getProfile({userId: 'me'});
    authenticatedAs = profile.data.emailAddress || null;
  } catch (e) {
    console.warn('processInboundGmail: getProfile failed', e.message);
  }
  const listRes = await gmail.users.messages.list({
    userId: 'me',
    q: gmailUnreadQuery(),
    maxResults: 50,
    includeSpamTrash: true,
  });
  const messages = listRes.data.messages || [];
  for (const item of messages) {
    try {
      const msgRes = await gmail.users.messages.get({userId: 'me', id: item.id, format: 'full'});
      const payload = msgRes.data.payload || {};
      if (!messageAddressedToMailbox(payload, mailboxLabel)) {
        skippedOther++;
        continue;
      }
      const fromHeader = getHeader(payload, 'From');
      const from = extractEmailFromHeader(fromHeader);
      const subject = getHeader(payload, 'Subject');
      const {textPlain, html} = await getBodiesFromPayload(gmail, item.id, payload);
      console.log(`processInboundGmail [${mailboxLabel}]: as=${authenticatedAs} from=${from} subject=${subject}`);
      const result = await processInboundEmail(db, {
        from,
        subject,
        bodyPlain: textPlain,
        bodyHtml: html,
        gmail,
        messageId: item.id,
        payload,
      });
      if (result.success) processed++;
      else errors++;
      await gmail.users.messages.modify({
        userId: 'me',
        id: item.id,
        requestBody: {removeLabelIds: ['UNREAD']},
      });
    } catch (err) {
      console.error(`processInboundGmail [${mailboxLabel}]: Error processing message ${item.id}`, err);
      errors++;
    }
  }
  return {
    processed,
    errors,
    total: messages.length,
    skippedOther,
    authenticatedAs,
  };
}

/**
 * Job invocado por Cloud Scheduler: lee uno o varios buzones Gmail, procesa cada correo no leído
 * y crea eventos pendientes. Soporta varios buzones (fallback/resiliencia): si uno falla, sigue con el siguiente.
 */
exports.processInboundGmail = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST' && req.method !== 'GET') {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }
  const secret = process.env.GMAIL_POLL_SECRET || gmailInboundConfig().poll_secret;
  if (secret && req.get('X-Gmail-Poll-Secret') !== secret) {
    res.status(403).json({ error: 'forbidden', message: 'Invalid or missing poll secret' });
    return;
  }

  const mailboxes = getMailboxList();
  if (mailboxes.length === 0) {
    console.warn('processInboundGmail: No mailboxes configured (GMAIL_INBOUND_MAILBOX or GMAIL_INBOUND_MAILBOX_LIST)');
    res.status(503).json({ error: 'not_configured', message: 'Gmail inbound not configured' });
    return;
  }

  const db = admin.firestore();
  let totalProcessed = 0;
  let totalErrors = 0;
  const byMailbox = [];

  for (const mailbox of mailboxes) {
    const gmail = getGmailClientForMailbox(mailbox);
    if (!gmail) {
      console.warn(`processInboundGmail: No credentials for mailbox ${mailbox}, skipping`);
      byMailbox.push({ mailbox, error: 'no_credentials', processed: 0, errors: 0, total: 0 });
      continue;
    }
    try {
      const result = await processOneMailbox(gmail, mailbox, db);
      totalProcessed += result.processed;
      totalErrors += result.errors;
      byMailbox.push({ mailbox, ...result });
    } catch (err) {
      console.error(`processInboundGmail: Mailbox ${mailbox} failed (auth/quota/disabled?)`, err);
      byMailbox.push({ mailbox, error: err.message, processed: 0, errors: 0, total: 0 });
    }
  }

  res.status(200).json({ success: true, processed: totalProcessed, errors: totalErrors, byMailbox });
});

// ============================================
// T273 — Avisos programados de límites de cancelación
// Cron (pubsub schedule) + HTTP opcional para Cloud Scheduler / prueba manual.
// ============================================

const CANCELLATION_DEFAULT_LEAD_HOURS = 48;

function parseCancellationDeadline(raw) {
  if (!raw) return null;
  if (raw.toDate && typeof raw.toDate === 'function') return raw.toDate();
  if (raw instanceof Date) return raw;
  if (typeof raw === 'string' || typeof raw === 'number') {
    const d = new Date(raw);
    return Number.isNaN(d.getTime()) ? null : d;
  }
  if (typeof raw.seconds === 'number') return new Date(raw.seconds * 1000);
  return null;
}

function sameCivilDay(a, b) {
  return a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate();
}

/**
 * Fases según reminderLeadHours / reminderAlsoOnDay del ítem.
 * Docs antiguos sin campos → 48h + día.
 */
function cancellationPhases(now, deadline, reservation) {
  const phases = [];
  if (!(deadline instanceof Date) || Number.isNaN(deadline.getTime()) || deadline <= now) {
    return phases;
  }

  const hasLeadField = reservation &&
    Object.prototype.hasOwnProperty.call(reservation, 'reminderLeadHours');
  const hasDayField = reservation &&
    Object.prototype.hasOwnProperty.call(reservation, 'reminderAlsoOnDay');

  let leadHours;
  if (!hasLeadField) {
    leadHours = CANCELLATION_DEFAULT_LEAD_HOURS;
  } else if (reservation.reminderLeadHours == null) {
    leadHours = null;
  } else {
    leadHours = Number(reservation.reminderLeadHours);
    if (Number.isNaN(leadHours) || leadHours <= 0) leadHours = null;
  }
  const alsoOnDay = hasDayField
    ? Boolean(reservation.reminderAlsoOnDay)
    : true;

  if (leadHours != null) {
    const untilMs = now.getTime() + leadHours * 60 * 60 * 1000;
    if (deadline.getTime() <= untilMs) {
      phases.push(`h${leadHours}`);
    }
  }
  if (alsoOnDay && sameCivilDay(now, deadline)) {
    phases.push('day');
  }
  return phases;
}

function cancellationDedupeKey(itemId, deadline, refundPercent, phase) {
  return `${itemId}|${deadline.toISOString()}|${refundPercent}|${phase}`;
}

function formatDeadlineEs(deadline) {
  const dd = String(deadline.getDate()).padStart(2, '0');
  const mm = String(deadline.getMonth() + 1).padStart(2, '0');
  const yyyy = deadline.getFullYear();
  const hh = String(deadline.getHours()).padStart(2, '0');
  const mi = String(deadline.getMinutes()).padStart(2, '0');
  return `${dd}/${mm}/${yyyy} ${hh}:${mi}`;
}

function formatPercent(n) {
  const num = Number(n);
  if (Number.isNaN(num)) return '0';
  return Number.isInteger(num) ? String(num) : num.toFixed(1);
}

async function loadExistingCancellationKeys(db, userId, planId) {
  const snap = await db.collection('users').doc(userId)
    .collection('notifications')
    .where('planId', '==', planId)
    .where('type', '==', 'alarm')
    .get();
  const keys = new Set();
  snap.docs.forEach((doc) => {
    const payload = doc.data().data;
    if (!payload || payload.kind !== 'cancellationDeadline') return;
    const k = payload.dedupeKey ? String(payload.dedupeKey) : '';
    if (k) keys.add(k);
    const phase = payload.phase ? String(payload.phase) : '';
    if (!phase && k && !k.endsWith('|48h') && !k.endsWith('|day') && !k.includes('|h')) {
      keys.add(`${k}|h48`);
      keys.add(`${k}|48h`);
    }
    if (k && k.endsWith('|48h')) {
      keys.add(`${k.slice(0, -4)}h48`);
    }
  });
  return keys;
}

async function sendFcmToUser(userId, title, body, data) {
  const tokensSnapshot = await admin.firestore()
    .collection('users')
    .doc(userId)
    .collection('fcmTokens')
    .get();
  if (tokensSnapshot.empty) {
    return { success: false, sent: 0 };
  }
  const tokens = tokensSnapshot.docs.map((d) => d.data().token).filter(Boolean);
  if (tokens.length === 0) return { success: false, sent: 0 };

  const stringData = {};
  Object.keys(data || {}).forEach((k) => {
    stringData[k] = data[k] == null ? '' : String(data[k]);
  });

  const response = await admin.messaging().sendEachForMulticast({
    notification: { title, body },
    data: stringData,
    tokens,
  });

  if (response.failureCount > 0) {
    const batch = admin.firestore().batch();
    let deleted = 0;
    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        const token = tokens[idx];
        batch.delete(
          admin.firestore().collection('users').doc(userId).collection('fcmTokens').doc(token),
        );
        deleted++;
      }
    });
    if (deleted > 0) await batch.commit();
  }
  return { success: response.successCount > 0, sent: response.successCount };
}

/**
 * Escanea eventos/alojamientos con política de cancelación y avisa al organizador.
 * Query: docs con `reservationCancellation` (incluye alojamientos en `events`).
 * El campo `nextCancellationDeadline` se escribe en cliente para futuras queries indexadas.
 */
async function runCancellationDeadlineCheck() {
  const db = admin.firestore();
  const now = new Date();

  let eventDocs = [];
  try {
    const snap = await db.collection('events')
      .where('reservationCancellation', '!=', null)
      .get();
    eventDocs = snap.docs;
    console.log(`checkCancellationDeadlines: scanned ${eventDocs.length} doc(s) with reservationCancellation`);
  } catch (err) {
    console.error('checkCancellationDeadlines: query failed', err);
    throw err;
  }

  const planCache = new Map();
  const keysCache = new Map();
  let notified = 0;
  let skipped = 0;
  let errors = 0;

  for (const doc of eventDocs) {
    try {
      const data = doc.data() || {};
      const planId = data.planId;
      if (!planId) {
        skipped++;
        continue;
      }

      const reservation = data.reservationCancellation;
      const tiers = (reservation && Array.isArray(reservation.tiers)) ? reservation.tiers : [];
      if (tiers.length === 0) {
        skipped++;
        continue;
      }

      let organizerUserId = planCache.get(planId);
      if (organizerUserId === undefined) {
        const planDoc = await db.collection('plans').doc(planId).get();
        organizerUserId = planDoc.exists ? (planDoc.data().userId || null) : null;
        planCache.set(planId, organizerUserId);
      }
      if (!organizerUserId) {
        skipped++;
        continue;
      }

      const cacheKey = `${organizerUserId}|${planId}`;
      let existing = keysCache.get(cacheKey);
      if (!existing) {
        existing = await loadExistingCancellationKeys(db, organizerUserId, planId);
        keysCache.set(cacheKey, existing);
      }

      const isAcc = data.typeFamily === 'alojamiento';
      const label = isAcc
        ? (data.hotelName || 'Alojamiento')
        : ((data.description && String(data.description).trim()) || 'Evento');

      for (const tier of tiers.slice(0, 2)) {
        const deadline = parseCancellationDeadline(tier.deadlineAt);
        if (!deadline) continue;
        const refundPercent = tier.refundPercent != null ? Number(tier.refundPercent) : 0;
        const phases = cancellationPhases(now, deadline, reservation);
        if (phases.length === 0) {
          skipped++;
          continue;
        }
        for (const phase of phases) {
          const key = cancellationDedupeKey(doc.id, deadline, refundPercent, phase);
          if (existing.has(key)) {
            skipped++;
            continue;
          }

          const title = phase === 'day'
            ? 'Cancelación: hoy es el límite'
            : 'Límite de cancelación próximo';
          const body = `${label}: recuperas ${formatPercent(refundPercent)}% hasta ${formatDeadlineEs(deadline)}`;

          const notifRef = db.collection('users').doc(organizerUserId)
            .collection('notifications').doc();
          await notifRef.set({
            userId: organizerUserId,
            type: 'alarm',
            title,
            body,
            planId,
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            data: {
              kind: 'cancellationDeadline',
              itemId: doc.id,
              isAccommodation: isAcc,
              deadlineAt: deadline.toISOString(),
              refundPercent,
              phase,
              dedupeKey: key,
              source: 'scheduled',
            },
          });
          existing.add(key);
          notified++;

          try {
            await sendFcmToUser(organizerUserId, title, body, {
              type: 'alarm',
              planId,
              kind: 'cancellationDeadline',
              phase,
            });
          } catch (pushErr) {
            console.warn(`checkCancellationDeadlines: push failed for ${organizerUserId}`, pushErr.message);
          }
        }
      }
    } catch (itemErr) {
      errors++;
      console.error(`checkCancellationDeadlines: error on event ${doc.id}`, itemErr);
    }
  }

  return { notified, skipped, errors, scanned: eventDocs.length };
}

exports.checkCancellationDeadlines = functions.pubsub
  .schedule('every 60 minutes')
  .timeZone('Europe/Madrid')
  .onRun(async () => {
    const result = await runCancellationDeadlineCheck();
    console.log('checkCancellationDeadlines result', result);
    return null;
  });

/**
 * HTTP para prueba manual o Cloud Scheduler.
 * Cabecera opcional: X-Cancellation-Reminders-Secret (si CANCELATION_REMINDERS_SECRET / config está definida).
 */
exports.triggerCancellationDeadlineCheck = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST' && req.method !== 'GET') {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }
  const secret = process.env.CANCELATION_REMINDERS_SECRET ||
    process.env.CANCELLATION_REMINDERS_SECRET ||
    functions.config().cancellation_reminders?.secret;
  if (secret && req.get('X-Cancellation-Reminders-Secret') !== secret) {
    res.status(403).json({ error: 'forbidden', message: 'Invalid or missing secret' });
    return;
  }
  try {
    const result = await runCancellationDeadlineCheck();
    res.status(200).json({ success: true, ...result });
  } catch (err) {
    console.error('triggerCancellationDeadlineCheck failed', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

async function sendPlatformEmail({ to, subject, text, html }) {
  if (gmailTransporter) {
    await gmailTransporter.sendMail({ from: FROM_EMAIL, to, subject, text, html });
    return;
  }
  if (SENDGRID_API_KEY) {
    await sgMail.send({ to, from: FROM_EMAIL, subject, text, html });
    return;
  }
  throw new Error('No email transport configured');
}

function confirmInboundEmailUrl(token) {
  const project = process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT || '';
  return `https://us-central1-${project}.cloudfunctions.net/confirmInboundEmail?token=${encodeURIComponent(token)}`;
}

function isValidEmailAddress(email) {
  return typeof email === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

exports.requestInboundEmailVerification = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes estar autenticado.');
  }
  const uid = context.auth.uid;
  const email = (data?.email || '').toLowerCase().trim();
  if (!isValidEmailAddress(email)) {
    throw new functions.https.HttpsError('invalid-argument', 'Email inválido.');
  }
  const db = admin.firestore();
  const userDoc = await db.collection(USERS_COLLECTION).doc(uid).get();
  const primary = ((userDoc.data() || {}).email || '').toLowerCase().trim();
  if (email === primary) {
    throw new functions.https.HttpsError('failed-precondition', 'primary');
  }
  const extrasSnap = await db.collection(USERS_COLLECTION).doc(uid).collection('inbound_emails').get();
  const existing = extrasSnap.docs.find((d) => ((d.data() || {}).email || '').toLowerCase() === email);
  if (!existing && extrasSnap.size >= 2) {
    throw new functions.https.HttpsError('failed-precondition', 'Máximo 2 extras.');
  }
  const primaryTaken = await db.collection(USERS_COLLECTION).where('email', '==', email).limit(1).get();
  const uniquenessException = isInboundUniquenessException(primary, email);
  if (!primaryTaken.empty && !uniquenessException) {
    throw new functions.https.HttpsError('already-exists', 'Email en otra cuenta.');
  }
  const lookupRef = db.collection('inbound_from_lookup').doc(email);
  const lookup = await lookupRef.get();
  if (lookup.exists && lookup.data().userId && lookup.data().userId !== uid && !uniquenessException) {
    throw new functions.https.HttpsError('already-exists', 'Email en otra cuenta.');
  }

  const token = crypto.randomBytes(24).toString('hex');
  const expiresAt = admin.firestore.Timestamp.fromDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
  const extraRef = existing
    ? extrasSnap.docs.find((d) => ((d.data() || {}).email || '').toLowerCase() === email).ref
    : db.collection(USERS_COLLECTION).doc(uid).collection('inbound_emails').doc();

  const batch = db.batch();
  batch.set(extraRef, {
    email,
    verified: false,
    createdAt: existing ? (existing.data().createdAt || admin.firestore.FieldValue.serverTimestamp()) : admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
  batch.set(lookupRef, {
    userId: uid,
    verified: false,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  batch.set(db.collection('inbound_email_tokens').doc(token), {
    userId: uid,
    email,
    extraId: extraRef.id,
    expiresAt,
  });
  await batch.commit();

  const url = confirmInboundEmailUrl(token);
  const subject = 'Verifica tu correo en Planoon';
  const text = `Confirma este correo para reenviar reservas a Planoon:\n${url}\n\nEl enlace caduca en 24 horas.`;
  const html = `<p>Confirma este correo para reenviar reservas a Planoon.</p><p><a href="${url}">Verificar correo</a></p><p>El enlace caduca en 24 horas.</p>`;
  await sendPlatformEmail({ to: email, subject, text, html });
  return { ok: true };
});

exports.removeInboundEmail = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes estar autenticado.');
  }
  const uid = context.auth.uid;
  const email = (data?.email || '').toLowerCase().trim();
  if (!isValidEmailAddress(email)) {
    throw new functions.https.HttpsError('invalid-argument', 'Email inválido.');
  }
  const db = admin.firestore();
  const extrasSnap = await db.collection(USERS_COLLECTION).doc(uid).collection('inbound_emails').get();
  const extra = extrasSnap.docs.find((d) => ((d.data() || {}).email || '').toLowerCase() === email);
  const lookup = await db.collection('inbound_from_lookup').doc(email).get();
  const batch = db.batch();
  if (extra) batch.delete(extra.ref);
  if (lookup.exists && lookup.data().userId === uid) {
    batch.delete(lookup.ref);
  }
  await batch.commit();
  return { ok: true };
});

exports.confirmInboundEmail = functions.https.onRequest(async (req, res) => {
  const token = (req.query.token || '').toString().trim();
  if (!token) {
    res.status(400).send('Falta token.');
    return;
  }
  const db = admin.firestore();
  const tokenRef = db.collection('inbound_email_tokens').doc(token);
  const tokenDoc = await tokenRef.get();
  if (!tokenDoc.exists) {
    res.status(400).send('Enlace no válido o ya usado.');
    return;
  }
  const data = tokenDoc.data() || {};
  const expiresAt = data.expiresAt && data.expiresAt.toDate ? data.expiresAt.toDate() : null;
  if (expiresAt && expiresAt.getTime() < Date.now()) {
    await tokenRef.delete();
    res.status(400).send('El enlace ha caducado. Vuelve a Planoon y reenvía el correo de verificación.');
    return;
  }
  const extraRef = db.collection(USERS_COLLECTION).doc(data.userId).collection('inbound_emails').doc(data.extraId);
  const lookupRef = db.collection('inbound_from_lookup').doc(data.email);
  const batch = db.batch();
  batch.set(extraRef, { verified: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  batch.set(lookupRef, { userId: data.userId, verified: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  batch.delete(tokenRef);
  await batch.commit();
  res.status(200).send('<!doctype html><html><body style="font-family:sans-serif;padding:32px"><h1>Correo verificado</h1><p>Ya puedes reenviar confirmaciones a Planoon desde esta dirección. Vuelve a la app.</p></body></html>');
});



