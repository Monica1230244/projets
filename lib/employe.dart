import 'package:flutter/material.dart';

class EmployeeCard extends StatelessWidget {
  final String name;
  final String arrival;
  final String departure;
  final bool showDetails;
  final String imagePath;

  EmployeeCard({
    required this.name,
    required this.arrival,
    required this.departure,
    this.showDetails = false,
    required this.imagePath,
  });

  bool isLate(String arrivalTime) {
    return arrivalTime.compareTo("08:30") > 0;
  }

  bool hasOvertime(String departureTime) {
    return departureTime.compareTo("18:30") > 0;
  }

  @override
  Widget build(BuildContext context) {
    bool late = isLate(arrival);
    bool overtime = hasOvertime(departure);

    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    name[0],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Arrivée: $arrival | Départ: $departure"),
                  ],
                ),
              ],
            ),
            if (late && !overtime)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text("Motif retard: Envoyer"),
              ),
            if (!late && overtime)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Motif heure supp: Travail"),
                    Text("Heures supp: 2h"),
                  ],
                ),
              ),
            if (late && overtime)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Motif retard: Envoyer"),
                    Text("Heures supp: 2h"),
                  ],
                ),
              ),
            if (showDetails)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Motif du retard accepté")));
                          },
                          child: Text("Valider", style: TextStyle(color: Colors.blue)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                TextEditingController _controller = TextEditingController();
                                return AlertDialog(
                                  title: Text("Motif du rejet"),
                                  content: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(hintText: "Saisissez la raison du rejet"),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Rejeté: ${_controller.text}",
                                                style: TextStyle(color: Colors.red)),
                                          ),
                                        );
                                      },
                                      child: Text("Envoyer", style: TextStyle(color: Colors.blue)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text("Rejeter", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
