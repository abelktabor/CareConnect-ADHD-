import 'package:flutter/foundation.dart';

/// The care recipient. Fields mirror `packages/mock-data` on the web side.
@immutable
class Patient {
  const Patient({
    required this.id,
    required this.displayName,
    required this.firstName,
    required this.email,
    required this.primaryCaregiverId,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    firstName: json['firstName'] as String,
    email: json['email'] as String,
    primaryCaregiverId: json['primaryCaregiverId'] as String?,
  );

  final String id;

  /// What the orientation bar and caregiver dashboard call the person.
  final String displayName;

  /// Used in plain-language activity summaries: "Muhammad logged…".
  final String firstName;

  /// Fictional — always on the reserved `example.test` domain.
  final String email;

  /// Backs the persistent "Call my caregiver" action (SC 3.2.6).
  final String? primaryCaregiverId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'firstName': firstName,
    'email': email,
    'primaryCaregiverId': primaryCaregiverId,
  };

  @override
  bool operator ==(Object other) =>
      other is Patient &&
      other.id == id &&
      other.displayName == displayName &&
      other.firstName == firstName &&
      other.email == email &&
      other.primaryCaregiverId == primaryCaregiverId;

  @override
  int get hashCode =>
      Object.hash(id, displayName, firstName, email, primaryCaregiverId);
}

/// The support person. `relationshipToPatient` is shown to the care recipient
/// in plain language ("your caregiver"), never as a role label.
@immutable
class Caregiver {
  const Caregiver({
    required this.id,
    required this.displayName,
    required this.firstName,
    required this.relationshipToPatient,
    required this.phone,
    required this.patientIds,
  });

  factory Caregiver.fromJson(Map<String, dynamic> json) => Caregiver(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    firstName: json['firstName'] as String,
    relationshipToPatient: json['relationshipToPatient'] as String,
    phone: json['phone'] as String,
    patientIds: (json['patientIds'] as List<dynamic>).cast<String>(),
  );

  final String id;
  final String displayName;
  final String firstName;
  final String relationshipToPatient;

  /// Fictional — always in the 555-01xx range reserved for fiction.
  final String phone;
  final List<String> patientIds;

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'firstName': firstName,
    'relationshipToPatient': relationshipToPatient,
    'phone': phone,
    'patientIds': patientIds,
  };

  @override
  bool operator ==(Object other) =>
      other is Caregiver &&
      other.id == id &&
      other.displayName == displayName &&
      other.firstName == firstName &&
      other.relationshipToPatient == relationshipToPatient &&
      other.phone == phone &&
      listEquals(other.patientIds, patientIds);

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    firstName,
    relationshipToPatient,
    phone,
    Object.hashAll(patientIds),
  );
}
