import 'package:flutter/foundation.dart';

/// Lifecycle of one scheduled dose.
///
/// `due` is the only state a dose can be in before the user acts. "Overdue"
/// is not a stored state — it is `due` whose scheduled time has passed, so
/// it is derived from the clock (see [DoseEvent.isOverdue]).
enum DoseStatus {
  due,
  taken,
  skipped,
  missed;

  /// The text half of the status chip. Colour is never the only carrier.
  String get label => switch (this) {
    DoseStatus.due => 'Due',
    DoseStatus.taken => 'Taken',
    DoseStatus.skipped => 'Skipped',
    DoseStatus.missed => 'Missed',
  };

  static DoseStatus fromStorage(String value) => DoseStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => DoseStatus.due,
  );
}

/// One row per scheduled dose per day.
@immutable
class DoseEvent {
  const DoseEvent({
    required this.id,
    required this.medicationId,
    required this.scheduledFor,
    this.status = DoseStatus.due,
    this.recordedAt,
    this.undoableUntil,
  });

  factory DoseEvent.fromJson(Map<String, dynamic> json) => DoseEvent(
    id: json['id'] as String,
    medicationId: json['medicationId'] as String,
    scheduledFor: DateTime.parse(json['scheduledFor'] as String),
    status: DoseStatus.fromStorage(json['status'] as String),
    recordedAt: json['recordedAt'] == null
        ? null
        : DateTime.parse(json['recordedAt'] as String),
    undoableUntil: json['undoableUntil'] == null
        ? null
        : DateTime.parse(json['undoableUntil'] as String),
  );

  /// Every state change offers a 10-second undo so a mis-tap never becomes
  /// something the care recipient has to ask a caregiver to fix.
  static const Duration undoWindow = Duration(seconds: 10);

  final String id;
  final String medicationId;
  final DateTime scheduledFor;
  final DoseStatus status;

  /// When the user acted. Null while the dose is still `due`.
  final DateTime? recordedAt;

  /// End of the undo window for the most recent change, if still open.
  final DateTime? undoableUntil;

  bool get isDue => status == DoseStatus.due;

  /// A due dose whose time has passed.
  bool isOverdue(DateTime now) => isDue && scheduledFor.isBefore(now);

  /// Whether the last change can still be reversed at [now].
  bool canUndo(DateTime now) =>
      undoableUntil != null && now.isBefore(undoableUntil!);

  DoseEvent copyWith({
    String? id,
    String? medicationId,
    DateTime? scheduledFor,
    DoseStatus? status,
    DateTime? recordedAt,
    bool clearRecordedAt = false,
    DateTime? undoableUntil,
    bool clearUndoableUntil = false,
  }) {
    return DoseEvent(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      status: status ?? this.status,
      recordedAt: clearRecordedAt ? null : (recordedAt ?? this.recordedAt),
      undoableUntil: clearUndoableUntil
          ? null
          : (undoableUntil ?? this.undoableUntil),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'scheduledFor': scheduledFor.toIso8601String(),
    'status': status.name,
    'recordedAt': recordedAt?.toIso8601String(),
    'undoableUntil': undoableUntil?.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is DoseEvent &&
      other.id == id &&
      other.medicationId == medicationId &&
      other.scheduledFor == scheduledFor &&
      other.status == status &&
      other.recordedAt == recordedAt &&
      other.undoableUntil == undoableUntil;

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    scheduledFor,
    status,
    recordedAt,
    undoableUntil,
  );

  @override
  String toString() =>
      'DoseEvent($id, $medicationId, $status, scheduledFor: $scheduledFor)';
}
