import 'package:flutter/material.dart';
import 'package:smartfly/core/theme/app_theme.dart';
import '../screens/chatbot/chatbot_screen.dart';

class ChatbotFloatingButton extends StatelessWidget {
  const ChatbotFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: AppColors.primary.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: AppColors.buttonGradient),
          ),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
