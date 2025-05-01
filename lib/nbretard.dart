import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class Top10RetardsPage extends StatefulWidget {
  @override
  _Top10RetardsPageState createState() => _Top10RetardsPageState();
}

class _Top10RetardsPageState extends State<Top10RetardsPage> {
  List<Map<String, dynamic>> top10 = [];
  bool isLoading = true;
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchTop10Retards();
  }

  Future<void> fetchTop10Retards() async {
    try {
      final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

      final response = await Supabase.instance.client
          .from('pointage')
          .select('idemploye, date_heure, type')
          .eq('type', 'Arrivee')
          .gte('date_heure', startOfMonth.toIso8601String())
          .lte('date_heure', endOfMonth.toIso8601String());

      final List data = response;

      Map<String, int> retardParEmploye = {};

      for (var pointage in data) {
        final dateHeure = DateTime.parse(pointage['date_heure']);
        final heureArrivee = TimeOfDay.fromDateTime(dateHeure);

        // Retard : arrivée après 08:30
        if (heureArrivee.hour > 8 || (heureArrivee.hour == 8 && heureArrivee.minute > 30)) {
          String employeId = pointage['idemploye'].toString();
          retardParEmploye.update(employeId, (value) => value + 1, ifAbsent: () => 1);
        }
      }

      List<Map<String, dynamic>> resultats = [];

      retardParEmploye.forEach((employeId, retardCount) {
        resultats.add({
          'employeId': employeId,
          'retards': retardCount,
        });
      });

      resultats.sort((a, b) => b['retards'].compareTo(a['retards']));

      final topRetards = resultats.take(10).toList();

      List<Map<String, dynamic>> finalTop10 = [];

      for (var employe in topRetards) {
        final userInfo = await Supabase.instance.client
            .from('user')
            .select('nom, prenom')
            .eq('id', employe['employeId'])
            .maybeSingle();

        if (userInfo != null) {
          finalTop10.add({
            'nom': userInfo['nom'],
            'prenom': userInfo['prenom'],
            'retards': employe['retards'],
          });
        }
      }

      setState(() {
        top10 = finalTop10;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectMonth() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('fr', 'FR'),
      helpText: 'Sélectionner un mois',
      fieldLabelText: 'Mois',
      fieldHintText: 'Mois/Année',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
        isLoading = true;
      });
      await fetchTop10Retards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Top 10 des retards', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, color: Colors.black38),
            onPressed: _selectMonth,
            tooltip: "Changer de mois",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ))
          : top10.isEmpty
          ? Center(child: Text("Aucune donnée trouvée."))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Mois sélectionné: ${DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: top10.length,
              itemBuilder: (context, index) {
                final employe = top10[index];
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}', style: TextStyle(color: Colors.black)),
                      backgroundColor: Colors.black26,
                    ),
                    title: Text(
                      '${employe['prenom']} ${employe['nom']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Retards : ${employe['retards']} fois'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
