import 'package:flutter/material.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final ApiService api;
  const ChatScreen({super.key, required this.api});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  List<Conversation> _conversations = [];
  int? _currentConversationId;
  List<ChatMessage> _messages = [];
  final Map<int, List<String>> _memoryNotes = {}; // messageId -> ذكريات مستخدمة

  bool _loadingConversations = true;
  bool _loadingMessages = false;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _loadingConversations = true;
      _error = null;
    });
    try {
      var convs = await widget.api.getConversations();
      if (convs.isEmpty) {
        final created = await widget.api.createConversation();
        convs = [created];
      }
      setState(() {
        _conversations = convs;
        _loadingConversations = false;
      });
      _currentConversationId ??= convs.first.id;
      await _loadMessages(_currentConversationId!);
    } catch (e) {
      setState(() {
        _loadingConversations = false;
        _error = 'تعذّر الاتصال بالخادم. تأكد من تشغيله وصحة العنوان في الإعدادات.';
      });
    }
  }

  Future<void> _loadMessages(int conversationId) async {
    setState(() {
      _loadingMessages = true;
      _currentConversationId = conversationId;
      _messages = [];
    });
    try {
      final msgs = await widget.api.getMessages(conversationId);
      setState(() {
        _messages = msgs;
        _loadingMessages = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _loadingMessages = false);
    }
  }

  Future<void> _newConversation() async {
    try {
      final conv = await widget.api.createConversation();
      setState(() {
        _conversations.insert(0, conv);
      });
      await _loadMessages(conv.id);
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _currentConversationId == null || _sending) return;

    _inputController.clear();
    setState(() {
      _sending = true;
      // إضافة رسالة المستخدم فوراً (تحديث متفائل) + رسالة "يكتب الآن"
      _messages.add(ChatMessage(
        id: -1,
        role: 'user',
        content: content,
        createdAt: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        id: -2,
        role: 'assistant',
        content: 'SRA يكتب…',
        createdAt: DateTime.now(),
      ));
    });
    _scrollToBottom();

    try {
      final result = await widget.api.sendMessage(_currentConversationId!, content);
      setState(() {
        // إزالة الرسالتين المؤقتتين، وإضافة الرسائل الحقيقية من الخادم
        _messages.removeWhere((m) => m.id == -1 || m.id == -2);
        _messages.add(result.userMessage);
        _messages.add(result.assistantMessage);
        if (result.usedMemories.isNotEmpty) {
          _memoryNotes[result.assistantMessage.id] = result.usedMemories;
        }
        _sending = false;
      });
      _scrollToBottom();
      // تحديث عنوان المحادثة في القائمة (قد تتغير عند أول رسالة)
      _refreshConversationTitles();
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.id == -2);
        _messages.add(ChatMessage(
          id: -3,
          role: 'assistant',
          content: 'تعذّر الحصول على رد: تأكد من تشغيل الخادم وصحة مفتاح Claude API.',
          createdAt: DateTime.now(),
        ));
        _sending = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _refreshConversationTitles() async {
    try {
      final convs = await widget.api.getConversations();
      setState(() => _conversations = convs);
    } catch (_) {}
  }

  void _openConversationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SraColors.panel,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add, color: SraColors.accent),
                title: const Text('محادثة جديدة'),
                onTap: () {
                  Navigator.pop(context);
                  _newConversation();
                },
              ),
              const Divider(color: SraColors.border, height: 1),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _conversations.length,
                  itemBuilder: (context, i) {
                    final conv = _conversations[i];
                    final selected = conv.id == _currentConversationId;
                    return ListTile(
                      title: Text(
                        conv.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? SraColors.accent : SraColors.text,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (!selected) _loadMessages(conv.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String get _currentTitle {
    final conv = _conversations
        .where((c) => c.id == _currentConversationId)
        .toList();
    return conv.isNotEmpty ? conv.first.title : 'محادثة';
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingConversations) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 40, color: SraColors.textMuted),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadConversations,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // شريط اختيار المحادثة
        InkWell(
          onTap: _openConversationPicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SraColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.forum_outlined, size: 18, color: SraColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.expand_more, color: SraColors.textMuted),
              ],
            ),
          ),
        ),

        // قائمة الرسائل
        Expanded(
          child: _loadingMessages
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'ابدأ محادثة مع SRA',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'سيتذكر SRA المعلومات المهمة من حديثك ويستخدمها لاحقاً.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: SraColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final msg = _messages[i];
                        final notes = _memoryNotes[msg.id];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ChatBubble(
                              content: msg.content,
                              isUser: msg.isUser,
                              pending: msg.id == -2,
                            ),
                            if (notes != null) MemoryUsedNote(memories: notes),
                          ],
                        );
                      },
                    ),
        ),

        // شريط الإدخال
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: SraColors.panel,
              border: Border(top: BorderSide(color: SraColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالتك هنا…',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _sendMessage,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
