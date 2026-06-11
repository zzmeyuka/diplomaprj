import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import '../../models/flight_offer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/flight_provider.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/flight_card.dart';
import '../../widgets/loading_widget.dart';
import '../details/flight_details_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<FlightOffer> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      setState(() => _loading = false);
      return;
    }
    final fp = context.read<FlightProvider>();
    final api = context.read<RecommendationService>();
    try {
      _items = await api.get(
        passengers: fp.params.passengers,
        cabinClass: fp.params.cabinClass,
      );
    } catch (_) {
      _items = [];
    }
    setState(() => _loading = false);
  }

  void _open(FlightOffer o) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FlightDetailsScreen(offerId: o.id, offer: o)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      appBar: AppBar(
        title: Text(l10n.recommendations),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const LoadingWidget()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(l10n.recommendationsHint, style: Theme.of(context).textTheme.bodyLarge),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final o = _items[i];
                      return FlightCard(
                        offer: o,
                        onTap: () => _open(o),
                        onSelect: () => _open(o),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
