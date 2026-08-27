import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

/// Tokens y bloques UI estilo iOS Settings (propuesta D).
/// Reutilizable en Info plan y, más adelante, evento / alojamiento.
class IosFormColors {
  IosFormColors._();

  static const Color pageBg = Color(0xFF000000);
  static const Color groupedBg = Color(0xFF1C1C1E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99EBEBF5);
  static const Color textTertiary = Color(0x4DEBEBF5);
  static const Color separator = Color(0x99545458);
  static const Color danger = Color(0xFFFF453A);
  static Color get accent => AppColorScheme.color2;

  /// Sangría en árbol bajo secciones colapsables (0 = fila raíz, 1 = hijo, 2 = nieto).
  static const double nestBase = 16;
  static const double nestStep = 12;
  static double nestPaddingLeft(int level) => nestBase + nestStep * level;
}

class IosSectionLabel extends StatelessWidget {
  const IosSectionLabel(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: IosFormColors.textTertiary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08,
        ),
      ),
    );
  }
}

class IosGroupedCard extends StatelessWidget {
  const IosGroupedCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Material (no DecoratedBox): ListTile/CheckboxListTile necesitan Material
    // propio o ancestro sin caja opaca intermedia (ink invisible assertion).
    return Material(
      color: IosFormColors.groupedBg,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class IosRowSeparator extends StatelessWidget {
  const IosRowSeparator({super.key, this.nestLevel = 0});

  /// Sangría alineada con [IosSettingsRow.nestLevel] de las filas del bloque.
  final int nestLevel;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: IosFormColors.nestPaddingLeft(nestLevel),
      color: IosFormColors.separator,
    );
  }
}

class IosSettingsRow extends StatelessWidget {
  const IosSettingsRow({
    super.key,
    required this.label,
    required this.value,
    this.chevron = false,
    this.multiline = false,
    this.nestLevel = 0,
    this.valueColor,
    this.valueDotColor,
    this.onTap,
  });

  final String label;
  final String value;
  final bool chevron;
  final bool multiline;
  /// 0 = fila raíz; ≥1 = hijo (label secundario, valor primario, sangría).
  final int nestLevel;
  final Color? valueColor;
  final Color? valueDotColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? '—' : value;
    final nested = nestLevel > 0;
    final labelColor =
        nested ? IosFormColors.textSecondary : IosFormColors.textPrimary;
    final defaultValueColor =
        nested ? IosFormColors.textPrimary : IosFormColors.textSecondary;
    final resolvedValueColor = valueColor ?? defaultValueColor;
    final horizontal = IosFormColors.nestPaddingLeft(nestLevel);

    final child = Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 12, 16, 12),
      child: multiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  display,
                  style: TextStyle(
                    color: resolvedValueColor,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (valueDotColor != null) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: valueDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          display,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: resolvedValueColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      if (chevron) ...[
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right,
                          color: IosFormColors.textTertiary,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

class IosEditField extends StatelessWidget {
  const IosEditField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.hint,
    this.onChanged,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: IosFormColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            minLines: minLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            validator: validator,
            style: const TextStyle(
              color: IosFormColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: IosFormColors.accent,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: const TextStyle(
                color: IosFormColors.textTertiary,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecera plegable estilo Settings (participantes, avisos, meta…).
class IosCollapsibleHeader extends StatelessWidget {
  const IosCollapsibleHeader({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    this.trailing,
    this.subtitle,
    this.titleColor,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget? trailing;
  /// Texto secundario a la derecha (p. ej. contador).
  final String? subtitle;
  /// Color del título (p. ej. peligro). Por defecto `textPrimary`.
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor ?? IosFormColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: IosFormColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 4),
              ],
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: titleColor ?? IosFormColors.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aviso informativo dentro del patrón D (p. ej. plan solo lectura).
class IosInfoBanner extends StatelessWidget {
  const IosInfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IosFormColors.groupedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9F0A).withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF9F0A), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: IosFormColors.textSecondary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IosExpandableText extends StatelessWidget {
  const IosExpandableText({
    super.key,
    required this.text,
    required this.expanded,
    required this.onToggle,
    required this.seeMoreLabel,
    required this.seeLessLabel,
    this.emptyLabel = '—',
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  final String seeMoreLabel;
  final String seeLessLabel;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final trimmed = text.trim();
    final empty = trimmed.isEmpty;
    final long = trimmed.length > 80;
    return InkWell(
      onTap: (!empty && long) ? onToggle : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              empty ? emptyLabel : trimmed,
              maxLines: expanded || empty ? null : 2,
              overflow:
                  expanded || empty ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                color: empty
                    ? IosFormColors.textTertiary
                    : IosFormColors.textPrimary,
                fontSize: 16,
                height: 1.35,
              ),
            ),
            if (!empty && long) ...[
              const SizedBox(height: 6),
              Text(
                expanded ? seeLessLabel : seeMoreLabel,
                style: TextStyle(
                  color: IosFormColors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class IosHeroChipData {
  const IosHeroChipData(
    this.label, {
    this.accent = false,
    this.color,
    this.onTap,
  });
  final String label;
  final bool accent;
  /// Si se define, pinta el chip con este color (p. ej. estado borrador/confirmado).
  final Color? color;
  final VoidCallback? onTap;
}

class IosHeroHeader extends StatelessWidget {
  const IosHeroHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.onSubtitleTap,
    this.chip,
    this.chipAccent = false,
    this.chips = const [],
    this.leading,
  });

  /// Si es null o vacío (p. ej. embebido bajo AppBar con el mismo nombre), se omite.
  final String? title;
  /// Sustituye el título de texto (p. ej. campo editable).
  final Widget? titleWidget;
  /// Si es null o vacío, no se pinta (p. ej. el tipo ya va en una sección abajo).
  final String? subtitle;
  /// Si no es null, el subtítulo es pulsable (p. ej. editar fechas).
  final VoidCallback? onSubtitleTap;
  final String? chip;
  final bool chipAccent;
  final List<IosHeroChipData> chips;
  /// Avatar u otro widget a la izquierda del bloque de título.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final allChips = <IosHeroChipData>[
      ...chips,
      if (chip != null) IosHeroChipData(chip!, accent: chipAccent),
    ];
    final showTitleWidget = titleWidget != null;
    final showTitle = !showTitleWidget &&
        title != null &&
        title!.trim().isNotEmpty;
    final showSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    Widget? subtitleChild;
    if (showSubtitle) {
      subtitleChild = Text(
        subtitle!.trim(),
        style: const TextStyle(
          color: IosFormColors.textSecondary,
          fontSize: 15,
          height: 1.3,
        ),
      );
      if (onSubtitleTap != null) {
        subtitleChild = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSubtitleTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: subtitleChild),
                  const Icon(
                    Icons.chevron_right,
                    color: IosFormColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitleWidget) ...[
          titleWidget!,
          if (showSubtitle || allChips.isNotEmpty) const SizedBox(height: 6),
        ] else if (showTitle) ...[
          Text(
            title!.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: IosFormColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
          if (showSubtitle || allChips.isNotEmpty) const SizedBox(height: 6),
        ],
        if (subtitleChild != null) subtitleChild,
        if (allChips.isNotEmpty) ...[
          if (subtitleChild != null) const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in allChips)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: c.onTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.color != null
                            ? c.color!.withValues(alpha: 0.22)
                            : c.accent
                                ? IosFormColors.accent.withValues(alpha: 0.22)
                                : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c.label,
                        style: TextStyle(
                          color: c.color ??
                              (c.accent
                                  ? IosFormColors.accent
                                  : IosFormColors.textSecondary),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: leading == null
          ? textBlock
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leading!,
                const SizedBox(width: 14),
                Expanded(child: textBlock),
              ],
            ),
    );
  }
}

/// Barra iOS: dismiss (X) · título · confirmar (✓), o texto Cancelar/Guardar.
class IosFormEditBar extends StatelessWidget {
  const IosFormEditBar({
    super.key,
    required this.editing,
    required this.canEdit,
    required this.editLabel,
    required this.cancelLabel,
    required this.saveLabel,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
    this.saving = false,
    this.title,
    this.centeredTitle = false,
    /// Modal tipo ficha iOS: círculo gris con X · título · círculo acento con ✓.
    this.modalIconActions = false,
  });

  final bool editing;
  final bool canEdit;
  final bool saving;
  final String editLabel;
  final String cancelLabel;
  final String saveLabel;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String? title;
  /// Título centrado; acciones a izquierda/derecha (estilo nav iOS).
  final bool centeredTitle;
  final bool modalIconActions;

  static const _titleStyle = TextStyle(
    color: IosFormColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  static const double _iconSlot = 36;

  Widget _barAction({
    required VoidCallback? onPressed,
    required Widget child,
    required _BarActionStyle style,
  }) {
    final bool enabled = onPressed != null;
    late final Color bg;
    late final Color fg;
    switch (style) {
      case _BarActionStyle.cancel:
        bg = enabled
            ? const Color(0xFF48484A)
            : const Color(0xFF48484A).withValues(alpha: 0.45);
        fg = enabled ? IosFormColors.textPrimary : IosFormColors.textTertiary;
      case _BarActionStyle.save:
        bg = enabled
            ? IosFormColors.accent.withValues(alpha: 0.88)
            : IosFormColors.accent.withValues(alpha: 0.35);
        fg = IosFormColors.textPrimary;
      case _BarActionStyle.edit:
        bg = enabled
            ? IosFormColors.accent.withValues(alpha: 0.55)
            : IosFormColors.accent.withValues(alpha: 0.25);
        fg = IosFormColors.textPrimary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: fg,
              fontSize: 15,
              fontWeight: style == _BarActionStyle.save
                  ? FontWeight.w600
                  : FontWeight.w500,
              letterSpacing: -0.24,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _iconCircleButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required Color backgroundColor,
    required String tooltip,
    double iconSize = 15,
    bool loading = false,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: _iconSlot,
        minHeight: _iconSlot,
      ),
      icon: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onPressed == null
              ? backgroundColor.withValues(alpha: 0.45)
              : backgroundColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: loading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: IosFormColors.textPrimary,
                ),
              )
            : Icon(
                icon,
                size: iconSize,
                color: IosFormColors.textPrimary,
              ),
      ),
    );
  }

  Widget _leadingAction({required bool showDismiss}) {
    if (!showDismiss) {
      return const SizedBox(width: _iconSlot);
    }
    if (modalIconActions) {
      return _iconCircleButton(
        onPressed: saving ? null : onCancel,
        icon: CupertinoIcons.xmark,
        backgroundColor: const Color(0xFF48484A),
        tooltip: cancelLabel,
        iconSize: 14,
      );
    }
    if (canEdit && editing) {
      return _barAction(
        onPressed: saving ? null : onCancel,
        style: _BarActionStyle.cancel,
        child: Text(cancelLabel),
      );
    }
    return const SizedBox(width: 8);
  }

  Widget _trailingAction() {
    if (!canEdit) {
      return SizedBox(width: modalIconActions ? _iconSlot : 8);
    }
    if (editing) {
      if (modalIconActions) {
        return _iconCircleButton(
          onPressed: saving ? null : onSave,
          icon: CupertinoIcons.checkmark,
          backgroundColor: IosFormColors.accent,
          tooltip: saveLabel,
          iconSize: 16,
          loading: saving,
        );
      }
      return _barAction(
        onPressed: saving ? null : onSave,
        style: _BarActionStyle.save,
        child: saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: IosFormColors.textPrimary,
                ),
              )
            : Text(saveLabel),
      );
    }
    if (modalIconActions) {
      return const SizedBox(width: _iconSlot);
    }
    return _barAction(
      onPressed: onEdit,
      style: _BarActionStyle.edit,
      child: Text(editLabel),
    );
  }

  BoxDecoration get _barDecoration => BoxDecoration(
        color: IosFormColors.groupedBg,
        border: Border(
          bottom: BorderSide(
            color: IosFormColors.separator.withValues(alpha: 0.6),
          ),
        ),
      );

  bool get _showDismiss =>
      modalIconActions || (canEdit && editing);

  @override
  Widget build(BuildContext context) {
    if (centeredTitle && title != null) {
      return Container(
        height: 48,
        decoration: _barDecoration,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            _leadingAction(showDismiss: _showDismiss),
            Expanded(
              child: Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: _titleStyle,
              ),
            ),
            _trailingAction(),
          ],
        ),
      );
    }

    if (!canEdit) {
      if (title == null) return const SizedBox.shrink();
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _barDecoration,
        alignment: Alignment.centerLeft,
        child: Text(
          title!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _titleStyle,
        ),
      );
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: _barDecoration,
      child: Row(
        children: [
          if (editing)
            _barAction(
              onPressed: saving ? null : onCancel,
              style: _BarActionStyle.cancel,
              child: Text(
                cancelLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else if (title != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _titleStyle,
                ),
              ),
            ),
          if (editing) ...[
            if (title != null)
              Expanded(
                child: Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: _titleStyle,
                ),
              )
            else
              const Spacer(),
            _barAction(
              onPressed: saving ? null : onSave,
              style: _BarActionStyle.save,
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: IosFormColors.textPrimary,
                      ),
                    )
                  : Text(
                      saveLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ] else ...[
            const Spacer(),
            _barAction(
              onPressed: onEdit,
              style: _BarActionStyle.edit,
              child: Text(
                editLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _BarActionStyle { cancel, save, edit }

/// Segment control iOS (General · Mi info · …).
class IosSegmentedControl extends StatelessWidget {
  const IosSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.fontSize = 13,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: IosFormColors.groupedBg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? const Color(0xFF636366)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: selectedIndex == i
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: selectedIndex == i
                          ? IosFormColors.textPrimary
                          : IosFormColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Muestra de color grande y legible (sin nombre).
class IosFormColorSwatch extends StatelessWidget {
  const IosFormColorSwatch({
    super.key,
    required this.color,
    this.size = 32,
    this.selected = false,
    this.showCheck = false,
  });

  final Color color;
  final double size;
  final bool selected;
  final bool showCheck;

  static Color _checkColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.55 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.65),
          width: selected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: (selected && showCheck)
          ? Icon(
              Icons.check_rounded,
              color: _checkColor(color),
              size: size * 0.52,
            )
          : null,
    );
  }
}

/// Fila Settings: etiqueta + muestra de color (sin nombre del color).
class IosColorSettingRow extends StatelessWidget {
  const IosColorSettingRow({
    super.key,
    required this.label,
    required this.color,
    this.chevron = false,
    this.onTap,
  });

  final String label;
  final Color color;
  final bool chevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const rowHeight = 48.0;
    final child = SizedBox(
      height: rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: IosFormColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            IosFormColorSwatch(color: color, size: 32),
            if (chevron) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                color: IosFormColors.textTertiary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

/// Fila Settings con interruptor a la derecha (p. ej. «Para todos»).
class IosSwitchRow extends StatelessWidget {
  const IosSwitchRow({
    super.key,
    required this.label,
    required this.value,
    this.nestLevel = 0,
    this.onChanged,
  });

  final String label;
  final bool value;
  final int nestLevel;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final nested = nestLevel > 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        IosFormColors.nestPaddingLeft(nestLevel),
        6,
        16,
        6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: nested
                    ? IosFormColors.textSecondary
                    : IosFormColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: IosFormColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Fila seleccionable con check a la derecha (lista multi-select Settings).
class IosCheckRow extends StatelessWidget {
  const IosCheckRow({
    super.key,
    required this.label,
    this.value = '',
    required this.selected,
    this.indented = false,
    this.nestLevel = 0,
    this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  /// Sangría bajo un control padre (equivale a [nestLevel] 1 si no se pasa).
  final bool indented;
  final int nestLevel;
  final VoidCallback? onTap;

  int get _level => indented ? (nestLevel > 0 ? nestLevel : 1) : nestLevel;

  @override
  Widget build(BuildContext context) {
    final nested = _level > 0;
    final child = Padding(
      padding: EdgeInsets.fromLTRB(IosFormColors.nestPaddingLeft(_level), 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: nested
                    ? IosFormColors.textSecondary
                    : IosFormColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (value.trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value.trim(),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: nested
                      ? IosFormColors.textPrimary
                      : IosFormColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
          SizedBox(
            width: 28,
            child: selected
                ? Icon(Icons.check, color: IosFormColors.accent, size: 22)
                : null,
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

/// Pie bajo una card (hint o error); no usa mayúsculas de sección.
class IosFormFooter extends StatelessWidget {
  const IosFormFooter(
    this.text, {
    super.key,
    this.color,
    this.nestLevel = 0,
  });

  final String text;
  final Color? color;
  final int nestLevel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        IosFormColors.nestPaddingLeft(nestLevel),
        8,
        16,
        0,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? IosFormColors.textTertiary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.3,
        ),
      ),
    );
  }
}

/// Subtítulo dentro de una card agrupada.
class IosGroupedCardCaption extends StatelessWidget {
  const IosGroupedCardCaption(this.text, {super.key, this.nestLevel = 0});
  final String text;
  final int nestLevel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        IosFormColors.nestPaddingLeft(nestLevel),
        10,
        16,
        2,
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: IosFormColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class IosFormPickerOption<T> {
  const IosFormPickerOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.selected = false,
  });

  final T value;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
}

/// Bottom sheet unificado para pickers de formulario (estado, visibilidad, TZ…).
class IosFormPickerSheet {
  IosFormPickerSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required List<IosFormPickerOption<T>> options,
    double maxHeightFactor = 0.55,
  }) {
    if (options.isEmpty) return Future.value(null);

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: IosFormColors.groupedBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        final maxHeight = MediaQuery.sizeOf(ctx).height * maxHeightFactor;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: IosFormColors.separator,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: IosFormColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      color: IosFormColors.separator,
                    ),
                    itemBuilder: (context, index) {
                      final opt = options[index];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        leading: opt.leading,
                        title: Text(
                          opt.title,
                          style: const TextStyle(
                            color: IosFormColors.textPrimary,
                            fontSize: 17,
                          ),
                        ),
                        subtitle: opt.subtitle == null
                            ? null
                            : Text(
                                opt.subtitle!,
                                style: const TextStyle(
                                  color: IosFormColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                        trailing: opt.selected
                            ? Icon(Icons.check, color: IosFormColors.accent)
                            : opt.trailing,
                        onTap: () => Navigator.of(ctx).pop(opt.value),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class IosFormColorPickerOption {
  const IosFormColorPickerOption({required this.id, required this.color});
  final String id;
  final Color color;
}

/// Bottom sheet unificado para elegir color (rejilla de muestras).
class IosFormColorPickerSheet {
  IosFormColorPickerSheet._();

  static Future<String?> show({
    required BuildContext context,
    required String title,
    required List<IosFormColorPickerOption> options,
    required String selectedId,
  }) {
    if (options.isEmpty) return Future.value(null);

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: IosFormColors.groupedBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: IosFormColors.separator,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: IosFormColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: options.map((opt) {
                    final selected = opt.id == selectedId;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(ctx).pop(opt.id),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: IosFormColorSwatch(
                            color: opt.color,
                            size: 40,
                            selected: selected,
                            showCheck: true,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Acciones inferiores de un bottom sheet (Cancelar / Aplicar).
class IosFormSheetActions extends StatelessWidget {
  const IosFormSheetActions({
    super.key,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.confirmDestructive = false,
  });

  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool confirmDestructive;

  @override
  Widget build(BuildContext context) {
    final confirmBg = confirmDestructive
        ? IosFormColors.danger.withValues(alpha: 0.28)
        : IosFormColors.accent.withValues(alpha: 0.32);
    final confirmBorder = confirmDestructive
        ? IosFormColors.danger.withValues(alpha: 0.55)
        : IosFormColors.accent.withValues(alpha: 0.55);

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCancel,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  cancelLabel,
                  style: const TextStyle(
                    color: IosFormColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onConfirm,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: confirmBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: confirmBorder),
                ),
                alignment: Alignment.center,
                child: Text(
                  confirmLabel,
                  style: const TextStyle(
                    color: IosFormColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IosFormActionSheetOption<T> {
  const IosFormActionSheetOption({
    required this.value,
    required this.label,
    this.primary = false,
    this.destructive = false,
    this.cancel = false,
  });

  final T value;
  final String label;
  final bool primary;
  final bool destructive;
  final bool cancel;
}

/// Bottom sheet con acciones apiladas (p. ej. cambios sin guardar).
class IosFormActionSheet {
  IosFormActionSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<IosFormActionSheetOption<T>> options,
  }) {
    if (options.isEmpty) return Future.value(null);

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: IosFormColors.groupedBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: IosFormColors.separator,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (title != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: IosFormColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: IosFormColors.textSecondary,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                IosGroupedCard(
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0) const IosRowSeparator(),
                      _ActionSheetRow(
                        label: options[i].label,
                        primary: options[i].primary,
                        destructive: options[i].destructive,
                        cancelStyle: options[i].cancel,
                        onTap: () => Navigator.of(ctx).pop(options[i].value),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionSheetRow extends StatelessWidget {
  const _ActionSheetRow({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.destructive = false,
    this.cancelStyle = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool destructive;
  final bool cancelStyle;

  @override
  Widget build(BuildContext context) {
    Color color = IosFormColors.textPrimary;
    FontWeight weight = FontWeight.w400;
    if (primary) {
      color = IosFormColors.accent;
      weight = FontWeight.w600;
    } else if (destructive) {
      color = IosFormColors.danger;
      weight = FontWeight.w600;
    } else if (cancelStyle) {
      color = IosFormColors.textSecondary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: weight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirmación simple Cancelar / Confirmar en bottom sheet.
class IosFormConfirmSheet {
  IosFormConfirmSheet._();

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String cancelLabel,
    required String confirmLabel,
    bool destructive = false,
    bool barrierDismissible = true,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: barrierDismissible,
      enableDrag: barrierDismissible,
      backgroundColor: IosFormColors.groupedBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: IosFormColors.separator,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: IosFormColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: IosFormColors.textSecondary,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                IosFormSheetActions(
                  cancelLabel: cancelLabel,
                  confirmLabel: confirmLabel,
                  confirmDestructive: destructive,
                  onCancel: () => Navigator.of(ctx).pop(false),
                  onConfirm: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}

class IosDestructiveTile extends StatelessWidget {
  const IosDestructiveTile({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: IosFormColors.groupedBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: IosFormColors.danger,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
