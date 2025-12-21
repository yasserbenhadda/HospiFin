import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class PatientService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getPatients() async {
    try {
      final response = await _apiService.dio.get(ApiConstants.patientsEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Patient Service Error: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }

  Future<void> createPatient(Map<String, dynamic> patient) async {
    try {
      // Ensure ID is not sent for creation
      final data = Map<String, dynamic>.from(patient);
      data.remove('id');
      await _apiService.dio.post(ApiConstants.patientsEndpoint, data: data);
    } catch (e) {
      print('Error creating patient: $e');
      throw Exception('Erreur lors de la création du patient');
    }
  }

  Future<void> updatePatient(int id, Map<String, dynamic> patient) async {
    try {
      await _apiService.dio.put('${ApiConstants.patientsEndpoint}/$id', data: patient);
    } catch (e) {
      print('Error updating patient: $e');
      throw Exception('Erreur lors de la modification du patient');
    }
  }

  Future<void> deletePatient(int id) async {
    try {
      await _apiService.dio.delete('${ApiConstants.patientsEndpoint}/$id');
    } catch (e) {
      print('Error deleting patient: $e');
      throw Exception('Erreur lors de la suppression du patient');
    }
  }
}
