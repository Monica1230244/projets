import 'package:flutter/material.dart';

class Presence extends StatefulWidget {
  @override
  _PresenceState createState() => _PresenceState();
}

class _PresenceState extends State<Presence> {
  DateTime? _selectedDate;
  DateTime? _selectedEndDate;
  int _selectedIndex = 0;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _selectedDate ?? DateTime.now() : _selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _selectedDate = pickedDate;
          _selectedEndDate = DateTime(pickedDate.year, pickedDate.month + 1, 0);
        } else {
          _selectedEndDate = pickedDate;
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Suivie de Présence", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: Color(0xFF003366),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, size: 35, color: Colors.white),
          ),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 10,
        selectedItemColor: Color(0xFF003366),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.save, size: 30), label: ''),
          BottomNavigationBarItem( icon: Icon(Icons.file_download_sharp, size: 30), label: ''),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildDateSelection(),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildStatCard("Présence", "22 / 30", Icons.check_circle, Colors.green),
                    SizedBox(height: 33),
                    _buildStatCard("Absence", "8 / 30", Icons.cancel, Colors.grey),
                    SizedBox(height: 33),
                    _buildStatCard("Retard", "13 min", Icons.timer, Colors.brown),
                    SizedBox(height: 33),
                    _buildStatCard("Pénalité", "5.000 FCFA", Icons.money_off, Colors.black),
                    SizedBox(height: 33),
                    _buildStatCard("Heures Supp", "19 min", Icons.access_time, Colors.teal, isLarge: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Du", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.black)),
        SizedBox(width: 10),
        _datePickerButton("Du", _selectedDate, () => _selectDate(context, true), style: TextStyle(color:Colors.black)),
        SizedBox(width: 10),
        Text("Au", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.black)),
        SizedBox(width: 10),
        _datePickerButton("Au", _selectedEndDate, () => _selectDate(context, false), style: TextStyle(color:Colors.black)),
      ],
    );
  }

  Widget _datePickerButton(String label, DateTime? date, VoidCallback onTap, {required TextStyle style}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF003366), size: 25),
            SizedBox(width: 10),
            Text(
              date == null ? "Date" : "${date.day}/${date.month}/${date.year}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(45),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 2)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            radius: 25,
            child: Icon(icon, color: iconColor, size: 30),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            ],
          ),
        ],
      ),
    );
  }
}
