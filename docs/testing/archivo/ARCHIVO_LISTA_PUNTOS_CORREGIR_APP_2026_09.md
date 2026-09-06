# Archivo — Lista de puntos corregidos (cerrados 2026-09)

**Documento histórico (solo lectura).**

- **Origen:** `LISTA_PUNTOS_CORREGIR_APP.md`.
- **Fecha de archivado:** 2026-09-01.
- **Rango:** **143**.

---

#### 143. Comunicaciones: imágenes cid y anexos del mail
- **Fix:** MIME en `processInboundGmail` → Storage `communication_files/`; `cid:` reescrito en HTML; notas manuales con foto/PDF; `placeOn` relee el pending y copia `attachments`.
- **Estado:** cerrado y validado en app (2026-09-01)
- **Referencias:** `COMUNICACIONES_MAIL_PLAN.md`; `functions/index.js` (`ingestGmailAttachments`); `communication_file_service.dart`; `compose_communication_sheet.dart`
