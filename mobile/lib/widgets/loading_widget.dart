import 'package:flutter/material.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.loading),
        ],
      ),
    );
  }
}
