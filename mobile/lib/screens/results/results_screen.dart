import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../../providers/flight_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/chatbot_floating_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/flight_card.dart';
import '../../widgets/loading_widget.dart';
import '../details/flight_details_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fp = context.watch<FlightProvider>();

    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('${fp.params.from} → ${fp.params.to}', style: Theme.of(context).textTheme.titleMedium),
            Text(fp.dateStr, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: const ChatbotFloatingButton(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: _PillButton(
                    icon: Icons.sort_rounded,
                    label: l10n.sorting,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: SortOption.values.map((o) {
                              String label;
                              switch (o) {
                                case SortOption.earliest:
                                  label = l10n.sortEarliest;
                                case SortOption.shortest:
                                  label = l10n.sortShortest;
                                case SortOption.cheapest:
                                  label = l10n.sortCheapest;
                              }
                              return ListTile(
                                title: Text(label),
                                trailing: fp.sort == o ? const Icon(Icons.check, color: AppColors.primaryBright) : null,
                                onTap: () {
                                  fp.setSortOption(o);
                                  Navigator.pop(ctx);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: fp.loading
                ? const LoadingWidget()
                : fp.visibleOffers.isEmpty
                    ? EmptyStateWidget(message: fp.error ?? l10n.empty)
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: fp.visibleOffers.length,
                        itemBuilder: (_, i) {
                          final offer = fp.visibleOffers[i];
                          final selected = fp.selected?.id == offer.id;
                          return FlightCard(
                            offer: offer,
                            showBadge: fp.isCheapest(offer),
                            selected: selected,
                            onTap: () {
                              fp.select(offer);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => FlightDetailsScreen(offerId: offer.id, offer: offer)),
                              );
                            },
                            onSelect: () {
                              fp.select(offer);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => FlightDetailsScreen(offerId: offer.id, offer: offer)),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkCard : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primaryBright),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
