import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/stay_model.dart';

class StayService {
  final Dio _dio = Dio();

  Future<List<HospitalStay>> getStays() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/stays');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
            return HospitalStay.fromJson(json);
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load stays: $e');
    }
  }

  Future<void> createStay(HospitalStay stay) async {
    try {
      final data = stay.toJson();
      // Remove ID for creation
      data.remove('id');
      await _dio.post('${ApiConstants.baseUrl}/stays', data: data);
    } catch (e) {
      throw Exception('Failed to create stay: $e');
    }
  }

  Future<void> updateStay(HospitalStay stay) async {
    try {
      await _dio.put('${ApiConstants.baseUrl}/stays/${stay.id}', data: stay.toJson());
    } catch (e) {
      throw Exception('Failed to update stay: $e');
    }
  }

  Future<void> deleteStay(int id) async {
    try {
      await _dio.delete('${ApiConstants.baseUrl}/stays/$id');
    } catch (e) {
      throw Exception('Failed to delete stay: $e');
    }
  }
}
