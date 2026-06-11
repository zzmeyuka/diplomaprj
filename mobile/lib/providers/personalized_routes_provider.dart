import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class PersonalizedRouteItem {
  PersonalizedRouteItem({
    required this.originCity,
    required this.destinationCity,
    required this.interestScore,
    required this.searchCount,
    required this.favoriteCount,
    required this.bookingCount,
    this.minPrice,
    this.currency = 'KZT',
  });

  final String originCity;
  final String destinationCity;
  final int interestScore;
  final int searchCount;
  final int favoriteCount;
  final int bookingCount;
  final double? minPrice;
  final String currency;

  factory PersonalizedRouteItem.fromJson(Map<String, dynamic> json) {
    final mp = json['minPrice'];
    return PersonalizedRouteItem(
      originCity: json['originCity'] as String,
      destinationCity: json['destinationCity'] as String,
      interestScore: json['interestScore'] as int? ?? 0,
      searchCount: json['searchCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      bookingCount: json['bookingCount'] as int? ?? 0,
      minPrice: mp == null ? null : (mp as num).toDouble(),
      currency: json['currency'] as String? ?? 'KZT',
    );
  }
}

class PersonalizedRoutesProvider extends ChangeNotifier {
  PersonalizedRoutesProvider(this._client);
  final ApiClient _client;

  List<PersonalizedRouteItem> routes = [];
  bool loading = false;

  Future<void> refresh() async {
    if (!_client.hasToken) {
      routes = [];
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final data = await _client.get('/preferences/personalized-routes');
      if (data is Map) {
        final list = data['routes'];
        if (list is List) {
          routes = list
              .map((e) => PersonalizedRouteItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        } else {
          routes = [];
        }
      } else {
        routes = [];
      }
    } catch (_) {
      routes = [];
    }
    loading = false;
    notifyListeners();
  }

  void clear() {
    routes = [];
    notifyListeners();
  }
}
