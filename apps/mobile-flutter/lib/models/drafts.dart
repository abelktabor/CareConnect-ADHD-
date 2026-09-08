import 'package:flutter/foundation.dart';

/// In-progress state of the Add / Edit Medication form.
///
/// Autosaved on every keystroke and restored when the form reopens, so an
/// interruption mid-form never costs lost progress ("never re-entered",
/// WCAG 2.2 SC 3.3.7 Redundant Entry).
@immutable
class MedicationDraft {
  const MedicationDraft({
    this.editingId,
    this.step = 1,
    this.name = '',
    this.dosage = '',
    this.scheduleTimes = const [],
    this.instructions = '',
  });

  factory MedicationDraft.fromJson(Map<String, dynamic> json) =>
      MedicationDraft(
        editingId: json['editingId'] as String?,
        step: json['step'] as int? ?? 1,
        name: json['name'] as String? ?? '',
        dosage: json['dosage'] as String? ?? '',
        scheduleTimes: (json['scheduleTimes'] as List<dynamic>? ?? const [])
            .cast<String>(),
        instructions: json['instructions'] as String? ?? '',
      );

  static const int totalSteps = 3;

  /// Null when adding; the medication id when editing.
  final String? editingId;
  final int step;
  final String name;
  final String dosage;
  final List<String> scheduleTimes;
  final String instructions;

  bool get isEditing => editingId != null;

  bool get isEmpty =>
      editingId == null &&
      step == 1 &&
      name.isEmpty &&
      dosage.isEmpty &&
      scheduleTimes.isEmpty &&
      instructions.isEmpty;

  MedicationDraft copyWith({
    String? editingId,
    bool clearEditingId = false,
    int? step,
    String? name,
    String? dosage,
    List<String>? scheduleTimes,
    String? instructions,
  }) {
    return MedicationDraft(
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
      step: step ?? this.step,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      instructions: instructions ?? this.instructions,
    );
  }

  Map<String, dynamic> toJson() => {
    'editingId': editingId,
    'step': step,
    'name': name,
    'dosage': dosage,
    'scheduleTimes': scheduleTimes,
    'instructions': instructions,
  };

  @override
  bool operator ==(Object other) =>
      other is MedicationDraft &&
      other.editingId == editingId &&
      other.step == step &&
      other.name == name &&
      other.dosage == dosage &&
      listEquals(other.scheduleTimes, scheduleTimes) &&
      other.instructions == instructions;

  @override
  int get hashCode => Object.hash(
    editingId,
    step,
    name,
    dosage,
    Object.hashAll(scheduleTimes),
    instructions,
  );
}

/// In-progress state of the Add / Edit Appointment form (two steps).
@immutable
class AppointmentDraft {
  const AppointmentDraft({
    this.editingId,
    this.step = 1,
    this.title = '',
    this.locationName = '',
    this.startsAt,
    this.companionName = '',
  });

  factory AppointmentDraft.fromJson(Map<String, dynamic> json) =>
      AppointmentDraft(
        editingId: json['editingId'] as String?,
        step: json['step'] as int? ?? 1,
        title: json['title'] as String? ?? '',
        locationName: json['locationName'] as String? ?? '',
        startsAt: json['startsAt'] == null
            ? null
            : DateTime.parse(json['startsAt'] as String),
        companionName: json['companionName'] as String? ?? '',
      );

  static const int totalSteps = 2;

  final String? editingId;
  final int step;
  final String title;
  final String locationName;
  final DateTime? startsAt;
  final String companionName;

  bool get isEditing => editingId != null;

  bool get isEmpty =>
      editingId == null &&
      step == 1 &&
      title.isEmpty &&
      locationName.isEmpty &&
      startsAt == null &&
      companionName.isEmpty;

  AppointmentDraft copyWith({
    String? editingId,
    bool clearEditingId = false,
    int? step,
    String? title,
    String? locationName,
    DateTime? startsAt,
    String? companionName,
  }) {
    return AppointmentDraft(
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
      step: step ?? this.step,
      title: title ?? this.title,
      locationName: locationName ?? this.locationName,
      startsAt: startsAt ?? this.startsAt,
      companionName: companionName ?? this.companionName,
    );
  }

  Map<String, dynamic> toJson() => {
    'editingId': editingId,
    'step': step,
    'title': title,
    'locationName': locationName,
    'startsAt': startsAt?.toIso8601String(),
    'companionName': companionName,
  };

  @override
  bool operator ==(Object other) =>
      other is AppointmentDraft &&
      other.editingId == editingId &&
      other.step == step &&
      other.title == title &&
      other.locationName == locationName &&
      other.startsAt == startsAt &&
      other.companionName == companionName;

  @override
  int get hashCode => Object.hash(
    editingId,
    step,
    title,
    locationName,
    startsAt,
    companionName,
  );
}
