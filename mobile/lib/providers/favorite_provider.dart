import 'package:flutter/foundation.dart';
import '../models/flight_offer.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider(this._service);
  final FavoriteService _service;

  List<FlightOffer> items = [];
  bool loading = false;
  String? error;

  Future<void> load(int passengers) async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.list(passengers: passengers);
      items = data.map(_service.parseFlight).toList();
      error = null;
    } catch (e) {
      error = e.toString();
      items = [];
    }
    loading = false;
    notifyListeners();
  }

  Future<void> add(String id, int passengers) async {
    await _service.add(id, passengers: passengers);
    await load(passengers);
  }

  Future<void> remove(String id, int passengers) async {
    await _service.remove(id);
    await load(passengers);
  }

  bool contains(String id) => items.any((f) => f.id == id);
}
