import 'package:email_otp/email_otp.dart';
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

import 'connect.dart';

void main() async {
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

  EmailOTP.config(
    appName: 'Waouh Monde',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v4,
  );
  // verifier si l'utilisateur est toujours connecté
  final authBox = Hive.box('authBox');
  final Users? user = authBox.get('stocker_user') as Users?;

  runApp(MyApp(isConnect: user != null));
}

class MyApp extends StatelessWidget {
  final bool isConnect;

  const MyApp({super.key, required this.isConnect});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('fr_FR', null);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: AppColor.backgroundForm,
          selectionHandleColor: AppColor.backgroundForm,
          cursorColor: AppColor.backgroundForm,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      home: isConnect ? Accueil() : Connect(),
    );
  }
}

class AppColor {
  static const Color backgroundForm = Color(0xFF2B9BD7);
}
