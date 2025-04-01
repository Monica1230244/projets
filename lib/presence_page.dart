import 'package:flutter/material.dart';
import 'package:projets/absence_page.dart';
import 'package:projets/retard_page.dart';

class PresencePage extends StatefulWidget {
  @override
  _PresencePageState createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  int _selectedIndex = 0;
  String _selectedFilter = 'Tous';
  bool _showOnlyProblems = false;

  final List<String> _filterOptions = ['Tous', 'Présents', 'Absents', 'Retards'];

  final List<Map<String, dynamic>> _allPresences = [
    {'date': '02 Mars 2023', 'heure_arrivee': '08:15', 'heure_depart': '17:30', 'status': 'Présent', 'color': Colors.green, 'hasProblem': false},
    {'date': '03 Mars 2023', 'heure_arrivee': '09:05', 'heure_depart': '17:45', 'status': 'Retard (35min)', 'color': Colors.orange, 'hasProblem': true},
    {'date': '04 Mars 2023', 'heure_arrivee': '-', 'heure_depart': '-', 'status': 'Absent', 'color': Colors.red, 'hasProblem': true},
    {'date': '05 Mars 2023', 'heure_arrivee': '08:00', 'heure_depart': '18:15', 'status': 'Présent', 'color': Colors.green, 'hasProblem': false},
  ];

  List<Map<String, dynamic>> get _filteredPresences {
    return _allPresences.where((presence) {
      bool matchesStatus = true;
      bool matchesProblemFilter = !_showOnlyProblems || presence['hasProblem'];

      switch (_selectedFilter) {
        case 'Présents': matchesStatus = presence['status'] == 'Présent'; break;
        case 'Absents': matchesStatus = presence['status'] == 'Absent'; break;
        case 'Retards': matchesStatus = presence['status'].contains('Retard'); break;
      }

      return matchesStatus && matchesProblemFilter;
    }).toList();
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
        title: Text("Suivie de Présence", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF003366),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

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
              // Section Filtres (sans sélection de date)
              _buildFilterSection(),
              SizedBox(height: 20),

              // Liste des cartes statiques (non défilantes)
              _buildStatCardsRow(),
              SizedBox(height: 20),

              // Liste des présences
              Expanded(
                child: _buildPresenceList(),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildStatCardsRow() {
    final presentCount = _filteredPresences.where((p) => p['status'] == 'Présent').length;
    final absentCount = _filteredPresences.where((p) => p['status'] == 'Absent').length;
    final lateCount = _filteredPresences.where((p) => p['status'].contains('Retard')).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard("Présence", "$presentCount", Icons.check_circle, Colors.green),
        _buildStatCard("Absence", "$absentCount", Icons.cancel, Colors.red, isClickable: true),
        _buildStatCard("Retard", "$lateCount", Icons.timer, Colors.orange, isClickable: true),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isClickable = false}) {
    final card = Container(
      width: 110,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(45),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 2)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            radius: 20,
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );

    if (!isClickable) return card;

    return InkWell(
      borderRadius: BorderRadius.circular(45),
      onTap: () {
        if (title == "Absence") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AbsencePage()));
        } else if (title == "Retard") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RetardPage()));
        }
      },
      child: card,
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((option) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(option),
                    selected: _selectedFilter == option,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? option : 'Tous';
                      });
                    },
                    selectedColor: Color(0xFF003366).withOpacity(0.2),
                    checkmarkColor: Color(0xFF003366),
                    labelStyle: TextStyle(
                      color: _selectedFilter == option ? Color(0xFF003366) : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPresenceList() {
    if (_filteredPresences.isEmpty) {
      return Center(child: Text('Aucune donnée correspondant aux filtres'));
    }

    return ListView.builder(
      itemCount: _filteredPresences.length,
      itemBuilder: (context, index) {
        final presence = _filteredPresences[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 60,
                  decoration: BoxDecoration(
                    color: presence['color'],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(presence['date'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Arrivée: ${presence['heure_arrivee']}'),
                          SizedBox(width: 20),
                          Text('Départ: ${presence['heure_depart']}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Chip(
                  backgroundColor: presence['color'].withOpacity(0.2),
                  label: Text(presence['status'], style: TextStyle(color: presence['color'])),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}