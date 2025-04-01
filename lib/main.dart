import 'package:flutter/material.dart';
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
      debugShowCheckedModeBanner: false,
      home: RetardPage(),
    );
  }
}

