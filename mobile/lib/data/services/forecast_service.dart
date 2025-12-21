import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';

class ForecastService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getForecast(int days) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/forecasts',
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Server returned ${response.statusCode}');
    } catch (e) {
      print('Error fetching forecast: $e');
      throw Exception('Failed to load forecast');
    }
  }
}
