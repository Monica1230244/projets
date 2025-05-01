import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:projets/connect_page.dart';
import 'package:projets/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projets/accueil_page.dart';
import 'package:projets/connect_admin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tryfckvixbjkpjhhyewi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI'
        '6InRyeWZja3ZpeGJqa3BqaGh5ZXdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwMTkyMDksImV4'
        'cCI6MjA1OTU5NTIwOX0.bUAUjXqg_O3MUTL0pV4GSDz6BNpk6A5EIfMWb72F2II',
  );

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UsersAdapter());
  }
  await Hive.openBox('authBox');
  await Hive.openBox('users');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('fr_FR', null);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: AppColor.backgroundForm, // Couleur de la sélection
          selectionHandleColor: AppColor.backgroundForm, // Couleur des poignées
          cursorColor: AppColor.backgroundForm, // Couleur du curseur
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      home: Accueil(),
    );
  }
}
class AppColor {
  static const Color backgroundForm = Color(0xFF2B9BD7);
}