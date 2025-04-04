import 'package:flutter/material.dart';
import 'package:projets/accueil_page.dart';
import 'package:projets/heure_supp.dart';
import 'package:projets/user.dart';

import 'constants.dart';

class RetardPage extends StatefulWidget {
  final List<Map<String, String>> presences = [
    {"date": "2025-03-02", "heure": "09:40", "heure_depart": "18:00", "motif": "Permission", "status": "Validé"},
    {"date": "2025-03-03", "heure": "08:45", "heure_depart": "17:30", "motif": "", "status": ""},
    {"date": "2025-03-06", "heure": "09:00", "heure_depart": "18:30", "motif": "Permission", "status": "En attente"},
    {"date": "2025-03-03", "heure": "08:45", "heure_depart": "17:30", "motif": "Retard", "status": "Rejeté"},
    {"date": "2025-03-06", "heure": "09:00", "heure_depart": "18:30", "motif": "Permission", "status": "Validé"},
  ];

  @override
  _RetardPageState createState() => _RetardPageState();
}

class _RetardPageState extends State<RetardPage> {
  int calculerMinutesRetard(String heureArrivee) {
    final parts = heureArrivee.split(':');
    final heures = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    const heureReference = 8;
    const minuteReference = 30;

    if (heures < heureReference || (heures == heureReference && minutes <= minuteReference)) {
      return 0;
    }
    return (heures - heureReference) * 60 + (minutes - minuteReference);
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutesRetard = widget.presences.fold(0, (sum, p) => sum + calculerMinutesRetard(p['heure']!));
    final penalitePar10Min = 5000;
    final totalPenalite = (totalMinutesRetard ~/ 10) * penalitePar10Min;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Presence() ),
            );
          },
        ),
        title: Text('Retards',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor:  Color(0xFF2B9BD7),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, primaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, Colors.deepPurple[400]!],
                    ),
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
                itemCount: widget.presences.length,
                itemBuilder: (context, index) {
                  final retard = widget.presences[index];
                  final minutesRetard = calculerMinutesRetard(retard['heure']!);
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
                                    '${retard['date']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: hasRetard ? Colors.deepPurple : Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Arrivée: ${retard['heure']} ${hasRetard ? '(Retard: ${minutesRetard} min)' : ''}',
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
      ),
    );
  }
}