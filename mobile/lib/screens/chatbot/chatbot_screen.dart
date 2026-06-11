import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/flight_provider.dart';
import '../../services/flight_api_service.dart';
import '../../widgets/app_scaffold.dart';
import '../booking/booking_screen.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _controller = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) {
        context.read<ChatProvider>().loadSessions();
      }
    });
  }

  void _openHistoryDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> _openBooking(BuildContext context, String offerId) async {
    final flightApi = context.read<FlightApiService>();
    final fp = context.read<FlightProvider>();
    try {
      final offer = await flightApi.getById(offerId, fp.params.passengers);
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookingScreen(offer: offer)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final fp = context.read<FlightProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: AppBar(
        title: Text(l10n.chatbot),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: l10n.newChat,
            onPressed: auth.isLoggedIn ? () => chat.startNewChat() : null,
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.chatHistory,
            onPressed: auth.isLoggedIn ? _openHistoryDrawer : null,
          ),
        ],
      ),
      endDrawer: auth.isLoggedIn ? _ChatHistoryDrawer(onSelect: (id) {
        Navigator.pop(context);
        chat.openSession(id);
      }) : null,
      body: Column(
        children: [
          if (chat.loadingHistory) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: chat.messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        auth.isLoggedIn
                            ? 'Задайте вопрос о билетах или откройте историю чатов'
                            : l10n.login,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: chat.messages.length,
                    itemBuilder: (_, i) => _MessageBubble(
                      message: chat.messages[i],
                      isDark: isDark,
                      onOfferBook: (id) => _openBooking(context, id),
                    ),
                  ),
          ),
          if (chat.loading) const LinearProgressIndicator(minHeight: 2, color: AppColors.primaryBright),
          _InputBar(
            controller: _controller,
            enabled: auth.isLoggedIn && !chat.loading,
            hint: auth.isLoggedIn ? 'Сообщение...' : l10n.login,
            onSend: () async {
              final text = _controller.text.trim();
              if (text.isEmpty) return;
              _controller.clear();
              await chat.send(text, fp);
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isDark,
    required this.onOfferBook,
  });
  final ChatMessageItem message;
  final bool isDark;
  final ValueChanged<String> onOfferBook;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.85),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : (isDark ? AppColors.darkCard : AppColors.lightSurface),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
            ),
            child: Text(
              message.content,
              style: TextStyle(color: isUser ? Colors.white : null, height: 1.4, fontSize: 15),
            ),
          ),
          if (!isUser && message.offers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: message.offers.map((o) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.9),
                      child: FilledButton.tonal(
                        onPressed: () => onOfferBook(o.id),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          backgroundColor: AppColors.primaryBright.withValues(alpha: 0.15),
                          foregroundColor: AppColors.primary,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.bookThisFlight, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(o.label, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, height: 1.2)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.hint,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool enabled;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              enabled: enabled,
              onSubmitted: enabled ? (_) => onSend() : null,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: enabled ? onSend : null,
              borderRadius: BorderRadius.circular(14),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatHistoryDrawer extends StatelessWidget {
  const _ChatHistoryDrawer({required this.onSelect});
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chat = context.watch<ChatProvider>();

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.chatHistory, style: Theme.of(context).textTheme.titleLarge)),
                  TextButton.icon(
                    onPressed: () {
                      chat.startNewChat();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.newChat),
                  ),
                ],
              ),
            ),
            if (chat.loadingSessions)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (chat.sessions.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.noChatHistory, textAlign: TextAlign.center),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: chat.sessions.length,
                  itemBuilder: (_, i) {
                    final s = chat.sessions[i];
                    final active = chat.sessionId == s.id;
                    return ListTile(
                      selected: active,
                      title: Text(
                        s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        s.lastMessage.isNotEmpty ? s.lastMessage : _formatDate(s.updatedAt),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onSelect(s.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
