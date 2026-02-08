import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Banner que sugiere actualizar la zona horaria del dispositivo al perfil del usuario.
/// Usado en la página principal cuando [AuthState] indica una sugerencia de timezone.
class WdTimezoneBanner extends ConsumerStatefulWidget {
  final String? configuredTimezone;
  final String deviceTimezone;

  const WdTimezoneBanner({
    super.key,
    required this.configuredTimezone,
    required this.deviceTimezone,
  });

  @override
  ConsumerState<WdTimezoneBanner> createState() => _WdTimezoneBannerState();
}

class _WdTimezoneBannerState extends ConsumerState<WdTimezoneBanner> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final userTz = widget.configuredTimezone ?? widget.deviceTimezone;
    final deviceDisplay = TimezoneService.getTimezoneDisplayName(widget.deviceTimezone);
    final userDisplay = TimezoneService.getTimezoneDisplayName(userTz);
    final shouldShowDifference = widget.configuredTimezone != null &&
        widget.configuredTimezone != widget.deviceTimezone;

    return Container(
      constraints: const BoxConstraints(maxWidth: 640),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.travel_explore, color: AppColorScheme.color2),
              const SizedBox(width: 8),
              Text(
                loc.timezoneBannerTitle,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            loc.timezoneBannerMessage(deviceDisplay, userDisplay),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!shouldShowDifference)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                loc.profileTimezoneDialogDeviceHint,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorScheme.color2,
                      AppColorScheme.color2.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorScheme.color2.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            await ref
                                .read(authNotifierProvider.notifier)
                                .updateDefaultTimezone(widget.deviceTimezone);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loc.timezoneBannerUpdateSuccess),
                                backgroundColor: Colors.green.shade600,
                              ),
                            );
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loc.timezoneBannerUpdateError),
                                backgroundColor: Colors.red.shade600,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          loc.timezoneBannerUpdateButton(deviceDisplay),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).dismissTimezoneSuggestion();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.timezoneBannerKeepMessage(userDisplay)),
                      backgroundColor: Colors.blueGrey.shade700,
                    ),
                  );
                  setState(() => _isLoading = false);
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  loc.timezoneBannerKeepButton(userDisplay),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
