import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:projets/constants.dart';
import 'package:projets/user.dart';
import 'package:projets/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RetardPage extends StatefulWidget {
  @override
  _RetardPageState createState() => _RetardPageState();
}

class _RetardPageState extends State<RetardPage> {
  List<Map<String, dynamic>> presences = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerRetards();
  }

  Future<void> chargerRetards() async {
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

      // Garder uniquement les retards du matin
      final retards = tousLesPointages.where((pointage) {
        final dateHeureStr = pointage['date_heure'];
        if (dateHeureStr == null) return false;

        final dateHeure = DateTime.parse(dateHeureStr);
        final h = dateHeure.hour;
        final m = dateHeure.minute;


        final estApres0830 = (h > 8) || (h == 8 && m > 30);
        final estAvantMidi = h < 12;

        return estApres0830 && estAvantMidi;
      }).toList();


      setState(() {
        presences = retards;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erreur lors du chargement des retards : $e');
    }
  }
  String formatMinutesToHours(int totalMinutes) {
    if (totalMinutes <= 0) return "0h00mn";
    final heureArrivee = totalMinutes ~/ 60;
    final minuteArrivee = totalMinutes % 60;
    return "${heureArrivee} h ${minuteArrivee.toString().padLeft(2, '0')} mn";
  }

  int calculerMinutesRetard(DateTime dateHeure) {
    final heureArrivee = dateHeure.hour;
    final minuteArrivee = dateHeure.minute;

    const heureReference = 8;
    const minuteReference = 30;

    if (heureArrivee < heureReference || (heureArrivee == heureReference && minuteArrivee <= minuteReference)) {
      return 0;
    }
    return (heureArrivee - heureReference) * 60 + (minuteArrivee - minuteReference);
  }

  @override
  Widget build(BuildContext context) {
    final penalitePar10Min = 5000;

    final totalMinutesRetard = presences.fold(0, (sum, p) {
      final dateHeure = DateTime.parse(p['date_heure']);
      return sum + calculerMinutesRetard(dateHeure);
    });

    final totalPenalite = (totalMinutesRetard ~/ 10) * penalitePar10Min;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Retards',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'TOTAL RETARDS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '$totalMinutesRetard minutes',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pénalité: $totalPenalite FCFA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '(5000 FCFA par tranche de 10 minutes)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (totalMinutesRetard == 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aucun retard enregistré.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF2B9BD7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: presences.length,
              itemBuilder: (context, index) {
                final retard = presences[index];
                final dateHeure = DateTime.parse(retard['date_heure']);
                final minutesRetard = calculerMinutesRetard(dateHeure);
                final hasRetard = minutesRetard > 0;
                final penalite = (minutesRetard ~/ 10) * penalitePar10Min;


                IconData statusIcon;
                Color statusColor;
                String statusText;

                switch (retard['status']) {
                  case "Validé":
                    statusIcon = Icons.check_circle;
                    statusColor = Colors.green;
                    statusText = "Validé";
                    break;
                  case "Rejeté":
                    statusIcon = Icons.cancel;
                    statusColor = Colors.red;
                    statusText = "Rejeté";
                    break;
                  case "En attente":
                    statusIcon = Icons.hourglass_empty;
                    statusColor = Colors.orangeAccent;
                    statusText = "En attente";
                    break;
                  default:
                    statusIcon = Icons.help;
                    statusColor = Colors.grey;
                    statusText = "";
                    break;
                }

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
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateHeure.toLocal().toString().split(' ')[0],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color(0xFF2B9BD7),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Arrivée: ${dateHeure.hour.toString().padLeft(2, '0')}:${dateHeure.minute.toString().padLeft(2, '0')} (Retard: ${minutesRetard} min)',
                                ),
                                if (hasRetard) SizedBox(height: 2),
                                if (hasRetard)
                                  SizedBox(height: 4),
                                if (retard['motif']!.isNotEmpty)
                                  Text(
                                    'Motif de retard : ${retard['motif']}',
                                    style: TextStyle(color:  Colors.black),
                                  ),
                                SizedBox(height: 6),
                                Text(
                                  'Pénalité: $penalite FCFA',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (retard['motif']!.isNotEmpty)
                                  SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(statusIcon, color: statusColor, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Status: $statusText',
                                      style: TextStyle(color: statusColor),
                                    ),
                                  ],
                                ),
                              ],

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
