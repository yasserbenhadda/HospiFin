import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }
  
  static const String loginEndpoint = '/auth/login';
  static const String dashboardSummaryEndpoint = '/dashboard/summary';
  static const String chatEndpoint = '/custom-ai/ask';
  
  // New endpoints
  static const String patientsEndpoint = '/patients';
  static const String medicalActsEndpoint = '/medical-acts'; // Assuming standard REST naming
  static const String medicationsEndpoint = '/medications';
  static const String consumablesEndpoint = '/consumables';
  static const String personnelEndpoint = '/personnel'; // Or /staff
}
