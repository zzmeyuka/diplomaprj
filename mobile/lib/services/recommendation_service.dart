import '../models/flight_offer.dart';
import 'api_client.dart';

class RecommendationService {
  RecommendationService(this._client);
  final ApiClient _client;

  Future<List<FlightOffer>> get({int passengers = 1, String cabinClass = 'economy'}) async {
    final data = await _client.get('/recommendations', query: {
      'passengers': passengers.toString(),
      'cabinClass': cabinClass,
    });
    final list = data['recommendations'] as List;
    return list.map((e) => FlightOffer.fromJson(e as Map<String, dynamic>)).toList();
  }
}
