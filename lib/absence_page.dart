import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:projets/constants.dart';
import 'package:projets/user.dart';
import 'package:projets/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AbsencePage extends StatefulWidget {
  @override
  _AbsencePageState createState() => _AbsencePageState();
}

class _AbsencePageState extends State<AbsencePage> {
  List<String> absences = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerAbsences();
  }

  Future<void> chargerAbsences() async {
    try {
      final authBox = Hive.box('authBox');
      Users user = authBox.get('stocker_user');

      if (user == null || user.id == null) {
        throw Exception('Utilisateur non trouvé');
      }

      final today = DateTime.now();
      final debutMois = DateTime(today.year, today.month, 1);

      // Récupérer les jours de présence dans Supabase
      final response = await Supabase.instance.client
          .from('pointage')
          .select('date_heure')
          .eq('idemploye', user.id)
          .gte('date_heure', debutMois.toIso8601String())
          .lte('date_heure', today.toIso8601String());

      final pointages = List<Map<String, dynamic>>.from(response);

      // Jours où l'employé a pointé (au format yyyy-MM-dd)
      final joursPointes = pointages.map((e) {
        final date = DateTime.parse(e['date_heure']).toLocal();
        return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }).toSet();

      // Générer toutes les dates ouvrables (sans samedi/dimanche)
      List<String> toutesLesDates = [];
      for (DateTime d = debutMois;
      d.isBefore(today) || d.isAtSameMomentAs(today);
      d = d.add(Duration(days: 1))) {
        if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
          final dateStr = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
          toutesLesDates.add(dateStr);
        }
      }

      // Absences = jours ouvrables sans pointage
      final joursAbsents = toutesLesDates.where((date) => !joursPointes.contains(date)).toList();

      setState(() {
        absences = joursAbsents;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement des absences : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAbsences = absences.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text("Suivi de Présence", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.blue,
        ),
      ))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'TOTAL ABSENCES',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '$totalAbsences absences',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (totalAbsences == 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aucune absence enregistrée.',
                style: TextStyle(
                  fontSize: 18,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: absences.length,
              itemBuilder: (context, index) {
                final date = absences[index];
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: 24),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.do_not_disturb,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              date,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
