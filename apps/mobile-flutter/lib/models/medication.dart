import 'package:flutter/foundation.dart';

/// A medication as the care recipient recognises it.
///
/// `dosage` is plain language ("500 mg", "1000 IU"), never a clinical sig
/// like "1 tab PO QD". `scheduleTimes` are 24-hour local times ("08:00")
/// and one [DoseEvent] is generated per time per day.
@immutable
class Medication {
  const Medication({
    required this.id,
    required this.patientId,
    required this.name,
    required this.dosage,
    required this.scheduleTimes,
    this.instructions,
    this.active = true,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'] as String,
    patientId: json['patientId'] as String,
    name: json['name'] as String,
    dosage: json['dosage'] as String,
    scheduleTimes: (json['scheduleTimes'] as List<dynamic>).cast<String>(),
    instructions: json['instructions'] as String?,
    active: json['active'] as bool? ?? true,
  );

  final String id;
  final String patientId;
  final String name;
  final String dosage;
  final List<String> scheduleTimes;
  final String? instructions;

  /// Soft delete keeps adherence history intact for the caregiver timeline.
  final bool active;

  /// "Metformin, 500 mg" — the card title everywhere in the app.
  String get displayName => dosage.isEmpty ? name : '$name, $dosage';

  Medication copyWith({
    String? id,
    String? patientId,
    String? name,
    String? dosage,
    List<String>? scheduleTimes,
    String? instructions,
    bool clearInstructions = false,
    bool? active,
  }) {
    return Medication(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      instructions: clearInstructions
          ? null
          : (instructions ?? this.instructions),
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'name': name,
    'dosage': dosage,
    'scheduleTimes': scheduleTimes,
    'instructions': instructions,
    'active': active,
  };

  @override
  bool operator ==(Object other) =>
      other is Medication &&
      other.id == id &&
      other.patientId == patientId &&
      other.name == name &&
      other.dosage == dosage &&
      listEquals(other.scheduleTimes, scheduleTimes) &&
      other.instructions == instructions &&
      other.active == active;

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    name,
    dosage,
    Object.hashAll(scheduleTimes),
    instructions,
    active,
  );

  @override
  String toString() => 'Medication($displayName, times: $scheduleTimes)';
}
