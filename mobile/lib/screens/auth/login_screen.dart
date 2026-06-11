import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../main_shell.dart';
import '../onboarding/onboarding_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'user@gmail.com');
  final _password = TextEditingController(text: '123456');
  bool _loading = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(l10n.welcomeBack, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 32),
              AppTextField(
                controller: _email,
                label: l10n.emailOrPhone,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _password,
                label: l10n.password,
                obscure: _obscure,
                prefixIcon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(auth.error!, style: TextStyle(color: Colors.red.shade600, fontSize: 13)),
                ),
              AppButton(
                label: l10n.login,
                loading: _loading,
                onPressed: () async {
                  setState(() => _loading = true);
                  final ok = await auth.login(_email.text.trim(), _password.text);
                  setState(() => _loading = false);
                  if (!context.mounted) return;
                  if (ok) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.noAccount, style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: Text(l10n.register, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                ),
                child: Text(l10n.guestContinue),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen(previewOnly: true)),
                ),
                child: Text(l10n.backToWelcome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
