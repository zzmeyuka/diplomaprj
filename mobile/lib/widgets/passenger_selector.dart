import 'package:flutter/material.dart';
import 'package:smartfly/core/theme/app_theme.dart';

class PassengerSelector extends StatelessWidget {
  const PassengerSelector({super.key, required this.count, required this.onChanged});

  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CircleBtn(icon: Icons.remove_rounded, enabled: count > 1, onTap: () => onChanged(count - 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text('$count', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          _CircleBtn(icon: Icons.add_rounded, enabled: count < 9, onTap: () => onChanged(count + 1)),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.lightBg : AppColors.lightSurface,
      shape: const CircleBorder(),
      elevation: enabled ? 2 : 0,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: enabled ? AppColors.primary : AppColors.textSecondary),
        ),
      ),
    );
  }
}
