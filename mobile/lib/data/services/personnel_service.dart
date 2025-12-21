import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class PersonnelService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getPersonnel() async {
    try {
      final response = await _apiService.dio.get(ApiConstants.personnelEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Personnel Service Error: $e');
      return [
        {'id': 'P001', 'name': 'Dr. Meredith Grey', 'role': 'Chirurgien', 'service': 'Chirurgie'},
        {'id': 'P002', 'name': 'Dr. Derek Shepherd', 'role': 'Neurochirurgien', 'service': 'Neuro'},
      ];
    }
  }
}
