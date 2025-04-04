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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2B9BD7),
              surface: Colors.white,
              onSurface: Colors.black,
            ),

          ),
          child: child!,
        );
      },
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tableau de bord",style: TextStyle(color:Colors.black , fontWeight: FontWeight.bold, fontSize: 26),),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(
              context

            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
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
                      const Text("Du", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,)),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20 ,color:Colors.blueAccent),
                              const SizedBox(width: 8),
                              Text(_formatDate(_selectedDate), style: TextStyle(color: Color(0xFF2B9BD7)), ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Au", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20 , color:Colors.blueAccent),
                              const SizedBox(width: 8),
                              Text(_formatDate(_selectedEndDate), style: TextStyle(color: Color(0xFF2B9BD7)),),
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
                count: "$retardCount/$totalJours",
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
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 30),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(icon, color: color, size: 28),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text, style: TextStyle(fontSize: 18)),
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text(
                    count,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPenaltyTile() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 30),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(Icons.money_off, color: Colors.purple, size: 28),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pénalité", style: TextStyle(fontSize: 18)),
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${penaliteMontant.toStringAsFixed(0)} FR",
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}