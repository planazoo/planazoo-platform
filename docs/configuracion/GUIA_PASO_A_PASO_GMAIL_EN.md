# 📧 Step-by-Step Guide: Configure Gmail SMTP for Invitations (English)

## 🎯 Objective

Configure invitation emails using **only Google services** (Gmail SMTP).

---

## 📋 Step 1: Create Gmail App Password

### 1.1 Go to your Google Account

1. Open your browser and go to: [myaccount.google.com](https://myaccount.google.com)
2. Sign in with your Gmail account

### 1.2 Enable 2-Step Verification (required)

1. In the left sidebar, click on **"Security"**
2. Find the section **"How you sign in to Google"**
3. Look for **"2-Step Verification"**
4. If it's **disabled**:
   - Click on **"2-Step Verification"**
   - Follow the instructions to enable it
   - You'll need your phone to verify
5. If it's already **enabled**, continue to the next step

### 1.3 Generate App Password

1. In the same **"Security"** page, scroll down to find **"App passwords"**
   - If you don't see it, click on **"2-Step Verification"** first, then look for the link
2. Click on **"App passwords"**
3. A new page will open
4. In **"Select app"**, choose: **"Mail"**
5. In **"Select device"**, choose: **"Other (Custom name)"**
6. Type: **"Firebase Functions"**
7. Click **"Generate"**
8. **⚠️ IMPORTANT!** Copy the password that appears (16 characters, format: `xxxx xxxx xxxx xxxx`)
   - ⚠️ **It only shows once**, save it well
   - Example: `abcd efgh ijkl mnop`

**Alternative path if you don't see "App passwords":**
1. Go to: [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
2. Or: Security → 2-Step Verification → App passwords (at the bottom)

---

## 📋 Step 2: Configure Firebase Functions

### 2.1 Open Terminal

Open your terminal and navigate to the project:

```bash
cd /Users/emmclaraso/development/unp_calendario
```

### 2.2 Verify Firebase CLI is installed

```bash
firebase --version
```

If not installed:
```bash
npm install -g firebase-tools
firebase login
```

### 2.3 Configure Gmail in Firebase Functions

Run these commands **one by one**, replacing with your data:

```bash
# 1. Configure your Gmail email
firebase functions:config:set gmail.user="YOUR_EMAIL@gmail.com"

# 2. Configure the App Password (with or without spaces, both work)
firebase functions:config:set gmail.password="xxxx xxxx xxxx xxxx"

# 3. Configure sender email (can be the same)
firebase functions:config:set gmail.from="YOUR_EMAIL@gmail.com"

# 4. Configure base URL for local development
firebase functions:config:set app.base_url="http://localhost:60508"
```

**Real example:**
```bash
firebase functions:config:set gmail.user="unplanazoo+admin@gmail.com"
firebase functions:config:set gmail.password="abcd efgh ijkl mnop"
firebase functions:config:set gmail.from="unplanazoo+admin@gmail.com"
firebase functions:config:set app.base_url="http://localhost:60508"
```

### 2.4 Verify configuration

```bash
firebase functions:config:get
```

You should see something like:
```
{
  "gmail": {
    "user": "your-email@gmail.com",
    "password": "xxxx xxxx xxxx xxxx",
    "from": "your-email@gmail.com"
  },
  "app": {
    "base_url": "http://localhost:60508"
  }
}
```

---

## 📋 Step 3: Install Dependencies

### 3.1 Install nodemailer

```bash
cd functions
npm install
```

This will install `nodemailer` and all necessary dependencies.

### 3.2 Verify it was installed correctly

```bash
npm list nodemailer
```

You should see: `nodemailer@6.9.7` (or similar version)

---

## 📋 Step 4: Deploy Cloud Function

### 4.1 Go back to project root

```bash
cd ..
```

### 4.2 Deploy only the email function

```bash
firebase deploy --only functions:sendInvitationEmail
```

**If there are lint errors**, you can skip them temporarily:
```bash
firebase deploy --only functions:sendInvitationEmail --no-lint
```

### 4.3 Verify it deployed correctly

You should see a message like:
```
✔  functions[sendInvitationEmail(us-central1)] Successful create operation.
```

---

## 📋 Step 5: Test Email Sending

### 5.1 Create a test invitation

1. Open your app in the browser
2. Go to a plan
3. Go to the **Participants** section
4. Click **"Invite by email"**
5. Enter a test email (can be another email of yours)
6. Send the invitation

### 5.2 Check logs

In another terminal, run:

```bash
firebase functions:log --only sendInvitationEmail
```

You should see messages like:
```
✅ Gmail SMTP configured correctly
✅ Invitation email sent via Gmail SMTP to your-email@example.com
```

### 5.3 Verify email arrived

1. Check the inbox of the email you used
2. If not there, check the **Spam** folder
3. The email should have:
   - Subject: "Invitación a [Plan Name] en Planazoo"
   - "Accept" and "Reject" buttons
   - Invitation link

---

## 🐛 Troubleshooting

### Error: "Gmail SMTP configured correctly" but emails don't arrive

**Solution:**
1. Verify the App Password is correct (16 characters)
2. Verify the Gmail email is spelled correctly
3. Check the Spam folder
4. Check logs: `firebase functions:log --only sendInvitationEmail`

### Error: "No email service configured"

**Solution:**
1. Verify configuration: `firebase functions:config:get`
2. Make sure you ran all configuration commands
3. Redeploy: `firebase deploy --only functions:sendInvitationEmail`

### Error: "Authentication failed"

**Solution:**
1. Verify the App Password is correct (no extra spaces)
2. Make sure you enabled 2-step verification
3. Generate a new App Password if necessary

### Error: "Function not found"

**Solution:**
1. Verify you're in the correct directory
2. Deploy the function: `firebase deploy --only functions:sendInvitationEmail`
3. Check in Firebase Console → Functions that `sendInvitationEmail` appears

---

## ✅ Final Checklist

- [ ] 2-Step Verification enabled
- [ ] App Password generated and copied
- [ ] Firebase Functions configuration completed
- [ ] `nodemailer` installed in `functions/`
- [ ] Cloud Function deployed
- [ ] Test invitation created
- [ ] Email received correctly
- [ ] Logs show "Gmail SMTP" (not SendGrid)

---

## 📝 Important Notes

- **App Password**: Only shows once, save it well
- **Gmail Limits**: 500 emails/day (free), 2,000/day (Google Workspace)
- **Development**: Use `http://localhost:60508` as `app.base_url`
- **Production**: Change to `https://planazoo.app` when deploying to production

---

## 🎉 Done!

If you've completed all steps and receive the invitation email, **it's working!**

Now all invitation emails are sent using **only Google services** (Gmail SMTP).

---

*Last updated: $(date)*
