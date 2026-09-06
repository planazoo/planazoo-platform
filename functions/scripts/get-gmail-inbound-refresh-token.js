/**
 * One-time OAuth for the inbound Gmail mailbox (consumer account).
 * Prints a refresh token for functions.config gmail_inbound.oauth_refresh_token.
 *
 * Usage (from repo root or functions/):
 *   GMAIL_INBOUND_OAUTH_CLIENT_ID=... GMAIL_INBOUND_OAUTH_CLIENT_SECRET=... npm run gmail-inbound-oauth
 *
 * Open the printed URL while signed in as the mailbox owner (the account that
 * receives unplanazoo+eventos@gmail.com).
 */
const http = require("http");
const {google} = require("googleapis");

const PORT = Number(process.env.GMAIL_OAUTH_PORT || 4180);
const clientId = process.env.GMAIL_INBOUND_OAUTH_CLIENT_ID;
const clientSecret = process.env.GMAIL_INBOUND_OAUTH_CLIENT_SECRET;

if (!clientId || !clientSecret) {
  console.error(
      "Set GMAIL_INBOUND_OAUTH_CLIENT_ID and GMAIL_INBOUND_OAUTH_CLIENT_SECRET " +
      "(Desktop OAuth client in GCP project planazoo).",
  );
  process.exit(1);
}

const redirectUri = `http://127.0.0.1:${PORT}/oauth2callback`;
const oauth2 = new google.auth.OAuth2(clientId, clientSecret, redirectUri);
const scopes = [
  "https://www.googleapis.com/auth/gmail.readonly",
  "https://www.googleapis.com/auth/gmail.modify",
];

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url, `http://127.0.0.1:${PORT}`);
    if (url.pathname !== "/oauth2callback") {
      res.writeHead(404);
      res.end();
      return;
    }
    const err = url.searchParams.get("error");
    if (err) {
      res.writeHead(400, {"Content-Type": "text/plain; charset=utf-8"});
      res.end(`OAuth error: ${err}`);
      console.error("OAuth error:", err);
      server.close();
      process.exit(1);
      return;
    }
    const code = url.searchParams.get("code");
    if (!code) {
      res.writeHead(400, {"Content-Type": "text/plain; charset=utf-8"});
      res.end("Missing code");
      return;
    }
    const {tokens} = await oauth2.getToken(code);
    res.writeHead(200, {"Content-Type": "text/html; charset=utf-8"});
    res.end("<p>Autorizado. Cierra esta pestaña y vuelve a la terminal.</p>");
    if (!tokens.refresh_token) {
      console.error(
          "Google no devolvió refresh_token. Revoca el acceso de la app en " +
          "https://myaccount.google.com/permissions y vuelve a ejecutar con prompt=consent.",
      );
      server.close();
      process.exit(1);
      return;
    }
    console.log("\nRefresh token (no lo subas a git):\n");
    console.log(tokens.refresh_token);
    console.log("\nLuego, desde la raíz del repo:\n");
    console.log(
        "npx firebase-tools functions:config:set " +
        `gmail_inbound.mailbox="unplanazoo+eventos@gmail.com" ` +
        `gmail_inbound.oauth_client_id="${clientId}" ` +
        "gmail_inbound.oauth_client_secret=\"…\" " +
        "gmail_inbound.oauth_refresh_token=\"…\"",
    );
    console.log("npx firebase-tools deploy --only functions:processInboundGmail\n");
    server.close();
    process.exit(0);
  } catch (e) {
    console.error(e);
    try {
      res.writeHead(500, {"Content-Type": "text/plain; charset=utf-8"});
      res.end(String(e.message || e));
    } catch (ignored) {
      // already sent
    }
    server.close();
    process.exit(1);
  }
});

server.listen(PORT, "127.0.0.1", () => {
  const authUrl = oauth2.generateAuthUrl({
    access_type: "offline",
    prompt: "consent",
    scope: scopes,
  });
  console.log(`Redirect URI que debe coincidir en el cliente OAuth:\n  ${redirectUri}\n`);
  console.log("Abre esta URL con la cuenta dueña del buzón:\n");
  console.log(authUrl);
  console.log("");
});
