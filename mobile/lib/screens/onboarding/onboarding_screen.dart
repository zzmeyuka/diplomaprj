import 'package:flutter/material.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/app_button.dart';
import '../../widgets/smartfly_logo.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, this.previewOnly = false});

  /// When true (opened from login), back instead of going to login flow.
  final bool previewOnly;

  Future<void> _finish(BuildContext context) async {
    if (previewOnly) {
      if (context.mounted) Navigator.pop(context);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: previewOnly
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.flight_rounded, size: 72, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              const SmartFlyLogo(size: 48),
              const SizedBox(height: 12),
              Text(
                l10n.appTagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: l10n.startSearch,
                onPressed: () => _finish(context),
              ),
              if (!previewOnly)
                TextButton(
                  onPressed: () => _finish(context),
                  child: Text(
                    l10n.skip,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
