import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/personalized_routes_provider.dart';
import 'search/search_screen.dart';
import 'favorites/favorites_screen.dart';
import 'bookings/my_bookings_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) {
        context.read<PersonalizedRoutesProvider>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pages = const [SearchScreen(), FavoritesScreen(), MyBookingsScreen(), ProfileScreen()];

    return Scaffold(
      extendBody: true,
      body: pages[_index],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white12 : AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            height: 64,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: _index,
            onDestinationSelected: (i) {
              setState(() => _index = i);
              if (i == 0 && context.read<AuthProvider>().isLoggedIn) {
                context.read<PersonalizedRoutesProvider>().refresh();
              }
            },
            destinations: [
              NavigationDestination(icon: Icon(Icons.search_rounded), label: l10n.search),
              NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: l10n.favorites),
              NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), selectedIcon: Icon(Icons.confirmation_number_rounded), label: l10n.bookings),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: l10n.settings),
            ],
          ),
        ),
      ),
    );
  }
}
