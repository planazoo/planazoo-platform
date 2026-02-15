const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');
const nodemailer = require('nodemailer');
const { google } = require('googleapis');

admin.initializeApp();

// --- Constantes para eventos desde correo (T134) ---
const RATE_LIMIT_EMAILS_PER_DAY = 50;
const PENDING_EMAIL_EVENTS_COLLECTION = 'pending_email_events';
const USERS_COLLECTION = 'users';
const EMAIL_TEMPLATES_COLLECTION = 'email_templates';

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

  const invitationsSnap = await db.collection('plan_invitations')
    .where('token', '==', token)
    .where('status', '==', 'pending')
    .limit(1)
    .get();

  if (invitationsSnap.empty) {
    throw new functions.https.HttpsError('not-found', 'Invitación no encontrada o ya procesada.');
  }

  const invDoc = invitationsSnap.docs[0];
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

  await invDoc.ref.update({
    status: 'accepted',
    respondedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log(`Invitation ${invDoc.id} marked accepted by ${uid}`);
  return { success: true, invitationId: invDoc.id };
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

/** Busca userId por email. Solo acepta el email principal del usuario (T216: no se aceptan alias como user+alias@gmail.com). */
async function findUserIdByEmail(db, fromEmail) {
  const normalized = (fromEmail || '').toLowerCase().trim();
  if (!normalized) return null;
  const snap = await db.collection(USERS_COLLECTION).where('email', '==', normalized).limit(1).get();
  return snap.empty ? null : snap.docs[0].id;
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
async function processInboundEmail(db, { from, subject, bodyPlain }) {
  const fromTrimmed = (from || '').trim();
  const subjectTrimmed = (subject || '').trim();
  if (!fromTrimmed || !subjectTrimmed) {
    return { success: false, error: 'from and subject required', code: 'invalid_argument' };
  }
  const plain = (bodyPlain !== undefined && bodyPlain !== null) ? String(bodyPlain) : '';

  const userId = await findUserIdByEmail(db, fromTrimmed);
  if (!userId) {
    console.warn(`processInboundEmail: From not registered: ${fromTrimmed}`);
    return { success: false, error: 'Sender email is not a registered user', code: 'from_not_registered' };
  }

  const countToday = await countPendingEmailsToday(db, userId);
  if (countToday >= RATE_LIMIT_EMAILS_PER_DAY) {
    console.warn(`processInboundEmail: Rate limit exceeded for user ${userId}`);
    return { success: false, error: 'Daily limit reached', code: 'rate_limit_exceeded' };
  }

  const { templateId, parsed } = await runTemplateEngine(db, subjectTrimmed, plain);

  const ref = db.collection(USERS_COLLECTION).doc(userId).collection(PENDING_EMAIL_EVENTS_COLLECTION).doc();
  const now = admin.firestore.FieldValue.serverTimestamp();
  await ref.set({
    subject: subjectTrimmed,
    bodyPlain: plain,
    fromEmail: fromTrimmed,
    parsed: parsed || null,
    templateId: templateId || null,
    status: 'pending',
    createdAt: now,
    updatedAt: now,
  });
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
  const db = admin.firestore();
  const result = await processInboundEmail(db, { from, subject, bodyPlain });

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
// Cloud Scheduler llama a processInboundGmail cada X minutos.
// ============================================

const GMAIL_SCOPES = ['https://www.googleapis.com/auth/gmail.readonly', 'https://www.googleapis.com/auth/gmail.modify'];

/** Devuelve la lista de buzones a procesar. Soporta uno (string) o varios (coma-separados o JSON array). */
function getMailboxList() {
  const single = process.env.GMAIL_INBOUND_MAILBOX || functions.config().gmail_inbound?.mailbox;
  const listRaw = process.env.GMAIL_INBOUND_MAILBOX_LIST || functions.config().gmail_inbound?.mailbox_list;
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
  return [];
}

function getGmailClientForMailbox(mailbox) {
  if (!mailbox) return null;
  let clientEmail;
  let privateKey;
  const saJson = process.env.GMAIL_INBOUND_SA_JSON || functions.config().gmail_inbound?.service_account_json;
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
    clientEmail = process.env.GMAIL_INBOUND_SA_CLIENT_EMAIL || functions.config().gmail_inbound?.client_email;
    privateKey = process.env.GMAIL_INBOUND_SA_PRIVATE_KEY || functions.config().gmail_inbound?.private_key;
    if (privateKey && typeof privateKey === 'string') privateKey = privateKey.replace(/\\n/g, '\n');
  }
  if (!clientEmail || !privateKey) return null;
  const auth = new google.auth.JWT({
    email: clientEmail,
    key: privateKey,
    subject: mailbox,
    scopes: GMAIL_SCOPES,
  });
  return google.gmail({ version: 'v1', auth });
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

function getBodyFromPayload(payload) {
  let textPlain = '';
  let html = '';
  if (payload.body && payload.body.data) {
    const decoded = decodeBase64url(payload.body.data);
    if ((payload.mimeType || '').toLowerCase() === 'text/plain') textPlain = decoded;
    else if ((payload.mimeType || '').toLowerCase() === 'text/html') html = decoded;
    else textPlain = decoded;
  }
  (payload.parts || []).forEach(part => {
    const mime = (part.mimeType || '').toLowerCase();
    const decoded = part.body && part.body.data ? decodeBase64url(part.body.data) : '';
    if (mime === 'text/plain') textPlain = decoded;
    else if (mime === 'text/html') html = decoded;
  });
  if (textPlain.trim()) return textPlain.trim();
  if (html.trim()) return html.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
  return '';
}

/**
 * Procesa un solo buzón: lista no leídos, crea eventos pendientes, marca como leído.
 * Si el buzón falla (cuenta deshabilitada, auth, etc.) lanza; el caller puede seguir con el siguiente.
 */
async function processOneMailbox(gmail, mailboxLabel, db) {
  let processed = 0;
  let errors = 0;
  const listRes = await gmail.users.messages.list({ userId: 'me', q: 'is:unread', maxResults: 50 });
  const messages = listRes.data.messages || [];
  for (const item of messages) {
    try {
      const msgRes = await gmail.users.messages.get({ userId: 'me', id: item.id, format: 'full' });
      const payload = msgRes.data.payload || {};
      const fromHeader = getHeader(payload, 'From');
      const from = extractEmailFromHeader(fromHeader);
      const subject = getHeader(payload, 'Subject');
      const bodyPlain = getBodyFromPayload(payload);
      const result = await processInboundEmail(db, { from, subject, bodyPlain });
      if (result.success) processed++;
      else errors++;
      await gmail.users.messages.modify({ userId: 'me', id: item.id, requestBody: { removeLabelIds: ['UNREAD'] } });
    } catch (err) {
      console.error(`processInboundGmail [${mailboxLabel}]: Error processing message ${item.id}`, err);
      errors++;
    }
  }
  return { processed, errors, total: messages.length };
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
  const secret = process.env.GMAIL_POLL_SECRET || functions.config().gmail_inbound?.poll_secret;
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


