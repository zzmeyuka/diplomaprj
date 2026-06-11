import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../../models/flight_offer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/flight_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.offer});

  final FlightOffer offer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fp = context.watch<FlightProvider>();
    final auth = context.watch<AuthProvider>();
    final bp = context.watch<BookingProvider>();
    final total = offer.pricePerPassenger * fp.params.passengers;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(
        title: Text(l10n.bookingTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${offer.originCity} → ${offer.destinationCity}', style: Theme.of(context).textTheme.titleLarge),
                Text('${offer.aggregatorName} · ${offer.flightCode}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            isDark: isDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.passengers, style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    _CounterBtn(
                      icon: Icons.remove,
                      onTap: fp.params.passengers > 1 ? () => fp.setPassengers(fp.params.passengers - 1) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('${fp.params.passengers}', style: Theme.of(context).textTheme.headlineMedium),
                    ),
                    _CounterBtn(
                      icon: Icons.add,
                      onTap: fp.params.passengers < 9 ? () => fp.setPassengers(fp.params.passengers + 1) : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            isDark: isDark,
            child: Column(
              children: ['economy', 'comfort', 'business'].map((c) {
                final label = c == 'comfort' ? l10n.comfort : c == 'business' ? l10n.business : l10n.economy;
                return RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  value: c,
                  groupValue: fp.params.cabinClass,
                  activeColor: AppColors.primaryBright,
                  onChanged: (v) {
                    if (v != null) fp.setCabin(v);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            isDark: isDark,
            child: Column(
              children: [
                _PriceRow(label: l10n.pricePerPassenger, value: '${offer.pricePerPassenger.toStringAsFixed(0)} ₸'),
                const SizedBox(height: 8),
                _PriceRow(
                  label: l10n.totalPrice,
                  value: '${total.toStringAsFixed(0)} ₸',
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: offer.aggregatorName == 'Kaspi Travel' ? l10n.continueKaspi : l10n.continueBtn,
            loading: bp.loading,
            onPressed: auth.isLoggedIn
                ? () async {
                    try {
                      final res = await bp.create(
                        flightOfferId: offer.id,
                        passengersCount: fp.params.passengers,
                      );
                      if (res == null || !context.mounted) return;
                      final booking = res['booking']! as Map<String, dynamic>;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingConfirmationScreen(
                            bookingId: booking['id'] as String,
                            offer: offer,
                            total: total,
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                : null,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(l10n.noHiddenFees, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.isDark, required this.child});
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.borderLight),
      ),
      child: child,
    );
  }
}

class _CounterBtn extends StatelessWidget {
  const _CounterBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightSurface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: onTap != null ? AppColors.primary : AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          value,
          style: bold
              ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)
              : Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
