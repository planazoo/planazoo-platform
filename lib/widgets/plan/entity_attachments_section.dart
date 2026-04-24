import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Barra de archivos adjuntos (PDF/JPG/PNG) para eventos y alojamientos — mismo patrón que Info del plan.
class EntityAttachmentsSection extends StatelessWidget {
  final String title;
  final List<EventDocument> files;
  final bool canManage;
  final bool isUploading;
  final VoidCallback? onUpload;
  final void Function(EventDocument doc) onDelete;

  const EntityAttachmentsSection({
    super.key,
    required this.title,
    required this.files,
    required this.canManage,
    required this.isUploading,
    required this.onUpload,
    required this.onDelete,
  });

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  static Future<void> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12).withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
              if (canManage)
                TextButton.icon(
                  onPressed: (isUploading || onUpload == null) ? null : onUpload,
                  icon: isUploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file, size: 16),
                  label: Text(
                    isUploading ? loc.entityAttachmentsUploading : loc.entityAttachmentsUpload,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (files.isEmpty)
            Text(
              'Sin archivos adjuntos',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: files.map((file) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => openUrl(file.url),
                          child: Text(
                            file.name,
                            style: GoogleFonts.poppins(
                              color: AppColorScheme.color2,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatFileSize(file.size),
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                      ),
                      if (canManage) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: loc.entityAttachmentsDeleteTitle,
                          onPressed: isUploading ? null : () => onDelete(file),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: Colors.red.shade300,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
