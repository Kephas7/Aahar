import 'package:flutter/material.dart';

import '../core/themes/aahar_theme.dart';
import 'routes.dart';

class AaharApp extends StatelessWidget {
  const AaharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Aahar',
      theme: AaharTheme.darkTheme,
    );
  }
}
