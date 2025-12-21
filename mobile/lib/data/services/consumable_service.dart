import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class ConsumableService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getConsumables() async {
    try {
      final response = await _apiService.dio.get(ApiConstants.consumablesEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Consumable Service Error: $e');
      return [
        {'id': 'C001', 'name': 'Seringue', 'quantity': 1000, 'patient': 'Jean Martin'},
        {'id': 'C002', 'name': 'Pansement', 'quantity': 500, 'patient': 'Marie Dubois'},
      ];
    }
  }
}
