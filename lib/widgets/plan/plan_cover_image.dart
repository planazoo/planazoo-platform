import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';

/// Foto de portada del plan. En web usa HTML para no quedarse negra al cerrar
/// el mapa (Maps WebGL / CanvasKit).
///
/// W5 (circular): un `div` **opaco**. Las esquinas transparentes de un
/// `ClipOval` / `border-radius` se pintan negras en CanvasKit.
class PlanCoverImage extends StatelessWidget {
  const PlanCoverImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.circular = false,
    this.placeholder,
    this.error,
    this.webMaskColor = const Color(0xFF111827),
    this.webBorderColor,
  });

  final String? imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool circular;
  final Widget? placeholder;
  final Widget? error;

  /// Color de las esquinas en W5 (mismo que el header).
  final Color webMaskColor;
  final Color? webBorderColor;

  bool get _valid => ImageService.isValidImageUrl(imageUrl);

  static String _cssHex(Color c) {
    final v = c.toARGB32();
    final r = (v >> 16) & 0xFF;
    final g = (v >> 8) & 0xFF;
    final b = v & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  static void _styleCircularCover({
    required Object element,
    required String url,
    required Color mask,
    required Color border,
  }) {
    final style = (element as dynamic).style;
    final maskHex = _cssHex(mask);
    final borderHex = _cssHex(border);
    final safeUrl = url.replaceAll(r'\', r'\\').replaceAll("'", '%27');
    style.width = '100%';
    style.height = '100%';
    style.backgroundColor = maskHex;
    // Capa superior opaca (anillo + esquinas); el centro deja ver la foto.
    // Todo el cuadrado queda pintado → CanvasKit no rellena de negro.
    style.backgroundImage =
        'radial-gradient(circle closest-side,'
        ' transparent 0%,'
        ' transparent 92%,'
        ' $borderHex 92%,'
        ' $borderHex 100%,'
        ' $maskHex 100%),'
        " url('$safeUrl')";
    style.backgroundSize = '100% 100%, cover';
    style.backgroundPosition = 'center';
    style.backgroundRepeat = 'no-repeat';
    style.pointerEvents = 'none';
  }

  @override
  Widget build(BuildContext context) {
    if (!_valid) {
      return error ?? const SizedBox.shrink();
    }
    final url = imageUrl!;
    final loading = placeholder ??
        ColoredBox(
          color: AppColorScheme.color2.withValues(alpha: 0.1),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
    final fallback = error ?? loading;
    final radius = circular
        ? BorderRadius.circular(999)
        : (borderRadius ?? BorderRadius.circular(8));

    if (kIsWeb) {
      if (circular) {
        return HtmlElementView.fromTagName(
          tagName: 'div',
          onElementCreated: (element) {
            _styleCircularCover(
              element: element,
              url: url,
              mask: webMaskColor,
              border: webBorderColor ?? AppColorScheme.color2,
            );
          },
        );
      }
      return Image.network(
        url,
        fit: fit,
        gaplessPlayback: true,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return loading;
        },
        errorBuilder: (context, error, stack) => fallback,
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (context, _) => loading,
        errorWidget: (context, url, error) => fallback,
      ),
    );
  }
}
