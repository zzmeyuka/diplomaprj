import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/chatbot_floating_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isLoggedIn) {
        context.read<BookingProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final bp = context.watch<BookingProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.bookings)),
      floatingActionButton: const Padding(padding: EdgeInsets.only(bottom: 72), child: ChatbotFloatingButton()),
      body: !auth.isLoggedIn
          ? Center(child: EmptyStateWidget(message: l10n.login))
          : bp.loading
              ? const LoadingWidget()
              : bp.bookings.isEmpty
                  ? Center(child: EmptyStateWidget(message: l10n.empty))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: bp.bookings.length,
                      itemBuilder: (_, i) {
                        final b = bp.bookings[i];
                        final f = b['flight'] as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightBg,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: isDark ? Colors.white12 : AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBright.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.confirmation_number_rounded, color: AppColors.primaryBright),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${f['origin']} → ${f['destination']}', style: Theme.of(context).textTheme.titleMedium),
                                    Text('${f['aggregator']} · ${b['bookingStatus']}', style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                              Text(
                                '${b['totalPrice']} ₸',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
