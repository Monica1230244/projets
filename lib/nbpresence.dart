import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class Top10PresencesPage extends StatefulWidget {
  @override
  _Top10PresencesPageState createState() => _Top10PresencesPageState();
}

class _Top10PresencesPageState extends State<Top10PresencesPage> {
  List<Map<String, dynamic>> top10 = [];
  bool isLoading = true;
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchTop10();
  }

  Future<void> fetchTop10() async {
    try {
      final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

      final response = await Supabase.instance.client
          .from('pointage')
          .select('idemploye, date_heure')
          .eq('type', 'Arrivee')
          .gte('date_heure', startOfMonth.toIso8601String())
          .lte('date_heure', endOfMonth.toIso8601String());

      final List pointages = response;

      Map<String, Set<String>> joursParEmploye = {};

      for (var pointage in pointages) {
        String employeId = pointage['idemploye'].toString();
        String jour = pointage['date_heure'].substring(0, 10);

        joursParEmploye.putIfAbsent(employeId, () => {}).add(jour);
      }

      List<Map<String, dynamic>> resultats = [];

      for (var entry in joursParEmploye.entries) {
        resultats.add({
          'employeId': entry.key,
          'nbPresences': entry.value.length,
        });
      }

      resultats.sort((a, b) => b['nbPresences'].compareTo(a['nbPresences']));

      final topEmployes = resultats.take(10).toList();

      List<Map<String, dynamic>> finalTop10 = [];

      for (var employe in topEmployes) {
        final userInfo = await Supabase.instance.client
            .from('user')
            .select('nom, prenom')
            .eq('id', employe['employeId'])
            .maybeSingle();

        if (userInfo != null) {
          finalTop10.add({
            'nom': userInfo['nom'],
            'prenom': userInfo['prenom'],
            'presences': employe['nbPresences'],
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
      await fetchTop10();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Top 10 des présences',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month,color: Colors.blue,),
            onPressed: _selectMonth,
            tooltip: "Changer de mois",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.blue,
        ),
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
                      child: Text('${index + 1}',style: TextStyle(color: Colors.black),),
                      backgroundColor: Colors.black26,
                    ),
                    title: Text(
                      '${employe['prenom']} ${employe['nom']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Présences : ${employe['presences']} jours'),
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
