import 'package:flutter/material.dart';

class PresencePage extends StatefulWidget {
  @override
  _PresencePageState createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  final List<Map<String, String>> presences = [
    {"date": "2025-03-01", "heure": "08:00", "heure_depart": "17:00", "motif": ""},
    {"date": "2025-03-02", "heure": "09:40", "heure_depart": "18:00", "motif": "permission"},
    {"date": "2025-03-03", "heure": "08:45", "heure_depart": "17:30", "motif": "Retard"},
    {"date": "2025-03-04", "heure": "07:30", "heure_depart": "16:30", "motif": ""},
    {"date": "2025-03-05", "heure": "07:55", "heure_depart": "17:00", "motif": ""},
    {"date": "2025-03-06", "heure": "09:00", "heure_depart": "18:40", "motif": "pane de moto"},
  ];

  // Variable pour gérer l'élément sélectionné
  int? selectedIndex;

  // Calculer le nombre total de présences
  int getTotalPresences() {
    return presences.length;
  }

  // Vérifier si l'heure d'arrivée est après 8h30
  String checkRetard(String heure) {
    DateTime heure_arriver = DateTime.parse("2025-03-01 $heure:00");
    DateTime heure_limite = DateTime.parse("2025-03-01 08:30:00");

    if (heure_arriver.isAfter(heure_limite)) {
      return "Retard";
    }
    return "";
  }

  // Vérifier les heures supplémentaires après 18h30
  String checkHeuresSupplementaires(String heureDepart) {
    DateTime heure_depart = DateTime.parse("2025-03-01 $heureDepart:00");
    DateTime heure_limite = DateTime.parse("2025-03-01 18:30:00");

    if (heure_depart.isAfter(heure_limite)) {
      Duration difference = heure_depart.difference(heure_limite);
      int minutes = difference.inMinutes;
      double heures = minutes / 60;
      return heures.toStringAsFixed(2);
    }
    return "0";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi des Présences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF2A3D7A),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre total de présences: ${getTotalPresences()}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            // Liste des présences
            Expanded(
              child: ListView.builder(
                itemCount: presences.length,
                itemBuilder: (context, index) {
                  String motif = checkRetard(presences[index]['heure'] ?? '');
                  String heuresSupplementaires = checkHeuresSupplementaires(presences[index]['heure_depart'] ?? '');
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = (selectedIndex == index) ? null : index;  // Permet de "désélectionner" si on clique sur le même élément
                      });
                      if (motif.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Motif de Retard'),
                              content: Text(motif),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      color: selectedIndex == index ? Colors.blue[200] : Colors.white, // Change la couleur quand l'élément est sélectionné
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Color(0xFF2A3D7A), size: 40),
                        title: Text(
                          'Date: ${presences[index]['date']}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Heure d\'arrivée: ${presences[index]['heure']}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            Text(
                              'Heure de départ: ${presences[index]['heure_depart']}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            Text(
                              'Heures supplémentaires: $heuresSupplementaires',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                          ],
                        ),
                        trailing: motif.isNotEmpty
                            ? Icon(Icons.warning, color: Color(0xFF2A3D7A))
                            : null,
                        isThreeLine: motif.isNotEmpty,
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
