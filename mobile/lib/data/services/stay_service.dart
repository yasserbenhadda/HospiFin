import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/stay_model.dart';

class StayService {
  final Dio _dio = Dio();

  Future<List<HospitalStay>> getStays() async {
    try {
      print('StayService: Fetching from ${ApiConstants.baseUrl}/stays');
      final response = await _dio.get('${ApiConstants.baseUrl}/stays');
      
      print('StayService: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('StayService: Received ${data.length} stays');
        return data.map((json) {
          try {
            return HospitalStay.fromJson(json);
          } catch (e) {
            print('StayService: Error parsing stay: $e, JSON: $json');
            rethrow;
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching stays: $e');
      throw Exception('Failed to load stays: $e');
    }
  }
}
