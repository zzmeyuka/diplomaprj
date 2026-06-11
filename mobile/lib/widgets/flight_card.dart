import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../models/flight_offer.dart';
import 'best_offer_badge.dart';

class FlightCard extends StatelessWidget {
  const FlightCard({
    super.key,
    required this.offer,
    required this.onTap,
    required this.onSelect,
    this.showBadge = false,
    this.selected = false,
  });

  final FlightOffer offer;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final bool showBadge;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFmt = DateFormat('HH:mm');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: selected
            ? AppColors.primaryBright.withValues(alpha: isDark ? 0.15 : 0.08)
            : (isDark ? AppColors.darkCard : AppColors.lightBg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: selected
                ? AppColors.primaryBright
                : (isDark ? Colors.white12 : AppColors.borderLight),
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AirlineAvatar(name: offer.aggregatorName ?? ''),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(offer.aggregatorName ?? '', style: Theme.of(context).textTheme.titleMedium),
                              ),
                              if (showBadge) const BestOfferBadge(),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${offer.totalPrice.toStringAsFixed(0)} ₸',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _TimeCol(time: timeFmt.format(offer.departureAt), code: offer.originCity ?? '')),
                    Column(
                      children: [
                        Text(offer.formattedDuration, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(width: 28, height: 1, color: AppColors.borderLight),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(Icons.flight, size: 16, color: AppColors.primaryBright.withValues(alpha: 0.8)),
                            ),
                            Container(width: 28, height: 1, color: AppColors.borderLight),
                          ],
                        ),
                      ],
                    ),
                    Expanded(child: _TimeCol(time: timeFmt.format(offer.arrivalAt), code: offer.destinationCity ?? '', alignEnd: true)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onSelect,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.select),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AirlineAvatar extends StatelessWidget {
  const _AirlineAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : 'A',
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _TimeCol extends StatelessWidget {
  const _TimeCol({required this.time, required this.code, this.alignEnd = false});
  final String time;
  final String code;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(time, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        Text(code, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
