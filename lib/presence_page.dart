import 'package:flutter/material.dart';
import 'package:projets/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:projets/utilisateur.dart';
import 'package:intl/intl.dart';

class PresencePage extends StatefulWidget {
  @override
  _PresencePageState createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  int _selectedIndex = 0;
  String _selectedFilter = 'Tous';
  bool _isLoading = true;

  List<Map<String, dynamic>> _allPresences = [];

  final List<String> _filterOptions = ['Tous', 'Arrivées', 'Départs', 'Retards', 'Heures Supp'];

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchPresenceData();
  }

  Future<void> _fetchPresenceData() async {
    try {
      setState(() {
        _isLoading = true;

      });

      // Récupérer l'utilisateur depuis Hive
      final authBox = Hive.box('authBox');
      Users user = authBox.get('stocker_user');

      if (user == null || user.id == null) {
        throw Exception('Utilisateur non trouvé');
      }

      // Récupérer les données de pointage
      final response = await _supabase
          .from('pointage')
          .select()
          .order('date_heure', ascending: false);

      // Transformer les données en format approprié
      _allPresences = response.map<Map<String, dynamic>>((record) {
        DateTime dateHeure = DateTime.parse(record['date_heure']);
        String date = DateFormat('dd MMMM yyyy', 'fr_FR').format(dateHeure);
        String heure = DateFormat('HH:mm').format(dateHeure);

        String status = _determineStatus(record, dateHeure);
        Color color = _getStatusColor(status);
        String type = record['type'] ?? 'Inconnu';

        return {
          'date': date,
          'heure': heure,
          'type': type,
          'status': status,
          'color': color,
          'motif': record['motif'] ?? record['raison'] ?? '',
          'hasProblem': status != 'À l\'heure',
        };
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des données: $e')),
      );
    }
  }

  String _determineStatus(Map<String, dynamic> record, DateTime dateHeure) {
    String type = record['type'] ?? '';

    if (type == 'Arrivee') {
      DateTime limiteArrivee = DateTime(dateHeure.year, dateHeure.month, dateHeure.day, 8, 30);
      if (dateHeure.isAfter(limiteArrivee)) {
        return 'Retard';
      }
      return 'À l\'heure';
    } else if (type == 'Départ') {
      DateTime limiteDepart = DateTime(dateHeure.year, dateHeure.month, dateHeure.day, 18, 30);
      if (dateHeure.isAfter(limiteDepart)) {
        return 'Heures Supp';
      }
      return 'Départ ';
    }

    return 'Inconnu';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'À l\'heure':
        return Colors.green;
      case 'Retard':
        return Colors.orange;
      case 'Heures Supp':
        return Colors.blue;
      case 'Départ ':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get _filteredPresences {
    return _allPresences.where((presence) {
      bool matchesStatus = true;

      switch (_selectedFilter) {
        case 'Arrivées':
          matchesStatus = presence['type'] == 'Arrivee';
          break;
        case 'Départs':
          matchesStatus = presence['type'] == 'Départ';
          break;
        case 'Retards':
          matchesStatus = presence['status'] == 'Retard';
          break;
        case 'Heures Supp':
          matchesStatus = presence['status'] == 'Heures Supp';
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
        title: Text("Suivi de Présence", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ))
                    : _buildPresenceList(),
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
                      Text('${presence['type']} à ${presence['heure']}', style: TextStyle(fontSize: 14)),
                      if (presence['motif'].isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Motif: ${presence['motif']}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                    ],
                  ),
                ),
                Chip(
                  labelPadding: EdgeInsets.symmetric(horizontal: 1),
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