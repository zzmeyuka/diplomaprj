import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';
import 'flight_provider.dart';

class ChatOfferAction {
  ChatOfferAction({required this.id, required this.label});
  final String id;
  final String label;
}

class ChatMessageItem {
  ChatMessageItem({
    required this.role,
    required this.content,
    this.offers = const [],
  });
  final String role;
  final String content;
  final List<ChatOfferAction> offers;
}

List<ChatOfferAction> _parseOffers(dynamic raw) {
  if (raw is! List) return [];
  return raw.map((e) {
    final m = e as Map<String, dynamic>;
    return ChatOfferAction(
      id: m['id'] as String,
      label: (m['label'] as String?) ?? m['id'] as String,
    );
  }).toList();
}

class ChatSessionItem {
  ChatSessionItem({
    required this.id,
    required this.title,
    required this.updatedAt,
    this.lastMessage = '',
  });

  final String id;
  final String title;
  final DateTime updatedAt;
  final String lastMessage;

  factory ChatSessionItem.fromJson(Map<String, dynamic> json) {
    return ChatSessionItem(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? 'Чат',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastMessage: json['lastMessage'] as String? ?? '',
    );
  }
}

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._service);
  final ChatService _service;

  final List<ChatMessageItem> messages = [];
  List<ChatSessionItem> sessions = [];
  String? sessionId;
  bool loading = false;
  bool loadingSessions = false;
  bool loadingHistory = false;

  Future<void> loadSessions() async {
    loadingSessions = true;
    notifyListeners();
    try {
      final raw = await _service.listSessions();
      sessions = raw.map(ChatSessionItem.fromJson).toList();
    } catch (_) {
      sessions = [];
    }
    loadingSessions = false;
    notifyListeners();
  }

  void startNewChat() {
    sessionId = null;
    messages.clear();
    notifyListeners();
  }

  Future<void> openSession(String id) async {
    sessionId = id;
    loadingHistory = true;
    messages.clear();
    notifyListeners();
    try {
      final data = await _service.history(id);
      final list = data['messages'] as List? ?? [];
      for (final m in list) {
        messages.add(ChatMessageItem(
          role: m['role'] as String,
          content: m['content'] as String,
        ));
      }
    } catch (e) {
      messages.add(ChatMessageItem(role: 'assistant', content: e.toString()));
    }
    loadingHistory = false;
    notifyListeners();
  }

  Future<void> send(String text, FlightProvider? flight) async {
    messages.add(ChatMessageItem(role: 'user', content: text));
    loading = true;
    notifyListeners();
    try {
      final res = await _service.ask(
        message: text,
        sessionId: sessionId,
        cabinClass: flight?.params.cabinClass,
        passengers: flight?.params.passengers,
      );
      sessionId = res['sessionId'] as String?;
      messages.add(ChatMessageItem(
        role: 'assistant',
        content: res['answer'] as String? ?? '',
        offers: _parseOffers(res['offers']),
      ));
      await loadSessions();
    } catch (e) {
      messages.add(ChatMessageItem(role: 'assistant', content: e.toString()));
    }
    loading = false;
    notifyListeners();
  }
}
