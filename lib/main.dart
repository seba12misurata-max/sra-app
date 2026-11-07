import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  runApp(const SraApp());
}

class SraApp extends StatelessWidget {
  const SraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRA',
      debugShowCheckedModeBanner: false,
      theme: buildSraTheme(),
      // دعم الاتجاه من اليمين لليسار للعربية
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
