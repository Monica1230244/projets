

import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'utilisateur.dart';


class RetardService {
  static Future<int> calculerPenaliteTotale(DateTime start, DateTime end) async {
    final authBox = Hive.box('authBox');
    Users user = authBox.get('stocker_user');

    if (user == null || user.id == null) {
      print(" Utilisateur non trouvé");
      return 0;
    }

    final response = await Supabase.instance.client
        .from('pointage')
        .select()
        .eq('idemploye', user.id)
        .gte('date_heure', start.toIso8601String())
        .lte('date_heure', end.toIso8601String())
        .order('date_heure', ascending: true);

    final List data = response;

    int totalMinutesRetard = 0;

    for (var pointage in data) {
      final dateHeureStr = pointage['date_heure'];
      if (dateHeureStr == null) continue;

      final dateHeure = DateTime.parse(dateHeureStr);
      final h = dateHeure.hour;
      final m = dateHeure.minute;

      final estApres0830 = (h > 8) || (h == 8 && m > 30);
     // final estAvantMidi = h < 12;

      if (estApres0830 ) {
        final minutesRetard = (h - 8) * 60 + (m - 30);
        totalMinutesRetard += minutesRetard;
      }
    }

    final penaliteTotale = (totalMinutesRetard ~/ 10) * 5000;
    return penaliteTotale;
  }
}
