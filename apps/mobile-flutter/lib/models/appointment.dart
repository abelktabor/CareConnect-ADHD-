import 'package:flutter/foundation.dart';

import '../core/utils/date_formatting.dart';

/// An appointment, with "who is taking me" answered on the card itself so the
/// care recipient never has to make a phone call to find out.
@immutable
class Appointment {
  const Appointment({
    required this.id,
    required this.patientId,
    required this.title,
    required this.startsAt,
    required this.locationName,
    this.companionName,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'] as String,
    patientId: json['patientId'] as String,
    title: json['title'] as String,
    startsAt: DateTime.parse(json['startsAt'] as String),
    locationName: json['locationName'] as String,
    companionName: json['companionName'] as String?,
    notes: json['notes'] as String?,
  );

  final String id;
  final String patientId;

  /// Plain-language title: "Dr. Alvarez — Cardiology follow-up".
  final String title;
  final DateTime startsAt;
  final String locationName;

  /// Who is accompanying the care recipient. Null means they are going alone.
  final String? companionName;
  final String? notes;

  /// "Renee is taking me" or "Driving myself".
  String get companionLabel {
    final name = companionName?.trim();
    return name == null || name.isEmpty
        ? 'Driving myself'
        : '$name is taking me';
  }

  /// "Tuesday, August 25 · 2:30 PM · Regional Medical · Renee is taking me"
  String get summaryLine =>
      '${DateFormatting.dateAndTime(startsAt)} · $locationName · $companionLabel';

  Appointment copyWith({
    String? id,
    String? patientId,
    String? title,
    DateTime? startsAt,
    String? locationName,
    String? companionName,
    bool clearCompanion = false,
    String? notes,
    bool clearNotes = false,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      title: title ?? this.title,
      startsAt: startsAt ?? this.startsAt,
      locationName: locationName ?? this.locationName,
      companionName: clearCompanion
          ? null
          : (companionName ?? this.companionName),
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'title': title,
    'startsAt': startsAt.toIso8601String(),
    'locationName': locationName,
    'companionName': companionName,
    'notes': notes,
  };

  @override
  bool operator ==(Object other) =>
      other is Appointment &&
      other.id == id &&
      other.patientId == patientId &&
      other.title == title &&
      other.startsAt == startsAt &&
      other.locationName == locationName &&
      other.companionName == companionName &&
      other.notes == notes;

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    title,
    startsAt,
    locationName,
    companionName,
    notes,
  );

  @override
  String toString() => 'Appointment($title @ $startsAt)';
}
