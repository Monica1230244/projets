import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:projets/absence_page.dart';
import 'package:projets/heure_supp.dart';
import 'package:projets/presence_page.dart';
import 'package:projets/retard_page.dart';
import 'package:projets/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projets/constants.dart';
import 'penalite.dart';

class PresenceUser extends StatefulWidget {
  const PresenceUser({Key? key}) : super(key: key);
  @override
  _PresenceUserState createState() => _PresenceUserState();
}

class _PresenceUserState extends State<PresenceUser> {
  late DateTime _selectedDate;
  late DateTime _selectedEndDate;
  int presenceCount = 0;
  int totalJours = 0;
  int absenceCount = 0;
  int retardCount = 0;
  int heuresSuppCount = 0;
  double penaliteMontant = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
     final DateTime now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, 1);
    _selectedEndDate = DateTime.now();
    _loadDataFromSupabase();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _selectedDate : _selectedEndDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),

      builder: (BuildContext context , Widget? child){
        return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary:Color(0xFF2B9BD7),
                surface: Colors.white,
                onSurface: Colors.black,
              )
            ),
            child: child!,
        );
      }
    );


    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _selectedDate = pickedDate;
          if (_selectedEndDate.isBefore(pickedDate)) {
            _selectedEndDate = pickedDate.add(const Duration(days: 30));
            totalJours = 30;
          }
        } else {
          _selectedEndDate = pickedDate;
          totalJours = _selectedEndDate.difference(_selectedDate).inDays + 1;
        }
      });
      _loadDataFromSupabase();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
  }

  Future<void> _loadDataFromSupabase() async {
    final supabase = Supabase.instance.client;
    final authBox = Hive.box('authBox');
    Users user = authBox.get('stocker_user');

    if (user == null || user.id == null) {
      print('Utilisateur non trouvé dans Hive');
      return;
    }

    final userId = user.id;
    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final end = DateTime(_selectedEndDate.year, _selectedEndDate.month, _selectedEndDate.day, 23, 59, 59);

    try {
      final response = await supabase
          .from('pointage')
          .select()
          .eq('idemploye', userId)
          .gte('date_heure', start.toIso8601String())
          .lte('date_heure', end.toIso8601String())
          .order('date_heure', ascending: true);
Logger().d(response);
      final List data = response;

      final Map<String, List<DateTime>> pointagesParJour = {};

      for (var item in data) {
        final dateHeure = DateTime.parse(item['date_heure']);
        final jourKey = DateFormat('yyyy-MM-dd').format(dateHeure);
        pointagesParJour.putIfAbsent(jourKey, () => []);
        pointagesParJour[jourKey]!.add(dateHeure);
      }

      int presence = 0;
      int retard = 0;
      int heuresSupp = 0;

      pointagesParJour.forEach((jour, liste) {
        liste.sort();
        if (liste.isNotEmpty) presence += 1;

        final arrivee = liste.first;
        final depart = liste.last;

        final arriveeTime = TimeOfDay.fromDateTime(arrivee);
        final departTime = TimeOfDay.fromDateTime(depart);

        if ((arriveeTime.hour > 8 || (arriveeTime.hour == 8 && arriveeTime.minute > 30))) {
          final retardMinutes = (arriveeTime.hour - 8) * 60 + (arriveeTime.minute - 30);
          retard += 1;

        }


        if (departTime.hour > 18 || (departTime.hour == 18 && departTime.minute > 30)) {
          int minutesSupp = ((departTime.hour - 18) * 60 + (departTime.minute - 30));
          heuresSupp += minutesSupp;
        }
      });

      // les  jours fériés
      final List<DateTime> joursFeries = [
        DateTime(_selectedDate.year, 1, 1), // Nouvel an
        DateTime(_selectedDate.year, 5, 1), // Fête du travail
        DateTime(_selectedDate.year, 8, 15), // Assomption
        DateTime(_selectedDate.year, 12, 25), // Noël
        DateTime(_selectedDate.year, 5, 29), // Ascension
        DateTime(_selectedDate.year, 5, 08), // Victoire 1945
        DateTime(_selectedDate.year, 6, 09), // Lundi de Pentecôte
        DateTime(_selectedDate.year, 7, 14), // Fête nationale
        DateTime(_selectedDate.year, 11, 01), // Toussaint
        DateTime(_selectedDate.year, 4, 21), // Lundi de Pâques
        DateTime(_selectedDate.year, 11, 11), // Armistice
      ];


      // permet de calculer les jours ouvrables
      List<DateTime> joursOuvrables = [];

      for (int i = 0; i <= _selectedEndDate.difference(_selectedDate).inDays; i++) {
        DateTime jour = _selectedDate.add(Duration(days: i));
        bool estWeekend = jour.weekday == DateTime.saturday || jour.weekday == DateTime.sunday;
        bool estFerie = joursFeries.any((ferie) => ferie.year == jour.year && ferie.month == jour.month && ferie.day == jour.day);

        if (!estWeekend && !estFerie) {
          joursOuvrables.add(jour);
        }
      }

      int totalJoursCalcul = joursOuvrables.length;
      int absences = totalJoursCalcul - presence;


      //  Appel au service pour calculer la pénalité
      final penaliteRetards = await RetardService.calculerPenaliteTotale(start, end);

      setState(() {
        totalJours = totalJoursCalcul;
        presenceCount = presence;
        absenceCount = absences;
        retardCount = retard;
        heuresSuppCount = (heuresSupp / 60).round();
        penaliteMontant = penaliteRetards.toDouble();
        isLoading = false;
      });
    } catch (e) {
      print("Erreur Supabase: $e");
      isLoading = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        title: const Text("Tableau de bord", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:  isLoading
          ? Center(child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.blue,
        ),
      ))
          :SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDateSelector("Du", _selectedDate, () => _selectDate(context, true)),
                  _buildDateSelector("Au", _selectedEndDate, () => _selectDate(context, false)),
                ],
              ),
              const SizedBox(height: 50),
              _buildOptionTile(
                icon: Icons.check_circle,
                color: Colors.green,
                text: "Présence",
                count: "$presenceCount/$totalJours",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PresencePage())),
              ),
              _buildOptionTile(
                icon: Icons.cancel,
                color: Colors.red,
                text: "Absence",
                count: "$absenceCount/$totalJours",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AbsencePage())),
              ),
              _buildOptionTile(
                icon: Icons.timer,
                color: Colors.orange,
                text: "Retard",
                count: "$retardCount/$totalJours",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RetardPage())),
              ),
              _buildOptionTile(
                icon: Icons.access_time,
                color: Colors.blue,
                text: "Heures Supp",
                count: "$heuresSuppCount h",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HeuresSupplementairesPage())),
              ),
              _buildPenaltyTile(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDateSelector(String label, DateTime date, VoidCallback onTap) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(_formatDate(date), style: TextStyle(color: Color(0xFF2B9BD7))),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildOptionTile({
    required IconData icon,
    required Color color,
    required String text,
    required String count,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 30),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(icon, color: color, size: 28),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text, style: TextStyle(fontSize: 18)),
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text(
                    count,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPenaltyTile() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 30),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(Icons.money_off, color: Colors.purple, size: 28),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pénalité", style: TextStyle(fontSize: 18)),
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${penaliteMontant.toStringAsFixed(0)} FR",
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
