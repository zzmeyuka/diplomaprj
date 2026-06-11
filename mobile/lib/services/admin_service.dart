import 'api_client.dart';

class AdminService {
  AdminService(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> stats() async =>
      await _client.get('/admin/stats') as Map<String, dynamic>;

  Future<List<dynamic>> users() async =>
      await _client.get('/admin/users') as List<dynamic>;

  Future<List<dynamic>> flights() async =>
      await _client.get('/admin/flights') as List<dynamic>;

  Future<List<dynamic>> bookings() async =>
      await _client.get('/admin/bookings') as List<dynamic>;

  Future<List<dynamic>> searchHistory() async =>
      await _client.get('/admin/search-history') as List<dynamic>;

  Future<List<dynamic>> chatMessages() async =>
      await _client.get('/admin/chat-messages') as List<dynamic>;

  Future<List<dynamic>> logs() async =>
      await _client.get('/admin/logs') as List<dynamic>;
}
