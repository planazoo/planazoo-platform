#!/bin/bash
# Script para configurar Gmail SMTP en Firebase Functions
# Reemplaza TU_EMAIL@gmail.com con tu email real

# ⚠️ SEGURIDAD: En producción, considera usar variables de entorno o Firebase Secret Manager
# en lugar de almacenar credenciales directamente en la configuración.
# Ver: https://firebase.google.com/docs/functions/config-env

# 1. Configurar email de Gmail
firebase functions:config:set gmail.user="TU_EMAIL@gmail.com"

# 2. Configurar App Password (sin espacios o con espacios, ambos funcionan)
# ⚠️ IMPORTANTE: Reemplaza este valor con tu App Password real de Gmail
# Cómo obtenerlo: https://support.google.com/accounts/answer/185833
firebase functions:config:set gmail.password="TU_APP_PASSWORD_AQUI"

# 3. Configurar email remitente (puede ser el mismo)
firebase functions:config:set gmail.from="TU_EMAIL@gmail.com"

# 4. Configurar URL base para desarrollo local
# En producción, cambiar a: https://planazoo.app
firebase functions:config:set app.base_url="http://localhost:60508"

# 5. Verificar la configuración
echo "Verificando configuración..."
firebase functions:config:get

# 6. Validación básica
echo ""
echo "⚠️  Verifica que todos los valores estén configurados correctamente:"
echo "   - gmail.user debe ser tu email de Gmail"
echo "   - gmail.password debe ser tu App Password (16 caracteres)"
echo "   - gmail.from debe ser tu email de Gmail"
echo "   - app.base_url debe ser la URL correcta (localhost para dev, planazoo.app para prod)"
echo ""
echo "Si algún valor está vacío o incorrecto, ejecuta los comandos anteriores manualmente."
