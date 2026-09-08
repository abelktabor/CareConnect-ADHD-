import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// One option in a single-select group (the round "15 min / 1 hour / 1 day"
/// chips, and the "I am a…" role cards).
///
/// Exposed to assistive tech as a radio-style item: mutually exclusive,
/// with a checked state, so the selection is announced without colour.
class ChoiceOption<T> {
  const ChoiceOption({required this.value, required this.label, this.spoken});

  final T value;
  final String label;
  final String? spoken;
}

class ChoiceGroup<T> extends StatelessWidget {
  const ChoiceGroup({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.groupLabel,
    this.circular = false,
    super.key,
  });

  final List<ChoiceOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  /// Announced as the group's name ("Reminder lead time").
  final String groupLabel;

  /// Round chips (Notifications screen) instead of rectangular cards.
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: groupLabel,
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: Space.sm + 4),
            Expanded(
              child: _Choice<T>(
                option: options[i],
                selected: options[i].value == selected,
                circular: circular,
                onTap: () => onSelected(options[i].value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Choice<T> extends StatelessWidget {
  const _Choice({
    required this.option,
    required this.selected,
    required this.circular,
    required this.onTap,
  });

  final ChoiceOption<T> option;
  final bool selected;
  final bool circular;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ccColors;
    final primary = theme.colorScheme.primary;
    final shape = circular
        ? const StadiumBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CcRadius.md),
          );

    return MergeSemantics(
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        button: true,
        label: option.spoken ?? option.label,
        child: Material(
          color: selected ? primary : theme.colorScheme.surface,
          shape: shape.copyWith(
            side: BorderSide(
              color: selected ? primary : colors.border,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: shape,
            child: ExcludeSemantics(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: circular ? 64 : TapTarget.dominantAction,
                  minWidth: TapTarget.minimum,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.sm,
                      vertical: Space.sm,
                    ),
                    child: Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyEmphasis.copyWith(
                        color: selected ? theme.colorScheme.onPrimary : primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
