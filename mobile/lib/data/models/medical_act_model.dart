import 'package:intl/intl.dart';
import '../services/service_mapper.dart';

class MedicalAct {
  final int id;
  final String type;
  final String service;
  final DateTime date;
  final String patientName;
  final String practitioner;
  final double cost;
  final int? _patientId;

  MedicalAct({
    required this.id,
    required this.type,
    required this.service,
    required this.date,
    required this.patientName,
    required this.practitioner,
    required this.cost,
    int? patientId,
  }) : _patientId = patientId;

  int? get patientId => _patientId;

  factory MedicalAct.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] ?? {};
    final firstName = patient['firstName'] ?? '';
    final lastName = patient['lastName'] ?? '';
    final typeStr = json['type'] ?? '';

    return MedicalAct(
      id: json['id'] ?? 0,
      type: typeStr,
      service: ServiceMapper.getServiceFromText(typeStr),
      date: DateTime.parse(json['date']),
      patientName: '$firstName $lastName'.trim(),
      practitioner: json['practitioner'] ?? 'Inconnu',
      cost: double.tryParse(json['cost'].toString()) ?? 0.0,
      patientId: patient['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (_patientId != null) 'patient': {'id': _patientId},
      'type': type,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'practitioner': practitioner,
      'cost': cost,
    };
  }
}
