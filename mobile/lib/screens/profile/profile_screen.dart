import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          if (auth.user != null) _Section(
            isDark: isDark,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary,
                child: Text(
                  auth.user!.fullName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22),
                ),
              ),
              title: Text(auth.user!.fullName, style: Theme.of(context).textTheme.titleLarge),
              subtitle: Text(auth.user!.email),
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            isDark: isDark,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.theme),
                  subtitle: Text(theme.isDark ? l10n.darkMode : l10n.lightMode),
                  value: theme.isDark,
                  activeThumbColor: AppColors.primaryBright,
                  onChanged: (_) => theme.toggle(),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                _LangTile(code: 'ru', flag: '🇷🇺', label: 'Русский', selected: locale.locale.languageCode == 'ru', onTap: () => locale.setLocale('ru')),
                _LangTile(code: 'en', flag: '🇬🇧', label: 'English', selected: locale.locale.languageCode == 'en', onTap: () => locale.setLocale('en')),
                _LangTile(code: 'kk', flag: '🇰🇿', label: 'Қазақша', selected: locale.locale.languageCode == 'kk', onTap: () => locale.setLocale('kk')),
              ],
            ),
          ),
          if (auth.user?.isAdmin == true) ...[
            const SizedBox(height: 12),
            _Section(
              isDark: isDark,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primaryBright),
                title: Text(l10n.adminPanel),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _Section(
            isDark: isDark,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(auth.isLoggedIn ? Icons.logout_rounded : Icons.login_rounded, color: auth.isLoggedIn ? Colors.red.shade400 : AppColors.primaryBright),
              title: Text(auth.isLoggedIn ? l10n.logout : l10n.login),
              onTap: () async {
                if (auth.isLoggedIn) {
                  await auth.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.isDark, required this.child});
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _LangTile extends StatelessWidget {
  const _LangTile({required this.code, required this.flag, required this.label, required this.selected, required this.onTap});
  final String code;
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle, color: AppColors.primaryBright) : null,
      onTap: onTap,
    );
  }
}
