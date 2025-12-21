import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class MedicationService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getMedications() async {
    try {
      final response = await _apiService.dio.get(ApiConstants.medicationsEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Medication Service Error: $e');
      return [
        {'id': 'M001', 'name': 'Paracétamol', 'stock': 500, 'unit': 'Boîte'},
        {'id': 'M002', 'name': 'Ibuprofène', 'stock': 200, 'unit': 'Boîte'},
      ];
    }
  }
}
