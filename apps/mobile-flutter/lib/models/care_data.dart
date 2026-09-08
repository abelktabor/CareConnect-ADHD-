import 'package:flutter/foundation.dart';

import 'activity_entry.dart';
import 'appointment.dart';
import 'dose_event.dart';
import 'medication.dart';
import 'person.dart';

/// Everything the app knows about one care relationship, persisted as a
/// single JSON document. One aggregate keeps undo, autosave and reset simple:
/// every mutation produces a new [CareData] and writes it in one go.
@immutable
class CareData {
  const CareData({
    required this.patient,
    required this.caregiver,
    required this.medications,
    required this.doseEvents,
    required this.appointments,
    required this.activity,
    required this.seededOn,
  });

  factory CareData.fromJson(Map<String, dynamic> json) => CareData(
    patient: Patient.fromJson(json['patient'] as Map<String, dynamic>),
    caregiver: Caregiver.fromJson(json['caregiver'] as Map<String, dynamic>),
    medications: (json['medications'] as List<dynamic>)
        .map((m) => Medication.fromJson(m as Map<String, dynamic>))
        .toList(),
    doseEvents: (json['doseEvents'] as List<dynamic>)
        .map((d) => DoseEvent.fromJson(d as Map<String, dynamic>))
        .toList(),
    appointments: (json['appointments'] as List<dynamic>)
        .map((a) => Appointment.fromJson(a as Map<String, dynamic>))
        .toList(),
    activity: (json['activity'] as List<dynamic>)
        .map((a) => ActivityEntry.fromJson(a as Map<String, dynamic>))
        .toList(),
    seededOn: DateTime.parse(json['seededOn'] as String),
  );

  final Patient patient;
  final Caregiver caregiver;
  final List<Medication> medications;
  final List<DoseEvent> doseEvents;
  final List<Appointment> appointments;
  final List<ActivityEntry> activity;

  /// The calendar day the fixtures were generated for.
  final DateTime seededOn;

  List<Medication> get activeMedications =>
      medications.where((m) => m.active).toList();

  Medication? medicationById(String id) {
    for (final m in medications) {
      if (m.id == id) return m;
    }
    return null;
  }

  DoseEvent? doseById(String id) {
    for (final d in doseEvents) {
      if (d.id == id) return d;
    }
    return null;
  }

  Appointment? appointmentById(String id) {
    for (final a in appointments) {
      if (a.id == id) return a;
    }
    return null;
  }

  CareData copyWith({
    Patient? patient,
    Caregiver? caregiver,
    List<Medication>? medications,
    List<DoseEvent>? doseEvents,
    List<Appointment>? appointments,
    List<ActivityEntry>? activity,
    DateTime? seededOn,
  }) {
    return CareData(
      patient: patient ?? this.patient,
      caregiver: caregiver ?? this.caregiver,
      medications: medications ?? this.medications,
      doseEvents: doseEvents ?? this.doseEvents,
      appointments: appointments ?? this.appointments,
      activity: activity ?? this.activity,
      seededOn: seededOn ?? this.seededOn,
    );
  }

  Map<String, dynamic> toJson() => {
    'patient': patient.toJson(),
    'caregiver': caregiver.toJson(),
    'medications': medications.map((m) => m.toJson()).toList(),
    'doseEvents': doseEvents.map((d) => d.toJson()).toList(),
    'appointments': appointments.map((a) => a.toJson()).toList(),
    'activity': activity.map((a) => a.toJson()).toList(),
    'seededOn': seededOn.toIso8601String(),
  };
}
