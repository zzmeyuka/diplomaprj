import 'package:flutter/material.dart';
import 'notifications_panel.dart';
import 'smartfly_logo.dart';

class SmartFlyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SmartFlyAppBar({
    super.key,
    this.showBell = true,
    this.title,
    this.leading,
  });

  final bool showBell;
  final Widget? title;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: leading != null,
      leading: leading,
      title: title ?? const SmartFlyLogo(size: 36),
      centerTitle: true,
      actions: [
        if (showBell)
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => showNotificationsSheet(context),
          ),
      ],
    );
  }
}
