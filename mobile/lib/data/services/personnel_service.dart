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
      rethrow;
    }
  }

  Future<void> createPersonnel(Map<String, dynamic> data) async {
    try {
      await _apiService.dio.post(ApiConstants.personnelEndpoint, data: data);
    } catch (e) {
      print('Error creating personnel: $e');
      rethrow;
    }
  }

  Future<void> updatePersonnel(int id, Map<String, dynamic> data) async {
    try {
      await _apiService.dio.put('${ApiConstants.personnelEndpoint}/$id', data: data);
    } catch (e) {
      print('Error updating personnel: $e');
      rethrow;
    }
  }

  Future<void> deletePersonnel(int id) async {
    try {
      await _apiService.dio.delete('${ApiConstants.personnelEndpoint}/$id');
    } catch (e) {
      print('Error deleting personnel: $e');
      rethrow;
    }
  }
}
