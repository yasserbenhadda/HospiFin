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
      throw e; // Throw error to be handled by UI
    }
  }

  Future<void> deleteMedication(int id) async {
    try {
      await _apiService.dio.delete('${ApiConstants.medicationsEndpoint}/$id');
    } catch (e) {
      print('Error deleting medication: $e');
      rethrow;
    }
  }

  Future<void> createMedication(Map<String, dynamic> data) async {
    try {
      await _apiService.dio.post(ApiConstants.medicationsEndpoint, data: data);
    } catch (e) {
      print('Error creating medication: $e');
      rethrow;
    }
  }

  Future<void> updateMedication(int id, Map<String, dynamic> data) async {
    try {
      final endpoint = '${ApiConstants.medicationsEndpoint}/$id';
       print('Updating medication at: $endpoint with data: $data');
      await _apiService.dio.put(endpoint, data: data);
    } catch (e) {
      print('Error updating medication: $e');
      rethrow;
    }
  }
}
