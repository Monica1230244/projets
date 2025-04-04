import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:projets/absence_page.dart';
import 'package:projets/heure_supp.dart';
import 'package:projets/presence_page.dart';
import 'package:projets/retard_page.dart';
import 'accueil_page.dart';
import 'constants.dart';

class Presence extends StatefulWidget {
  const Presence({Key? key}) : super(key: key);

  @override
  _PresenceState createState() => _PresenceState();
}

class _PresenceState extends State<Presence> {
  late DateTime _selectedDate;
  late DateTime _selectedEndDate;

  // Valeurs simulées
  int presenceCount = 12;
  int totalJours = 30;
  int absenceCount = 3;
  int retardCount = 2;
  int heuresSuppCount = 5;
  double penaliteMontant = 1500.0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _selectedDate = DateTime.now();
    _selectedEndDate = DateTime.now().add(const Duration(days: 30));
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _selectedDate : _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _selectedDate = pickedDate;
          if (_selectedEndDate.isBefore(pickedDate)) {
            _selectedEndDate = pickedDate.add(const Duration(days: 30));
            totalJours = 30;
          }
        } else {
          _selectedEndDate = pickedDate;
          totalJours = _selectedEndDate.difference(_selectedDate).inDays + 1;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suivi de Présence"),
        centerTitle: true,
        backgroundColor: primaryColor,
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text("Du", style: TextStyle(color: Colors.black)),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(_formatDate(_selectedDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Au", style: TextStyle(color: Colors.black)),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(_formatDate(_selectedEndDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),


              _buildOptionTile(
                icon: Icons.check_circle,
                color: Colors.green,
                text: "Présence",
                count: "$presenceCount/$totalJours",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PresencePage()),
                ),
              ),
              _buildOptionTile(
                icon: Icons.cancel,
                color: Colors.red,
                text: "Absence",
                count: "$absenceCount/$totalJours",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AbsencePage()),
                ),
              ),
              _buildOptionTile(
                icon: Icons.timer,
                color: Colors.orange,
                text: "Retard",
                count: "$retardCount",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RetardPage()),
                ),
              ),
              _buildOptionTile(
                icon: Icons.access_time,
                color: Colors.blue,
                text: "Heures Supp",
                count: "$heuresSuppCount h",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HeuresSupplementairesPage()),
                ),
              ),
              _buildPenaltyTile(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color color,
    required String text,
    required String count,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 50),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(text),
        trailing: Chip(
          label: Text(
            count,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: color.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPenaltyTile() {
    return Card(
      margin: const EdgeInsets.only(bottom: 50),
      child: ListTile(
        leading: Icon(Icons.money_off, color: Colors.purple),
        title: Text("Pénalité"),
        trailing: Chip(
          label: Text(
            "${penaliteMontant.toStringAsFixed(0)} DA",
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.purple.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}