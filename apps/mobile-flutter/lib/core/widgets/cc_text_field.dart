import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Labelled text field: label always visible above the value, error text in
/// plain language below it, both merged into the field's accessible name.
///
/// Errors say exactly what is wrong and how to fix it ("Enter the dose, like
/// 25 mg") rather than "Required field" alone.
class CcTextField extends StatelessWidget {
  const CcTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.ccColors;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodyEmphasis.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: Space.xs + 2),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              errorMaxLines: 3,
              suffixIcon: readOnly && onTap != null
                  ? Icon(Icons.edit_calendar, color: colors.textSecondary)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
