import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/conversation.dart';
import '../models/file_item.dart';
import '../models/memory_item.dart';
import '../models/message.dart';
import 'settings_service.dart';

/// نتيجة إرسال رسالة - تحتوي على رد المساعد والذكريات المستخدمة.
class SendMessageResult {
  final ChatMessage userMessage;
  final ChatMessage assistantMessage;
  final List<String> usedMemories;

  SendMessageResult({
    required this.userMessage,
    required this.assistantMessage,
    required this.usedMemories,
  });
}

/// استثناء مخصص يُستخدم لإظهار رسائل خطأ واضحة بالعربية في الواجهة.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// طبقة الاتصال بـ SRA Backend (FastAPI).
/// تقرأ عنوان الخادم من [SettingsService] في كل طلب، بحيث يمكن للمستخدم
/// تغييره من شاشة الإعدادات دون إعادة تشغيل التطبيق.
class ApiService {
  Future<String> get _baseUrl => SettingsService.getServerUrl();

  Future<Uri> _uri(String path) async {
    final base = await _baseUrl;
    return Uri.parse('$base$path');
  }

  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(await _uri('/health'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------------- المحادثات ----------------

  Future<List<Conversation>> getConversations() async {
    final res = await http.get(await _uri('/chat/conversations'));
    _checkOk(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Conversation> createConversation() async {
    final res = await http.post(await _uri('/chat/conversations'));
    _checkOk(res);
    return Conversation.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    final res =
        await http.get(await _uri('/chat/conversations/$conversationId/messages'));
    _checkOk(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SendMessageResult> sendMessage(int conversationId, String content) async {
    final res = await http.post(
      await _uri('/chat/conversations/$conversationId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );
    _checkOk(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return SendMessageResult(
      userMessage: ChatMessage.fromJson(data['user_message']),
      assistantMessage: ChatMessage.fromJson(data['assistant_message']),
      usedMemories: (data['used_memories'] as List).cast<String>(),
    );
  }

  // ---------------- الذاكرة ----------------

  Future<List<MemoryItem>> getMemories() async {
    final res = await http.get(await _uri('/memory'));
    _checkOk(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => MemoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MemoryItem> addMemory(String content, String type) async {
    final res = await http.post(
      await _uri('/memory'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'content': content,
        'type': type,
        'importance_score': 0.6,
      }),
    );
    _checkOk(res);
    return MemoryItem.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteMemory(int id) async {
    final res = await http.delete(await _uri('/memory/$id'));
    _checkOk(res);
  }

  // ---------------- الملفات ----------------

  Future<List<FileItem>> getFiles() async {
    final res = await http.get(await _uri('/files'));
    _checkOk(res);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => FileItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// رفع ملف. على الويب يُمرَّر [bytes]، وعلى الموبايل/سطح المكتب يُمرَّر [path].
  Future<FileItem> uploadFile({
    required String filename,
    Uint8List? bytes,
    String? path,
  }) async {
    final uri = await _uri('/files/upload');
    final request = http.MultipartRequest('POST', uri);

    if (bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );
    } else if (path != null) {
      request.files.add(await http.MultipartFile.fromPath('file', path,
          filename: filename));
    } else {
      throw ApiException('لا يوجد محتوى للملف لرفعه');
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    _checkOk(res);
    return FileItem.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<String> askFile(int fileId, String question) async {
    final res = await http.post(
      await _uri('/files/$fileId/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'question': question}),
    );
    _checkOk(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['answer'] as String;
  }

  // ---------------- مساعد داخلي ----------------

  void _checkOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String detail = res.body;
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['detail'] != null) {
          detail = decoded['detail'].toString();
        }
      } catch (_) {}
      throw ApiException('خطأ من الخادم (${res.statusCode}): $detail');
    }
  }
}
