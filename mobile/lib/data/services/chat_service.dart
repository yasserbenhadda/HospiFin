import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();

  Future<String> sendMessage(String message) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.chatEndpoint,
        data: {'question': message},
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['answer'] ?? 'No response';
      }
      return 'Error: Invalid response from server';
    } catch (e) {
      print('Chat Error: $e');
      return 'Désolé, je ne peux pas répondre pour le moment. ($e)';
    }
  }
}
