import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = TextEditingController();
  final _api = ApiService();
  bool _loading = true;
  bool _saving = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final url = await SettingsService.getServerUrl();
    setState(() {
      _controller.text = url;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _testResult = null;
    });
    await SettingsService.setServerUrl(_controller.text.trim());
    final ok = await _api.checkHealth();
    setState(() {
      _saving = false;
      _testResult = ok
          ? '✅ تم الاتصال بالخادم بنجاح'
          : '⚠️ تم الحفظ، لكن تعذّر الاتصال بهذا العنوان حالياً';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'عنوان خادم SRA (Backend URL)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'http://192.168.1.50:8000',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('حفظ واختبار الاتصال'),
                  ),
                  if (_testResult != null) ...[
                    const SizedBox(height: 12),
                    Text(_testResult!),
                  ],
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'كيف أعرف العنوان الصحيح؟',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  const _HelpText(
                    '• محاكي Android (Emulator) والخادم على نفس الكمبيوتر:\n'
                    '  http://10.0.2.2:8000\n\n'
                    '• جهاز Android حقيقي على نفس شبكة Wi-Fi التي عليها الكمبيوتر:\n'
                    '  http://<IP الكمبيوتر على الشبكة>:8000\n'
                    '  (مثال: http://192.168.1.50:8000)\n\n'
                    '• تطبيق Windows أو Web يعمل على نفس الكمبيوتر الذي يشغّل الخادم:\n'
                    '  http://localhost:8000',
                  ),
                ],
              ),
            ),
    );
  }
}

class _HelpText extends StatelessWidget {
  final String text;
  const _HelpText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(height: 1.6, color: Color(0xFF8B909C), fontSize: 13),
    );
  }
}
