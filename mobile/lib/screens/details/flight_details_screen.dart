import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../../models/flight_offer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/flight_provider.dart';
import '../../services/flight_api_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/best_offer_badge.dart';
import '../../widgets/loading_widget.dart';
import '../booking/booking_screen.dart';
class FlightDetailsScreen extends StatefulWidget {
  const FlightDetailsScreen({super.key, required this.offerId, this.offer});

  final String offerId;
  final FlightOffer? offer;

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  FlightOffer? _offer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.offer != null) {
      setState(() {
        _offer = widget.offer;
        _loading = false;
      });
      return;
    }
    final fp = context.read<FlightProvider>();
    try {
      _offer = await context.read<FlightApiService>().getById(widget.offerId, fp.params.passengers);
    } catch (_) {
      _offer = fp.selected;
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fp = context.watch<FlightProvider>();
    final auth = context.watch<AuthProvider>();
    final fav = context.watch<FavoriteProvider>();
    final o = _offer;

    return AppScaffold(
      appBar: AppBar(
        title: Text(l10n.flightDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading || o == null
          ? const LoadingWidget()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _SummaryHeader(offer: o),
                      const SizedBox(height: 20),
                      _TimelineCard(offer: o),
                      const SizedBox(height: 16),
                      _ConditionsCard(l10n: l10n, offer: o),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: Row(
                    children: [
                      if (auth.isLoggedIn)
                        IconButton.filledTonal(
                          onPressed: () => fav.add(o.id, fp.params.passengers),
                          icon: Icon(
                            fav.contains(o.id) ? Icons.favorite : Icons.favorite_border,
                            color: fav.contains(o.id) ? Colors.red : null,
                          ),
                        ),
                      if (auth.isLoggedIn) const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: l10n.select,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BookingScreen(offer: o)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.offer});
  final FlightOffer offer;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.aggregatorName ?? '', style: Theme.of(context).textTheme.titleLarge),
                Text(offer.flightCode, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${offer.totalPrice.toStringAsFixed(0)} ₸',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              const BestOfferBadge(),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.offer});
  final FlightOffer offer;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm · d MMM');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.borderLight),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primaryBright, shape: BoxShape.circle)),
                Expanded(child: Container(width: 2, color: AppColors.primaryBright.withValues(alpha: 0.3))),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fmt.format(offer.departureAt), style: Theme.of(context).textTheme.titleMedium),
                  Text(offer.originCity ?? '', style: Theme.of(context).textTheme.bodyMedium),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(offer.formattedDuration, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Text(fmt.format(offer.arrivalAt), style: Theme.of(context).textTheme.titleMedium),
                  Text(offer.destinationCity ?? '', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard({required this.l10n, required this.offer});
  final AppLocalizations l10n;
  final FlightOffer offer;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          _CondRow(icon: Icons.luggage_outlined, text: l10n.baggageKg),
          _CondRow(icon: Icons.backpack_outlined, text: l10n.handLuggage),
          _CondRow(icon: Icons.sync_alt_rounded, text: offer.refundable ? l10n.refundable : '—'),
          _CondRow(icon: Icons.airline_seat_recline_extra, text: '${l10n.seatsLeft}: ${offer.seatsLeft}'),
        ],
      ),
    );
  }
}

class _CondRow extends StatelessWidget {
  const _CondRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primaryBright),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
