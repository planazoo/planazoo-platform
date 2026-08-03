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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file, size: 20, color: Colors.white70),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              if (canManage)
                TextButton.icon(
                  onPressed: (isUploading || onUpload == null) ? null : onUpload,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColorScheme.color2,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: isUploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file, size: 18),
                  label: Text(
                    isUploading
                        ? loc.entityAttachmentsUploading
                        : loc.entityAttachmentsUpload,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (files.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                loc.entityAttachmentsEmpty,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white60,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: files.map((file) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 30),
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
                              fontWeight: FontWeight.w500,
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
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      if (canManage) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: loc.entityAttachmentsDeleteTitle,
                          onPressed: isUploading ? null : () => onDelete(file),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: Colors.red.shade300,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
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
