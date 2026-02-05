#!/bin/bash
# Script para configurar Gmail SMTP en Firebase Functions
# Reemplaza TU_EMAIL@gmail.com con tu email real

# 1. Configurar email de Gmail
firebase functions:config:set gmail.user="TU_EMAIL@gmail.com"

# 2. Configurar App Password (sin espacios o con espacios, ambos funcionan)
firebase functions:config:set gmail.password="wnyn yinh uefh dwcf"

# 3. Configurar email remitente (puede ser el mismo)
firebase functions:config:set gmail.from="TU_EMAIL@gmail.com"

# 4. Configurar URL base para desarrollo local
firebase functions:config:set app.base_url="http://localhost:60508"

# 5. Verificar la configuración
echo "Verificando configuración..."
firebase functions:config:get
