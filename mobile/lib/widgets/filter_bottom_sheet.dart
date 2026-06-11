import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../providers/flight_provider.dart';
import 'app_button.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fp = context.watch<FlightProvider>();
    final f = fp.filters;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Text(l10n.filters, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('${f.minPrice.toInt()} - ${f.maxPrice.toInt()} ₸'),
          RangeSlider(
            values: RangeValues(f.minPrice, f.maxPrice),
            min: 0,
            max: 400000,
            activeColor: AppColors.primaryBright,
            onChanged: (v) => setState(() {
              f.minPrice = v.start;
              f.maxPrice = v.end;
            }),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.baggageIncluded),
            value: f.baggageOnly ?? false,
            onChanged: (v) => setState(() => f.baggageOnly = v == true ? true : null),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.refundable),
            value: f.refundableOnly ?? false,
            onChanged: (v) => setState(() => f.refundableOnly = v == true ? true : null),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.directFlight),
            value: f.directOnly ?? false,
            onChanged: (v) => setState(() => f.directOnly = v == true ? true : null),
          ),
          const SizedBox(height: 8),
          AppButton(label: l10n.apply, onPressed: () {
            fp.applyFilters();
            Navigator.pop(context);
          }),
          TextButton(onPressed: () {
            fp.resetFilters();
            Navigator.pop(context);
          }, child: Text(l10n.reset)),
        ],
      ),
    );
  }
}
