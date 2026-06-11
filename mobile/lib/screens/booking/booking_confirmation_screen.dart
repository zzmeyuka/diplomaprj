import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import '../../models/flight_offer.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_button.dart';
import '../main_shell.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.offer,
    required this.total,
  });

  final String bookingId;
  final FlightOffer offer;
  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().addBookingSuccess(
            route: '${offer.originCity} → ${offer.destinationCity}',
          );
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green.shade600),
              const SizedBox(height: 16),
              Text(l10n.bookingSuccess, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('ID: $bookingId'),
              Text('${offer.originCity} → ${offer.destinationCity}'),
              Text('${total.toStringAsFixed(0)} ${offer.currency}'),
              const SizedBox(height: 32),
              AppButton(
                label: l10n.viewBookings,
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 2)),
                  (_) => false,
                ),
              ),
              AppButton(
                label: l10n.backHome,
                outlined: true,
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
