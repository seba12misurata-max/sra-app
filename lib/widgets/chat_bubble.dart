import 'package:flutter/material.dart';

import '../theme.dart';

/// فقاعة رسالة في المحادثة (مستخدم أو SRA).
class ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool pending;

  const ChatBubble({
    super.key,
    required this.content,
    required this.isUser,
    this.pending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? SraColors.accentDim : SraColors.panelAlt,
          borderRadius: BorderRadius.circular(12),
          border: isUser ? null : Border.all(color: SraColors.border),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? const Color(0xFFFFF7EC) : SraColors.text,
            height: 1.6,
            fontStyle: pending ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}

/// شريط صغير يظهر أسفل رد SRA إذا استخدم معلومات من الذاكرة طويلة المدى.
class MemoryUsedNote extends StatelessWidget {
  final List<String> memories;

  const MemoryUsedNote({super.key, required this.memories});

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: SraColors.border, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '🧠 استُخدمت من ذاكرتك: ${memories.join(' · ')}',
          style: const TextStyle(color: SraColors.textMuted, fontSize: 11),
        ),
      ),
    );
  }
}
