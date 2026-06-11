import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/flight_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/chatbot_floating_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/flight_card.dart';
import '../../widgets/loading_widget.dart';
import '../details/flight_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isLoggedIn) {
        context.read<FavoriteProvider>().load(context.read<FlightProvider>().params.passengers);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final fav = context.watch<FavoriteProvider>();
    final fp = context.watch<FlightProvider>();

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.favorites)),
      floatingActionButton: const Padding(padding: EdgeInsets.only(bottom: 72), child: ChatbotFloatingButton()),
      body: !auth.isLoggedIn
          ? Center(child: EmptyStateWidget(message: l10n.login))
          : fav.loading
              ? const LoadingWidget()
              : fav.items.isEmpty
                  ? Center(child: EmptyStateWidget(message: l10n.empty))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: fav.items.length,
                      itemBuilder: (_, i) {
                        final o = fav.items[i];
                        return Dismissible(
                          key: ValueKey(o.id),
                          onDismissed: (_) => fav.remove(o.id, fp.params.passengers),
                          child: FlightCard(
                            offer: o,
                            showBadge: false,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlightDetailsScreen(offerId: o.id, offer: o))),
                            onSelect: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlightDetailsScreen(offerId: o.id, offer: o))),
                          ),
                        );
                      },
                    ),
    );
  }
}
