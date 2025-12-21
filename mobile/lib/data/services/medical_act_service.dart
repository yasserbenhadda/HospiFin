import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/medical_act_model.dart';

class MedicalActService {
  final Dio _dio = Dio();

  Future<List<MedicalAct>> getMedicalActs() async {
    try {
      print('MedicalActService: Fetching from ${ApiConstants.baseUrl}/medical-acts');
      final response = await _dio.get('${ApiConstants.baseUrl}/medical-acts');
      print('MedicalActService: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('MedicalActService: Received ${data.length} acts');
        return data.map((json) {
           try {
             return MedicalAct.fromJson(json);
           } catch (e) {
             print('MedicalActService: Error parsing act: $e, JSON: $json');
             rethrow;
           }
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching medical acts: $e');
      throw Exception('Failed to load medical acts: $e');
    }
  }
}
