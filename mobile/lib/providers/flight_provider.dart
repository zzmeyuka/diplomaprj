import 'package:flutter/foundation.dart';
import '../models/flight_offer.dart';
import '../services/flight_api_service.dart';

enum SortOption { cheapest, earliest, shortest }

class FlightSearchParams {
  String from = 'Almaty';
  String to = 'Astana';
  DateTime date = DateTime(2026, 6, 20);
  DateTime returnDate = DateTime(2026, 6, 27);
  bool roundTrip = false;
  String cabinClass = 'economy';
  int passengers = 1;
}

class FlightFilters {
  double minPrice = 0;
  double maxPrice = 500000;
  Set<String> cabinClasses = {'economy', 'comfort', 'business'};
  bool? baggageOnly;
  bool? refundableOnly;
  bool? directOnly;
  Set<String> aggregators = {
    'Kaspi Travel',
    'Freedom Travel',
    'Tickets.kz',
    'Trip',
  };
}

class FlightProvider extends ChangeNotifier {
  FlightProvider(this._api);
  final FlightApiService _api;

  final params = FlightSearchParams();
  final filters = FlightFilters();
  SortOption sort = SortOption.cheapest;

  List<FlightOffer> allOffers = [];
  List<FlightOffer> cheapestOffers = [];
  List<String> cities = [];
  bool loading = false;
  String? error;
  FlightOffer? selected;

  List<FlightOffer> get visibleOffers {
    var list = List<FlightOffer>.from(allOffers);
    list = list.where((o) {
      if (o.finalPrice < filters.minPrice || o.finalPrice > filters.maxPrice) return false;
      if (!filters.cabinClasses.contains(o.cabinClass)) return false;
      if (filters.baggageOnly == true && !o.baggageIncluded) return false;
      if (filters.refundableOnly == true && !o.refundable) return false;
      if (filters.directOnly == true && o.transferType != 'direct') return false;
      if (o.aggregatorName != null && !filters.aggregators.contains(o.aggregatorName)) {
        return false;
      }
      return true;
    }).toList();

    switch (sort) {
      case SortOption.cheapest:
        list.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
      case SortOption.earliest:
        list.sort((a, b) => a.departureAt.compareTo(b.departureAt));
      case SortOption.shortest:
        list.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
    }
    return list;
  }

  String get dateStr =>
      '${params.date.year}-${params.date.month.toString().padLeft(2, '0')}-${params.date.day.toString().padLeft(2, '0')}';

  Future<void> loadCities() async {
    try {
      final data = await _api.getCities();
      cities = data.map((c) => c['nameEn'] as String).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> search() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      allOffers = await _api.search(
        from: params.from,
        to: params.to,
        date: dateStr,
        cabinClass: params.cabinClass,
        passengers: params.passengers,
      );
      cheapestOffers = await _api.cheapest(
        from: params.from,
        to: params.to,
        date: dateStr,
        cabinClass: params.cabinClass,
        passengers: params.passengers,
      );
    } catch (e) {
      error = e.toString();
      allOffers = [];
      cheapestOffers = [];
    }
    loading = false;
    notifyListeners();
  }

  bool isCheapest(FlightOffer o) {
    return cheapestOffers.any((c) => c.id == o.id);
  }

  void select(FlightOffer o) {
    selected = o;
    notifyListeners();
  }

  void setPassengers(int n) {
    params.passengers = n.clamp(1, 9);
    notifyListeners();
  }

  void setCabin(String c) {
    params.cabinClass = c;
    notifyListeners();
  }

  void setRoundTrip(bool value) {
    params.roundTrip = value;
    notifyListeners();
  }

  void setFromCity(String v) {
    params.from = v;
    notifyListeners();
  }

  void setToCity(String v) {
    params.to = v;
    notifyListeners();
  }

  void setDate(DateTime d) {
    params.date = d;
    notifyListeners();
  }

  void setReturnDate(DateTime d) {
    params.returnDate = d;
    notifyListeners();
  }

  void setSortOption(SortOption s) {
    sort = s;
    notifyListeners();
  }

  void applyFilters() => notifyListeners();

  void resetFilters() {
    filters
      ..minPrice = 0
      ..maxPrice = 500000
      ..baggageOnly = null
      ..refundableOnly = null
      ..directOnly = null;
    notifyListeners();
  }
}
