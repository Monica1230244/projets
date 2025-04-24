import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:projets/constants.dart';
import 'package:projets/user.dart';
import 'package:projets/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HeuresSupplementairesPage extends StatefulWidget {
  @override
  _HeuresSupplementairesPageState createState() => _HeuresSupplementairesPageState();
}

class _HeuresSupplementairesPageState extends State<HeuresSupplementairesPage> {
  List<Map<String, dynamic>> presences = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerHeuresSupp();
  }

  Future<void> chargerHeuresSupp() async {
    try {
      final authBox = Hive.box('authBox');
      Users user = authBox.get('stocker_user');

      if (user == null || user.id == null) {
        throw Exception('Utilisateur non trouvé');
      }

      final response = await Supabase.instance.client
          .from('pointage')
          .select()
          .eq('idemploye', user.id)
          .order('date_heure', ascending: false);

      final tousLesPointages = List<Map<String, dynamic>>.from(response);

      final heuresSupp = tousLesPointages.where((pointage) {
        final dateHeureStr = pointage['date_heure'];
        if (dateHeureStr == null) return false;

        final dateHeure = DateTime.parse(dateHeureStr);
        final h = dateHeure.hour;
        final m = dateHeure.minute;

        return (h > 18) || (h == 18 && m > 30); // après 18h30
      }).toList();

      setState(() {
        presences = heuresSupp;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erreur lors du chargement des heures supp : $e');
    }
  }

  int calculerMinutesSupplementaires(DateTime dateHeure) {
    const heureRef = 18;
    const minuteRef = 30;

    final h = dateHeure.hour;
    final m = dateHeure.minute;

    if (h < heureRef || (h == heureRef && m <= minuteRef)) return 0;
    return (h - heureRef) * 60 + (m - minuteRef);
  }

  String formatDuree(int totalMinutes) {
    if (totalMinutes >= 60) {
      return '${totalMinutes ~/ 60}h ${totalMinutes % 60}min';
    }
    return '${totalMinutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = presences.fold(0, (sum, p) {
      final dateHeure = DateTime.parse(p['date_heure']);
      return sum + calculerMinutesSupplementaires(dateHeure);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Heures Supplémentaires',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
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
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'TOTAL HEURES SUPPLÉMENTAIRES',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      formatDuree(totalMinutes),
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
          Expanded(
            child: presences.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hourglass_empty, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Aucune heure supplémentaire',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: presences.length,
              itemBuilder: (context, index) {
                final presence = presences[index];
                final dateHeure = DateTime.parse(presence['date_heure']);
                final minutes = calculerMinutesSupplementaires(dateHeure);
                final hours = minutes ~/ 60;
                final remainingMinutes = minutes % 60;
                final dateStr = dateHeure.toLocal().toString().split(' ')[0];

                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.access_time,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Départ à ${dateHeure.hour.toString().padLeft(2, '0')}:${dateHeure.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '$hours h ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Text(
                                    '$remainingMinutes min',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
