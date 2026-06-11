import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    return AppScaffold(
      appBar: AppBar(
        title: Text(l10n.register),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(controller: _name, label: l10n.fullName, prefixIcon: Icons.person_outline_rounded),
            const SizedBox(height: 14),
            AppTextField(controller: _email, label: l10n.emailOrPhone, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.mail_outline_rounded),
            const SizedBox(height: 14),
            AppTextField(controller: _phone, label: l10n.phone, keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined),
            const SizedBox(height: 14),
            AppTextField(controller: _password, label: l10n.password, obscure: true, prefixIcon: Icons.lock_outline_rounded),
            const SizedBox(height: 14),
            AppTextField(controller: _confirm, label: l10n.confirmPassword, obscure: true, prefixIcon: Icons.verified_user_outlined),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(auth.error!, style: TextStyle(color: Colors.red.shade600)),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: l10n.register,
              loading: _loading,
              onPressed: () async {
                if (_password.text != _confirm.text) return;
                setState(() => _loading = true);
                final ok = await auth.register(
                  fullName: _name.text,
                  email: _email.text.trim(),
                  password: _password.text,
                  phoneNumber: _phone.text,
                );
                setState(() => _loading = false);
                if (!context.mounted) return;
                if (ok) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (_) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
