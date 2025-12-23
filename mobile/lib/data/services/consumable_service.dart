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
      throw e;
    }
  }

  Future<void> deleteConsumable(int id) async {
    try {
      await _apiService.dio.delete('${ApiConstants.consumablesEndpoint}/$id');
    } catch (e) {
      print('Error deleting consumable: $e');
      rethrow;
    }
  }

  Future<void> createConsumable(Map<String, dynamic> data) async {
    try {
      await _apiService.dio.post(ApiConstants.consumablesEndpoint, data: data);
    } catch (e) {
      print('Error creating consumable: $e');
      rethrow;
    }
  }

  Future<void> updateConsumable(int id, Map<String, dynamic> data) async {
    try {
      await _apiService.dio.put('${ApiConstants.consumablesEndpoint}/$id', data: data);
    } catch (e) {
      print('Error updating consumable: $e');
      rethrow;
    }
  }
}
