import 'package:flutter/material.dart';
import 'package:projets/constants.dart';

class PresencePage extends StatefulWidget {
  @override
  _PresencePageState createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  int _selectedIndex = 0;
  String _selectedFilter = 'Tous';

  final List<String> _filterOptions = ['Tous', 'Présents', 'Absents', 'Retards', 'Heures Supp'];

  final List<Map<String, dynamic>> _allPresences = [
    {'date': '02 Mars 2025', 'heure_arrivee': '08:15', 'heure_depart': '17:30', 'status': 'Présent', 'color': Colors.green, 'hasProblem': false},
    {'date': '03 Mars 2025', 'heure_arrivee': '09:05', 'heure_depart': '17:45', 'status': 'Retard ', 'color': Colors.orange, 'hasProblem': true},
    {'date': '04 Mars 2025', 'heure_arrivee': '-', 'heure_depart': '-', 'status': 'Absent', 'color': Colors.red, 'hasProblem': true},
    {'date': '05 Mars 2025', 'heure_arrivee': '08:00', 'heure_depart': '18:15', 'status': 'Présent', 'color': Colors.green, 'hasProblem': false},
    {'date': '06 Mars 2025', 'heure_arrivee': '08:00', 'heure_depart': '19:30', 'status': 'Heures Supp ', 'color': Colors.blue, 'hasProblem': false},
    {'date': '07 Mars 2025', 'heure_arrivee': '-', 'heure_depart': '-', 'status': 'Absent', 'color':  Colors.red, 'hasProblem': true},
    {'date': '08 Mars 2025', 'heure_arrivee': '9:30', 'heure_depart': '19:00', 'status': 'Retard', 'color': Colors.orange, 'hasProblem': false},
    {'date': '07 Mars 2025', 'heure_arrivee': '-', 'heure_depart': '-', 'status': 'Absent', 'color':  Colors.red, 'hasProblem': true},
    {'date': '08 Mars 2025', 'heure_arrivee': '9:30', 'heure_depart': '19:00', 'status': 'Retard', 'color': Colors.orange, 'hasProblem': false},
    {'date': '08 Mars 2025', 'heure_arrivee': '9:30', 'heure_depart': '19:00', 'status': 'Retard', 'color': Colors.orange, 'hasProblem': false},
    {'date': '08 Mars 2025', 'heure_arrivee': '9:30', 'heure_depart': '19:00', 'status': 'Retard', 'color': Colors.orange, 'hasProblem': false},
    {'date': '02 Mars 2025', 'heure_arrivee': '08:15', 'heure_depart': '17:30', 'status': 'Présent', 'color': Colors.green, 'hasProblem': false},
    {'date': '06 Mars 2025', 'heure_arrivee': '08:00', 'heure_depart': '19:30', 'status': 'Heures Supp ', 'color': Colors.blue, 'hasProblem': false},
    {'date': '06 Mars 2025', 'heure_arrivee': '08:00', 'heure_depart': '19:30', 'status': 'Heures Supp ', 'color': Colors.blue, 'hasProblem': false},
  ];

  List<Map<String, dynamic>> get _filteredPresences {
    return _allPresences.where((presence) {
      bool matchesStatus = true;


      switch (_selectedFilter) {
        case 'Présents':
          matchesStatus = presence['status'] == 'Présent';
          break;
        case 'Absents':
          matchesStatus = presence['status'] == 'Absent';
          break;
        case 'Retards':
          matchesStatus = presence['status'].contains('Retard');
          break;
        case 'Heures Supp':
          matchesStatus = presence['status'].contains('Heures Supp');
          break;
      }

      return matchesStatus;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Suivie de Présence", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildFilterSection(),
              SizedBox(height: 20),
              Expanded(
                child: _buildPresenceList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
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
                  backgroundColor: Colors.white,
                  selectedColor: primaryColor.withOpacity(0.2),
                  checkmarkColor: primaryColor,
                  labelStyle: TextStyle(
                    color: _selectedFilter == option ? primaryColor : Color(0xFF2B9BD7),
                  ),

              side: BorderSide(
              color: _selectedFilter == option ? primaryColor : Colors.black,
              width: 1,
              ),
                )
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 10),
      ],
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

        final statusText = presence['status'].contains('Retard')
            ? 'Retard'
            : presence['status'].contains('Heures Supp')
            ? 'Heures Supp'
            : presence['status'];

        return Card(
          color: Colors.white,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 80,
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
                  labelPadding: EdgeInsets.symmetric(horizontal: 1),
                  backgroundColor: presence['color'].withOpacity(0.2),
                  label: Text(statusText, style: TextStyle(color: presence['color'])),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}