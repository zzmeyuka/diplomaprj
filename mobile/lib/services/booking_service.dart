import 'api_client.dart';

class BookingService {
  BookingService(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> create({
    required String flightOfferId,
    required int passengersCount,
    List<Map<String, dynamic>>? passengers,
    String paymentStatus = 'paid',
  }) async {
    return await _client.post('/bookings', {
      'flightOfferId': flightOfferId,
      'passengersCount': passengersCount,
      if (passengers != null) 'passengers': passengers,
      'paymentStatus': paymentStatus,
    }) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> myBookings() async {
    final data = await _client.get('/bookings/my');
    return List<Map<String, dynamic>>.from(data as List);
  }
}
