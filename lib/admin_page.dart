import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Rapport extends StatefulWidget {
  @override
  RapportState createState() => RapportState();
}

class RapportState extends State<Rapport> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Rapport mensuel",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),)
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2019, 1, 1),
            lastDay: DateTime.utc(9999, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            calendarFormat: CalendarFormat.twoWeeks,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blueAccent),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blueAccent),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
              weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),


          Expanded(
            child: ListView(
              children: [
                EmployeeCard(name: "Jean", arrival: "08:00", departure: "18:30", imagePath: "assets/image/img2.jpg"),
                EmployeeCard(name: "Marie", arrival: "09:30", departure: "19:00", showDetails: true, imagePath: "assets/image/img3.jpg"),
                EmployeeCard(name: "Pierre", arrival: "09:00", departure: "20:30", showDetails: true, imagePath: "assets/image/img6.jpg"),
                EmployeeCard(name: "Marlyne", arrival: "07:30", departure: "18:00", imagePath: "assets/image/img5.jpeg"),
                EmployeeCard(name: "Prince", arrival: "09:00", departure: "19:30", showDetails: true, imagePath: "assets/image/img4.jpg"),
                EmployeeCard(name: "Karel", arrival: "08:15", departure: "18:20", imagePath: "assets/image/img6.jpg"),
                EmployeeCard(name: "Adna", arrival: "09:00", departure: "18:30", showDetails: true, imagePath: "assets/image/img1.jpeg"),
                EmployeeCard(name: "Hamid", arrival: "08:10", departure: "18:00", imagePath: "assets/image/img4.jpg"),
                EmployeeCard(name: "Ruth", arrival: "08:00", departure: "18:30", imagePath: "assets/image/img5.jpeg"),
                EmployeeCard(name: "Charbel", arrival: "09:30", departure: "19:00", showDetails: true, imagePath: "assets/image/img2.jpg"),
                EmployeeCard(name: "Bonaventure", arrival: "08:45", departure: "18:30", showDetails: true, imagePath: "assets/image/img6.jpg"),
                EmployeeCard(name: "Carlos", arrival: "07:30", departure: "18:30", imagePath: "assets/image/img4.jpg"),
                EmployeeCard(name: "Miriam", arrival: "09:00", departure: "19:00", showDetails: true, imagePath: "assets/image/img7.jpeg"),
                EmployeeCard(name: "Monica", arrival: "08:20", departure: "18:30", imagePath: "assets/image/img7.jpeg"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
                  backgroundImage: AssetImage(imagePath),
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
                          child: Text("Valider",style: TextStyle(color: Colors.blue),),
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
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rejeté: ${_controller.text}",
                                            style: TextStyle(color: Colors.red))));
                                      },
                                      child: Text("Envoyer",style: TextStyle(color: Colors.blue)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text("Rejeter",style: TextStyle(color: Colors.red)),
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
