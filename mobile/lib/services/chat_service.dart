import 'api_client.dart';

class ChatService {
  ChatService(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> ask({
    required String message,
    String? sessionId,
    String? from,
    String? to,
    String? date,
    String? cabinClass,
    int? passengers,
  }) async {
    return await _client.post('/chat/ask', {
      'message': message,
      if (sessionId != null) 'sessionId': sessionId,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (date != null) 'date': date,
      if (cabinClass != null) 'cabinClass': cabinClass,
      if (passengers != null) 'passengers': passengers,
    }) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> history(String sessionId) async {
    return await _client.get('/chat/history/$sessionId') as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listSessions() async {
    try {
      final data = await _client.get('/chat/sessions');
      if (data is! List) return [];
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
