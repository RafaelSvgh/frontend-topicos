import 'package:chat_app/router.dart';
import 'package:chat_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importa esto

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Asistente Legal',
      locale: const Locale('es', 'ES'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    );
  }
}
