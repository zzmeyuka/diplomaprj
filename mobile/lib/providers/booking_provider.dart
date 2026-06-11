import 'package:flutter/foundation.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider(this._service);
  final BookingService _service;

  List<Map<String, dynamic>> bookings = [];
  bool loading = false;

  Future<Map<String, dynamic>?> create({
    required String flightOfferId,
    required int passengersCount,
  }) async {
    loading = true;
    notifyListeners();
    try {
      final result = await _service.create(
        flightOfferId: flightOfferId,
        passengersCount: passengersCount,
      );
      loading = false;
      notifyListeners();
      return result;
    } catch (e) {
      loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    bookings = await _service.myBookings();
    loading = false;
    notifyListeners();
  }
}
