import '../models/flight_offer.dart';
import 'api_client.dart';

class FavoriteService {
  FavoriteService(this._client);
  final ApiClient _client;

  Future<void> add(String flightOfferId, {int passengers = 1}) async {
    await _client.post('/favorites', {
      'flightOfferId': flightOfferId,
      'passengers': passengers,
    });
  }

  Future<List<Map<String, dynamic>>> list({int passengers = 1}) async {
    final data = await _client.get('/favorites', query: {
      'passengers': passengers.toString(),
    });
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<void> remove(String flightOfferId) async {
    await _client.delete('/favorites/$flightOfferId');
  }

  FlightOffer parseFlight(Map<String, dynamic> item) {
    return FlightOffer.fromJson(item['flight'] as Map<String, dynamic>);
  }
}
