import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Ajoutez cette ligne
import 'package:projets/accueil_page.dart';
import 'package:projets/connect_page.dart';
import 'package:projets/heure_supp.dart';
import 'package:projets/presence_page.dart';
import 'package:projets/retard_page.dart';
import 'user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // Nécessite flutter_localizations
        GlobalWidgetsLocalizations.delegate,   // Nécessite flutter_localizations
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'), // Français
      ],
      debugShowCheckedModeBanner: false,
      home: ConnectPage(),
    );
  }
}