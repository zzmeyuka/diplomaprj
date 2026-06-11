import 'package:flutter/foundation.dart';

class AppNotification {
  AppNotification({
    required this.id,
    required this.message,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String message;
  final DateTime createdAt;
  bool read;
}

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _items = [];

  List<AppNotification> get items => List.unmodifiable(_items);
  List<AppNotification> get unread => _items.where((n) => !n.read).toList();

  void addBookingSuccess({String? route}) {
    final msg = route != null
        ? 'Билет успешно забронирован: $route'
        : 'Билет успешно забронирован';
    _items.insert(
      0,
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: msg,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _items) {
      n.read = true;
    }
    notifyListeners();
  }

  void dismiss(String id) {
    _items.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
