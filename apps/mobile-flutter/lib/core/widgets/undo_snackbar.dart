import 'package:flutter/material.dart';

import '../../models/dose_event.dart';

/// Shows the reversible confirmation used for every routine action.
///
/// Material's snackbar is the closest existing spec to "confirmation plus a
/// reversible action": bottom-anchored, auto-dismissing after the 10-second
/// undo window, and announced through a live region. Undo is additive —
/// nothing is forfeited when the window closes (SC 2.2.1 Timing Adjustable).
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  return messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: DoseEvent.undoWindow,
      action: SnackBarAction(label: 'Undo', onPressed: onUndo),
    ),
  );
}

/// A plain confirmation with no action.
void showConfirmationSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(content: Text(message)));
}
