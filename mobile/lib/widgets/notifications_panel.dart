import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../providers/notification_provider.dart';

class NotificationsBanner extends StatelessWidget {
  const NotificationsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unread;
    if (unread.isEmpty) return const SizedBox.shrink();
    final n = unread.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => showNotificationsSheet(context),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    n.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => context.read<NotificationProvider>().dismiss(n.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showNotificationsSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final np = context.read<NotificationProvider>();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Consumer<NotificationProvider>(
        builder: (_, provider, __) {
          final items = provider.items;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.notifications, style: Theme.of(ctx).textTheme.titleLarge),
                    if (items.isNotEmpty)
                      TextButton(
                        onPressed: provider.markAllRead,
                        child: Text(l10n.markAllRead),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(l10n.noNotifications, textAlign: TextAlign.center),
                  )
                else
                  ...items.take(10).map(
                        (n) => ListTile(
                          leading: Icon(
                            n.read ? Icons.notifications_none : Icons.notifications_active,
                            color: AppColors.primaryBright,
                          ),
                          title: Text(n.message),
                          subtitle: Text(
                            _formatTime(n.createdAt),
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => provider.dismiss(n.id),
                          ),
                        ),
                      ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );

  np.markAllRead();
}

String _formatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'только что';
  if (diff.inHours < 1) return '${diff.inMinutes} мин назад';
  if (diff.inDays < 1) return '${diff.inHours} ч назад';
  return '${dt.day}.${dt.month}.${dt.year}';
}
