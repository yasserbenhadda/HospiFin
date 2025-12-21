import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await _apiService.dio.get(ApiConstants.dashboardSummaryEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      throw Exception('Failed to load dashboard summary');
    } catch (e) {
      print('Dashboard Error: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }
}
