import '../models/flight_offer.dart';
import 'api_client.dart';

class FlightApiService {
  FlightApiService(this._client);
  final ApiClient _client;

  Future<List<Map<String, dynamic>>> getCities() async {
    final data = await _client.get('/cities');
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<List<FlightOffer>> search({
    required String from,
    required String to,
    required String date,
    required String cabinClass,
    required int passengers,
  }) async {
    final data = await _client.get('/flights/search', query: {
      'from': from,
      'to': to,
      'date': date,
      'cabinClass': cabinClass,
      'passengers': passengers.toString(),
    });
    final offers = data['offers'] as List;
    return offers.map((e) => FlightOffer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FlightOffer>> cheapest({
    required String from,
    required String to,
    required String date,
    required String cabinClass,
    required int passengers,
  }) async {
    final data = await _client.get('/flights/cheapest', query: {
      'from': from,
      'to': to,
      'date': date,
      'cabinClass': cabinClass,
      'passengers': passengers.toString(),
    });
    final offers = data['offers'] as List;
    return offers.map((e) => FlightOffer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FlightOffer> getById(String id, int passengers) async {
    final data = await _client.get('/flights/$id', query: {
      'passengers': passengers.toString(),
    });
    return FlightOffer.fromJson(data as Map<String, dynamic>);
  }
}
