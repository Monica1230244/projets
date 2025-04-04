import 'package:flutter/material.dart';
import 'package:projets/absence_page.dart';
import 'package:projets/accueil_page.dart';
import 'package:projets/constants.dart';

class HeuresSupplementairesPage extends StatefulWidget {
  final List<Map<String, String>> presences = [
    {"date": "2025-03-02", "heure": "09:40", "heure_depart": "17:30", "motif": "Permission"},
    {"date": "2025-03-03", "heure": "08:45", "heure_depart": "18:30", "motif": ""},
    {"date": "2025-03-06", "heure": "09:00", "heure_depart": "19:00", "motif": ""},
    {"date": "2025-03-02", "heure": "09:40", "heure_depart": "18:45", "motif": "Permission"},
    {"date": "2025-03-03", "heure": "08:45", "heure_depart": "18:30", "motif": ""},
    {"date": "2025-03-06", "heure": "09:00", "heure_depart": "20:00", "motif": ""},
    {"date": "2025-03-03", "heure": "08:45", "heure_depart": "18:30", "motif": ""},
    {"date": "2025-03-06", "heure": "09:00", "heure_depart": "20:00", "motif": ""},
  ];

  @override
  _HeuresSupplementairesPageState createState() => _HeuresSupplementairesPageState();
}

class _HeuresSupplementairesPageState extends State<HeuresSupplementairesPage> {
  int calculerMinutesSupplementaires(String heureDepart) {
    final parts = heureDepart.split(':');
    final heures = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    if (heures < 18 || (heures == 18 && minutes <= 30)) {
      return 0;
    }
    return (heures - 18) * 60 + minutes - 30;
  }

  String formatDuree(int totalMinutes) {
    if (totalMinutes >= 60) {
      return '${totalMinutes ~/ 60}h ${totalMinutes % 60}min';
    }
    return '${totalMinutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final heuresSupList = widget.presences.where((p) => calculerMinutesSupplementaires(p['heure_depart']!) > 0).toList();
    final totalMinutes = heuresSupList.fold(0, (sum, p) => sum + calculerMinutesSupplementaires(p['heure_depart']!));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Heures Supplémentaires',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            )),
        centerTitle: true,
        backgroundColor:primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Accueil()),
            );
          },
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, Colors.deepPurple[400]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'TOTAL HEURES SUPPLEMENTAIRES',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
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
              child: heuresSupList.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucune heure supplémentaire',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: heuresSupList.length,
                itemBuilder: (context, index) {
                  final presence = heuresSupList[index];
                  final minutes = calculerMinutesSupplementaires(presence['heure_depart']!);
                  final hours = minutes ~/ 60;
                  final remainingMinutes = minutes % 60;

                  return Card(
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
                                color:primaryColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    presence['date']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Départ à ${presence['heure_depart']}',
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
                                      '$hours h',
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
                                )
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
      ),
    );
  }
}