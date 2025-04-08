import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:projets/connect_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';




  Future<void> main() async {
    await Supabase.initialize(
      url: 'https://tryfckvixbjkpjhhyewi.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyeWZja3ZpeGJqa3BqaGh5ZXdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwMTkyMDksImV4cCI6MjA1OTU5NTIwOX0.bUAUjXqg_O3MUTL0pV4GSDz6BNpk6A5EIfMWb72F2II',
    );

    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('fr_FR', null);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      home: ConnectPage(),
    );
  }
}
