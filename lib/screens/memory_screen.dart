import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/memory_item.dart';
import '../services/api_service.dart';
import '../theme.dart';

class MemoryScreen extends StatefulWidget {
  final ApiService api;
  const MemoryScreen({super.key, required this.api});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final _controller = TextEditingController();
  String _selectedType = 'fact';

  List<MemoryItem> _memories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final memories = await widget.api.getMemories();
      setState(() {
        _memories = memories;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذّر تحميل الذاكرة. تأكد من تشغيل الخادم.';
      });
    }
  }

  Future<void> _add() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    try {
      final mem = await widget.api.addMemory(text, _selectedType);
      setState(() => _memories.insert(0, mem));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر إضافة الذكرى')),
        );
      }
    }
  }

  Future<void> _delete(MemoryItem mem) async {
    setState(() => _memories.remove(mem));
    try {
      await widget.api.deleteMemory(mem.id);
    } catch (_) {
      setState(() => _memories.add(mem)); // التراجع عند الفشل
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الذاكرة طويلة المدى',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'هذا كل ما يتذكره SRA عنك. يمكنك إضافة معلومة يدوياً أو حذف أي عنصر.',
            style: TextStyle(color: SraColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // نموذج إضافة ذكرى يدوياً
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'أضف معلومة (مثال: أنا أدرس هندسة برمجيات)',
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedType,
                dropdownColor: SraColors.panelAlt,
                items: MemoryItem.typeLabels.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v ?? 'fact'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _add, child: const Text('إضافة')),
            ],
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
    if (_memories.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد ذكريات محفوظة بعد. تحدث مع SRA وسيبدأ بالتعلّم عنك تلقائياً.',
          textAlign: TextAlign.center,
          style: TextStyle(color: SraColors.textMuted),
        ),
      );
    }

    final dateFormat = DateFormat('y/MM/dd');

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _memories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final mem = _memories[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SraColors.panel,
              border: Border.all(color: SraColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mem.typeLabel} · أهمية ${mem.importanceScore.toStringAsFixed(1)} · '
                        '${dateFormat.format(mem.createdAt)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: SraColors.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(mem.content),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: SraColors.textMuted),
                  onPressed: () => _delete(mem),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
