import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/medical_act_model.dart';

class MedicalActService {
  final Dio _dio = Dio();

  Future<List<MedicalAct>> getMedicalActs() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/medical-acts');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
             return MedicalAct.fromJson(json);
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load medical acts: $e');
    }
  }

  Future<void> createMedicalAct(MedicalAct act) async {
    try {
      final data = act.toJson();
      data.remove('id');
      await _dio.post('${ApiConstants.baseUrl}/medical-acts', data: data);
    } catch (e) {
      throw Exception('Failed to create medical act: $e');
    }
  }

  Future<void> updateMedicalAct(MedicalAct act) async {
    try {
      await _dio.put('${ApiConstants.baseUrl}/medical-acts/${act.id}', data: act.toJson());
    } catch (e) {
      throw Exception('Failed to update medical act: $e');
    }
  }

  Future<void> deleteMedicalAct(int id) async {
    try {
      await _dio.delete('${ApiConstants.baseUrl}/medical-acts/$id');
    } catch (e) {
      throw Exception('Failed to delete medical act: $e');
    }
  }
}
