import 'package:intl/intl.dart';
import '../services/service_mapper.dart';

class HospitalStay {
  final int id;
  final String patientName;
  final String service;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCost;
  final String status;

  HospitalStay({
    required this.id,
    required this.patientName,
    required this.service,
    required this.startDate,
    required this.endDate,
    required this.totalCost,
    required this.status,
  });

  factory HospitalStay.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] ?? {};
    final firstName = patient['firstName'] ?? '';
    final lastName = patient['lastName'] ?? '';
    final pathology = json['pathology'] ?? '';

    // Calculate status based on date
    final start = DateTime.parse(json['startDate']);
    final end = DateTime.parse(json['endDate']);
    final now = DateTime.now();
    
    String statusStr;
    if (now.isBefore(start)) {
      statusStr = 'Prévu';
    } else if (now.isAfter(end)) {
      statusStr = 'Terminé';
    } else {
      statusStr = 'En cours';
    }

    // Calculate cost (dailyRate * days)
    final dailyRate = double.tryParse(json['dailyRate'].toString()) ?? 0.0;
    final days = end.difference(start).inDays + 1;
    final total = dailyRate * days;

    return HospitalStay(
      id: json['id'],
      patientName: '$firstName $lastName'.trim(),
      service: ServiceMapper.getServiceFromText(pathology), // Use Mapper
      startDate: start,
      endDate: end,
      totalCost: total,
      status: statusStr,
    );
  }
}
