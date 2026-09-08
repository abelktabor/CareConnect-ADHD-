import 'package:flutter/foundation.dart';

/// What kind of event a timeline row records. Drives the Activity Timeline
/// filter ("All medications & appointments").
enum ActivityKind {
  dose,
  appointment,
  reminder,
  note,
  task;

  static ActivityKind fromStorage(String value) =>
      ActivityKind.values.firstWhere(
        (kind) => kind.name == value,
        orElse: () => ActivityKind.note,
      );
}

/// Append-only feed behind the caregiver's Activity Timeline.
///
/// `summary` is pre-written plain language ("Muhammad logged Metformin taken
/// at 8:04 AM") so the timeline needs no interpretation.
@immutable
class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.at,
    required this.summary,
    required this.kind,
  });

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
    id: json['id'] as String,
    at: DateTime.parse(json['at'] as String),
    summary: json['summary'] as String,
    kind: ActivityKind.fromStorage(json['kind'] as String),
  );

  final String id;
  final DateTime at;
  final String summary;
  final ActivityKind kind;

  Map<String, dynamic> toJson() => {
    'id': id,
    'at': at.toIso8601String(),
    'summary': summary,
    'kind': kind.name,
  };

  @override
  bool operator ==(Object other) =>
      other is ActivityEntry &&
      other.id == id &&
      other.at == at &&
      other.summary == summary &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(id, at, summary, kind);
}
