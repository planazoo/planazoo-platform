import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

/// Modal intermedio: resumen del evento con enlace a abrir el evento completo.
void showEventSummaryPreviewModal({
  required BuildContext context,
  required Event event,
  required VoidCallback onOpenFull,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.grey.shade900,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            event.description,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Fecha',
            value: DateFormatter.formatDate(event.date),
          ),
          _DetailRow(
            icon: Icons.access_time,
            label: 'Hora',
            value: '${event.hour.toString().padLeft(2, '0')}:${event.startMinute.toString().padLeft(2, '0')}',
          ),
          if (event.typeFamily != null && event.typeFamily!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.category_outlined,
              label: 'Tipo',
              value: '${event.typeFamily}${event.typeSubtype != null ? ' · ${event.typeSubtype}' : ''}',
            ),
          ],
          if (event.commonPart?.location != null && event.commonPart!.location!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.place_outlined,
              label: 'Lugar',
              value: event.commonPart!.location!,
            ),
          ],
          if (event.cost != null && event.cost! > 0) ...[
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.payments_outlined,
              label: 'Coste',
              value: '${event.cost!.toStringAsFixed(2)}',
            ),
          ],
          if (event.commonPart?.url != null && event.commonPart!.url!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _LinkRow(
              icon: Icons.link,
              label: 'Enlace',
              url: event.commonPart!.url!.trim(),
            ),
          ],
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onOpenFull();
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Abrir evento'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorScheme.color2,
              side: const BorderSide(color: AppColorScheme.color2),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Modal intermedio: resumen del alojamiento con enlace a abrir el alojamiento completo.
void showAccommodationSummaryPreviewModal({
  required BuildContext context,
  required Accommodation accommodation,
  required VoidCallback onOpenFull,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.grey.shade900,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            accommodation.hotelName,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.login,
            label: 'Check-in',
            value: DateFormatter.formatDate(accommodation.checkIn),
          ),
          _DetailRow(
            icon: Icons.logout,
            label: 'Check-out',
            value: DateFormatter.formatDate(accommodation.checkOut),
          ),
          if (accommodation.description != null && accommodation.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.description_outlined,
              label: 'Descripción',
              value: accommodation.description!,
            ),
          ],
          if (accommodation.commonPart?.address != null && accommodation.commonPart!.address!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.place_outlined,
              label: 'Dirección',
              value: accommodation.commonPart!.address!,
            ),
          ],
          if (accommodation.cost != null && accommodation.cost! > 0) ...[
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.payments_outlined,
              label: 'Coste',
              value: '${accommodation.cost!.toStringAsFixed(2)}',
            ),
          ],
          if (accommodation.commonPart?.url != null && accommodation.commonPart!.url!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _LinkRow(
              icon: Icons.link,
              label: 'Enlace',
              url: accommodation.commonPart!.url!.trim(),
            ),
          ],
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onOpenFull();
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Abrir alojamiento'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorScheme.color2,
              side: const BorderSide(color: AppColorScheme.color2),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila con enlace web clicable.
class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.url,
  });

  Future<void> _openUrl() async {
    var uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      uri = Uri.tryParse('https://$url');
    }
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              InkWell(
                onTap: _openUrl,
                borderRadius: BorderRadius.circular(4),
                child: Text(
                  url,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColorScheme.color2,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
