class Patient {
  final int id;
  final String firstName;
  final String lastName;
  final String ssn;
  final DateTime? birthDate;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.ssn,
    this.birthDate,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      ssn: json['ssn'] ?? '',
      birthDate: json['birthDate'] != null ? DateTime.tryParse(json['birthDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'ssn': ssn,
      'birthDate': birthDate?.toIso8601String(),
    };
  }
}
