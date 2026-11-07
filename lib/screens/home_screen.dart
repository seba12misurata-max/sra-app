import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme.dart';
import 'chat_screen.dart';
import 'files_screen.dart';
import 'memory_screen.dart';
import 'settings_screen.dart';

/// الشاشة الرئيسية: تحتوي على شريط تنقّل يتكيّف مع حجم الشاشة.
/// - شاشات عريضة (Windows/Web): NavigationRail جانبي.
/// - شاشات ضيقة (Android): NavigationBar سفلي.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  int _selectedIndex = 0;
  bool? _connected; // null = جارٍ الفحص

  static const _destinations = [
    (icon: Icons.chat_bubble_outline, label: 'الدردشة'),
    (icon: Icons.psychology_outlined, label: 'الذاكرة'),
    (icon: Icons.folder_open_outlined, label: 'الملفات'),
  ];

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final ok = await _api.checkHealth();
    if (mounted) setState(() => _connected = ok);
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    _checkConnection();
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return ChatScreen(api: _api);
      case 1:
        return MemoryScreen(api: _api);
      case 2:
        return FilesScreen(api: _api);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _connectionPill() {
    Color color;
    String label;
    if (_connected == null) {
      color = SraColors.textMuted;
      label = 'جارٍ الفحص…';
    } else if (_connected == true) {
      color = SraColors.success;
      label = 'متصل';
    } else {
      color = SraColors.danger;
      label = 'غير متصل';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsetsDirectional.only(end: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    final appBar = AppBar(
      title: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsetsDirectional.only(end: 10),
            decoration: const BoxDecoration(
              color: SraColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const Text(
            'SRA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: _connectionPill(),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'الإعدادات',
          icon: const Icon(Icons.settings_outlined),
          onPressed: _openSettings,
        ),
      ],
    );

    if (isWide) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: SraColors.panel,
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1, color: SraColors.border),
            Expanded(child: _buildPage(_selectedIndex)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: _destinations
            .map((d) => NavigationDestination(icon: Icon(d.icon), label: d.label))
            .toList(),
      ),
    );
  }
}
