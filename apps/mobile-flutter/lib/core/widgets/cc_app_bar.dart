import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Top app bar in the role colour, with optional subtitle and back button.
///
/// The bar sits inside the platform safe area so the trailing contact action
/// is never hidden behind a notch or the status bar.
class CcAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CcAppBar({
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 84);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      leadingWidth: showBack ? TapTarget.icon + Space.sm : 0,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: Space.sm),
              child: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                constraints: const BoxConstraints(
                  minWidth: TapTarget.icon,
                  minHeight: TapTarget.icon,
                ),
              ),
            )
          : null,
      titleSpacing: showBack ? 0 : Space.md,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(color: onPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(color: onPrimary),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        for (final action in actions)
          Padding(
            padding: const EdgeInsets.only(right: Space.sm),
            child: action,
          ),
      ],
    );
  }
}
