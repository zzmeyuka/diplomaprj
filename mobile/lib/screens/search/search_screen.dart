import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/flight_provider.dart';
import '../../providers/personalized_routes_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/chatbot_floating_button.dart';
import '../../widgets/city_search_field.dart';
import '../../widgets/notifications_panel.dart';
import '../../widgets/smartfly_app_bar.dart';
import '../results/results_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static final _popular = [
    ('Almaty', 'Astana', '24 000'),
    ('Almaty', 'Istanbul', '95 000'),
    ('Astana', 'Dubai', '110 000'),
    ('Shymkent', 'Antalya', '98 000'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fp = context.watch<FlightProvider>();
    final auth = context.watch<AuthProvider>();
    final personalized = context.watch<PersonalizedRoutesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkCard : AppColors.lightSurface;

    final showPersonalized = auth.isLoggedIn && (personalized.loading || personalized.routes.isNotEmpty);

    return AppScaffold(
      extendBody: true,
      appBar: const SmartFlyAppBar(),
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 72),
        child: ChatbotFloatingButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const NotificationsBanner(),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text(l10n.roundTrip)),
              ButtonSegment(value: false, label: Text(l10n.oneWay)),
            ],
            selected: {fp.params.roundTrip},
            onSelectionChanged: (s) => fp.setRoundTrip(s.first),
          ),
          const SizedBox(height: 16),
          _SearchCard(
            child: Column(
              children: [
                _FieldRow(
                  icon: Icons.flight_takeoff_rounded,
                  label: l10n.from,
                  child: CitySearchField(
                    value: fp.params.from,
                    cities: fp.cities,
                    hint: l10n.searchCity,
                    onSelected: fp.setFromCity,
                  ),
                ),
                Divider(height: 1, color: isDark ? Colors.white12 : AppColors.borderLight),
                _FieldRow(
                  icon: Icons.flight_land_rounded,
                  label: l10n.to,
                  child: CitySearchField(
                    value: fp.params.to,
                    cities: fp.cities,
                    hint: l10n.searchCity,
                    onSelected: fp.setToCity,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primaryBright),
                    onPressed: () {
                      final a = fp.params.from;
                      fp.setFromCity(fp.params.to);
                      fp.setToCity(a);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SearchCard(
                  child: _DateField(
                    label: l10n.departureDate,
                    date: fp.params.date,
                    onPick: (d) => fp.setDate(d),
                  ),
                ),
              ),
              if (fp.params.roundTrip) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _SearchCard(
                    child: _DateField(
                      label: l10n.returnDate,
                      date: fp.params.returnDate,
                      onPick: fp.setReturnDate,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _SearchCard(
            onTap: () => _showPassengerSheet(context),
            child: Row(
              children: [
                Icon(Icons.people_outline_rounded, color: AppColors.primaryBright.withValues(alpha: 0.9)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.passengersAndClass, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                      Text(
                        '${fp.params.passengers} · ${_cabinLabel(l10n, fp.params.cabinClass)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withValues(alpha: 0.6)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: l10n.searchFlights,
            onPressed: () async {
              await fp.search();
              if (!context.mounted) return;
              if (context.read<AuthProvider>().isLoggedIn) {
                context.read<PersonalizedRoutesProvider>().refresh();
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen()));
            },
          ),
          const SizedBox(height: 28),
          Text(
            showPersonalized ? l10n.personalizedDestinations : l10n.popularDestinations,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (showPersonalized && personalized.loading)
            const SizedBox(height: 118, child: Center(child: CircularProgressIndicator()))
          else if (showPersonalized)
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: personalized.routes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final r = personalized.routes[i];
                  final priceStr = r.minPrice != null ? r.minPrice!.round().toString() : '—';
                  return _PopularCard(
                    from: r.originCity,
                    to: r.destinationCity,
                    price: priceStr,
                    surface: surface,
                    onTap: () {
                      fp.setFromCity(r.originCity);
                      fp.setToCity(r.destinationCity);
                    },
                  );
                },
              ),
            )
          else
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: SearchScreen._popular.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final p = SearchScreen._popular[i];
                  return _PopularCard(
                    from: p.$1,
                    to: p.$2,
                    price: p.$3,
                    surface: surface,
                    onTap: () {
                      fp.setFromCity(p.$1);
                      fp.setToCity(p.$2);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _cabinLabel(AppLocalizations l10n, String c) {
    switch (c) {
      case 'comfort':
        return l10n.comfort;
      case 'business':
        return l10n.business;
      default:
        return l10n.economy;
    }
  }

  void _showPassengerSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer<FlightProvider>(
        builder: (ctx, fpSheet, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.passengersAndClass, style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.passengers),
                    Row(
                      children: [
                        IconButton(
                          onPressed: fpSheet.params.passengers > 1
                              ? () => fpSheet.setPassengers(fpSheet.params.passengers - 1)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${fpSheet.params.passengers}', style: Theme.of(ctx).textTheme.titleLarge),
                        IconButton(
                          onPressed: fpSheet.params.passengers < 9
                              ? () => fpSheet.setPassengers(fpSheet.params.passengers + 1)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...['economy', 'comfort', 'business'].map((c) => RadioListTile<String>(
                      title: Text(_cabinLabel(l10n, c)),
                      value: c,
                      groupValue: fpSheet.params.cabinClass,
                      activeColor: AppColors.primaryBright,
                      onChanged: (v) {
                        if (v != null) fpSheet.setCabin(v);
                        Navigator.pop(ctx);
                      },
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkCard : AppColors.lightBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: isDark ? Colors.white12 : AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.icon, required this.label, required this.child, this.trailing});
  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Icon(icon, size: 22, color: AppColors.primaryBright),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                child,
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.date, required this.onPick});
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy');
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2026, 6, 1),
          lastDate: DateTime(2026, 8, 31),
        );
        if (d != null) onPick(d);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text(fmt.format(date), style: Theme.of(context).textTheme.titleMedium)),
                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primaryBright),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({
    required this.from,
    required this.to,
    required this.price,
    required this.surface,
    required this.onTap,
  });
  final String from;
  final String to;
  final String price;
  final Color surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$from →', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
            Text(to, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text(
              l10n.fromPrice(price),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
