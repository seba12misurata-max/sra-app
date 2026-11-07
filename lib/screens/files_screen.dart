import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/file_item.dart';
import '../services/api_service.dart';
import '../theme.dart';

class FilesScreen extends StatefulWidget {
  final ApiService api;
  const FilesScreen({super.key, required this.api});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<FileItem> _files = [];
  bool _loading = true;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final files = await widget.api.getFiles();
      setState(() {
        _files = files;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذّر تحميل الملفات. تأكد من تشغيل الخادم.';
      });
    }
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (picked.bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تعذّر قراءة الملف المحدد')));
      }
      return;
    }

    setState(() => _uploading = true);
    try {
      final file = await widget.api.uploadFile(
        filename: picked.name,
        bytes: picked.bytes,
      );
      setState(() {
        _files.insert(0, file);
        _uploading = false;
      });
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل رفع الملف: $e')));
      }
    }
  }

  void _openAskSheet(FileItem file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SraColors.panel,
      builder: (context) => _AskFileSheet(api: widget.api, file: file),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الملفات والمكتبة الشخصية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'ارفع ملف PDF أو نصي ليقوم SRA بتلخيصه، ثم اسأله عن محتواه.',
            style: TextStyle(color: SraColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _uploading ? null : _pickAndUpload,
            icon: _uploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            label: Text(_uploading ? 'جارٍ التحليل…' : 'رفع ملف وتحليله'),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }
    if (_files.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد ملفات مرفوعة بعد.',
          style: TextStyle(color: SraColors.textMuted),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _files.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final file = _files[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SraColors.panel,
              border: Border.all(color: SraColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.filename, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  file.summary?.isNotEmpty == true ? file.summary! : 'بدون ملخص',
                  style: const TextStyle(color: SraColors.textMuted, fontSize: 13),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: () => _openAskSheet(file),
                    child: const Text('اسأل عن هذا الملف'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// نافذة سفلية لطرح سؤال عن ملف معيّن.
class _AskFileSheet extends StatefulWidget {
  final ApiService api;
  final FileItem file;
  const _AskFileSheet({required this.api, required this.file});

  @override
  State<_AskFileSheet> createState() => _AskFileSheetState();
}

class _AskFileSheetState extends State<_AskFileSheet> {
  final _controller = TextEditingController();
  String? _answer;
  bool _loading = false;

  Future<void> _ask() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _loading = true;
      _answer = null;
    });
    try {
      final answer = await widget.api.askFile(widget.file.id, question);
      setState(() {
        _answer = answer;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _answer = 'تعذّر الحصول على إجابة.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('أسئلة عن: ${widget.file.filename}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'اكتب سؤالك…'),
                  onSubmitted: (_) => _ask(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loading ? null : _ask,
                child: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('اسأل'),
              ),
            ],
          ),
          if (_answer != null) ...[
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Text(_answer!, style: const TextStyle(height: 1.6)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
