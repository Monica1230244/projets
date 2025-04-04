import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  final TextEditingController _filterController = TextEditingController();
  final TextEditingController _rejectionController = TextEditingController();
  final TextEditingController _absenceMotifController = TextEditingController();

  final List<Map<String, dynamic>> _employees = [

    {
      'name': 'Jean ',
      'arrival': '08:00',
      'departure': '18:30',
      'date': DateTime(2025, 4, 2),
      'status': 'Présent',
      'avatar': Icons.person,
    },


    {
      'name': 'Miriam',
      'arrival': '08:15',
      'departure': '18:30',
      'date': DateTime(2025, 4, 2),
      'status': 'Présent',
      'avatar': Icons.person,
    },


    {
      'name': 'Monica',
      'arrival': '07:00',
      'departure': '18:30',
      'date': DateTime(2025, 4, 2),
      'status': 'Présent',
      'avatar': Icons.person,
    },

    {
      'name': 'Marie ',
      'arrival': '08:45',
      'departure': '18:30',
      'date': DateTime(2025, 4, 2),
      'status': 'Retard',
      'lateMotif': 'Problème de transport',
      'validationStatus': 'En attente',
      'penalty': _calculatePenalty('08:45'),
      'avatar': Icons.person,
    },

    {
      'name': 'Prince',
      'arrival': '08:00',
      'departure': '19:45',
      'date': DateTime(2025, 4, 2),
      'status': 'Heure Supp',
      'overtimeMotif': 'Dossier urgent à terminer',
      'validationStatus': 'En attente',
      'avatar': Icons.engineering,
    },

    {
      'name': 'Karel',
      'arrival': '09:15',
      'departure': '18:30',
      'date': DateTime(2025, 4, 2),
      'status': 'Retard' ,
      'lateMotif': 'Réveil tardif',
      'validationStatus': 'En attente',
      'penalty': _calculatePenalty('09:15'),
      'avatar': Icons.person,
    },

    {
      'name': 'Adna',
      'arrival': '09:00',
      'departure': '18:30',
      'date': DateTime(2025, 4, 2),
      'status': 'Retard',
      'lateMotif': 'Problème de voiture',
      'validationStatus': 'En attente',
      'penalty': _calculatePenalty('09:00'),
      'avatar': Icons.person,
    },
    // Cas 6: Arrivé en retard (75 min)
    {
      'name': 'Prude',
      'arrival': '09:45',
      'departure': '18:30',
      'date': DateTime(2025, 4, 2),
      'status': 'Retard',
      'lateMotif': 'Problème familial',
      'validationStatus': 'En attente',
      'penalty': _calculatePenalty('09:45'),
      'avatar': Icons.person,
    },

    {
      'name': 'Ruth',
      'arrival': '08:39',
      'departure': '20:30',
      'date': DateTime(2025, 4, 2),
      'status': 'Retard & Heure Supp',
      'lateMotif': 'Petit retard',
      'overtimeMotif': 'Dossier urgent à terminer',
      'validationStatus': 'En attente',
      'penalty': _calculatePenalty('08:39'),
      'avatar': Icons.person,
    },

    {
      'name': 'Azaria',
      'arrival': '08:20',
      'departure': '18:30',
      'date': DateTime(2025, 4, 2),
      'status': 'Présent',
      'avatar': Icons.person,
    },

    {
      'name': 'Charbel',
      'date': DateTime(2025, 4, 2),
      'status': 'Absent',
      'validationStatus': 'En attente',
      'absenceMotif': null,
      'avatar': Icons.person,
    },

    {
      'name': 'Hamid',
      'date': DateTime(2025, 4, 2),
      'status': 'Absent',
      'validationStatus': 'En attente',
      'absenceMotif': 'Maladie (certificat médical fourni)',
      'avatar': Icons.person,
    },
  ];

  static String _calculatePenalty(String arrivalTime) {
    final lateMinutes = _calculateLateMinutes(arrivalTime);
    return _calculatePenaltyFromMinutes(lateMinutes);
  }

  static int _calculateLateMinutes(String arrivalTime) {
    final parts = arrivalTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return (hour - 8) * 60 + (minute - 30);
  }

  static String _calculatePenaltyFromMinutes(int lateMinutes) {
    if (lateMinutes <= 0) {
      return 'Aucune sanction';
    } else if (lateMinutes < 10) {
      return 'Avertissement (retard de $lateMinutes min)';
    } else if (lateMinutes < 20) {
      return '5000 F (retard de $lateMinutes min)';
    } else if (lateMinutes < 30) {
      return '10000 F (retard de $lateMinutes min)';
    } else if (lateMinutes < 40) {
      return '15000 F (retard de $lateMinutes min)';
    } else if (lateMinutes < 50) {
      return '20000 F (retard de $lateMinutes min)';
    } else if (lateMinutes < 60) {
      return '25000 F (retard de $lateMinutes min)';
    } else {
      return '30000 F (retard de $lateMinutes min)';
    }
  }

  String _calculateHeuresSupp(String departure) {
    final time = departure.split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    final suppMinutes = (hour - 18) * 60 + (minute - 30);
    return '${suppMinutes ~/ 60}h ${suppMinutes % 60}min';
  }

  bool _isLate(String? arrival) {
    if (arrival == null) return false;
    final time = arrival.split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    return hour > 8 || (hour == 8 && minute > 30);
  }

  bool _isOvertime(String? departure) {
    if (departure == null) return false;
    final time = departure.split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    return hour > 18 || (hour == 18 && minute > 30);
  }

  bool _isAbsent(Map<String, dynamic> employee) {
    return employee['status'] == 'Absent';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _searchQuery = '';
      _selectedDateRange = null;
    });
  }

  Future<void> _showFilterDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filtrer les résultats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Champ de recherche par nom
                TextField(
                  controller: _filterController,
                  decoration: const InputDecoration(
                    labelText: 'Rechercher par nom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 15),


                InkWell(
                  onTap: () async {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      initialDateRange: _selectedDateRange,
                      locale: const Locale('fr', 'FR'),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDateRange = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          _selectedDateRange == null
                              ? 'Sélectionner une période'
                              : 'Du ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} au '
                              '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),


                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _filterController.clear();
                          setState(() {
                            _searchQuery = '';
                            _selectedDateRange = null;
                          });
                        },
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Appliquer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  List<Map<String, dynamic>> get filteredEmployees {
    return _employees.where((emp) {

      final nameMatch = _searchQuery.isEmpty ||
          emp['name'].toLowerCase().contains(_searchQuery.toLowerCase());


      bool dateMatch = true;
      if (_selectedDateRange != null) {
        dateMatch = emp['date'].isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            emp['date'].isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }

      return nameMatch && dateMatch;
    }).toList();
  }


  void _showAddAbsenceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une absence'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _absenceMotifController,
                  decoration: const InputDecoration(
                    labelText: 'Motif de l\'absence',
                    border: OutlineInputBorder(),
                    hintText: 'Maladie, congé, etc.',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _showValidationDialog(Map<String, dynamic> employee) {
    final hasLate = _isLate(employee['arrival']);
    final hasOvertime = _isOvertime(employee['departure']);
    final isAbsent = _isAbsent(employee);
    final lateMinutes = hasLate ? _calculateLateMinutes(employee['arrival']) : 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Validation ${employee['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAbsent) ...[
                  const Text('DÉTAILS ABSENCE',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Text('Date: ${DateFormat('dd/MM/yyyy').format(employee['date'])}'),
                  const SizedBox(height: 10),
                  const Text('Motif fourni:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(employee['absenceMotif'] ?? 'Aucun motif fourni',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                  const Divider(height: 30),
                ],
                if (hasLate) ...[
                  const Text('DÉTAILS RETARD',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Text('Arrivé à ${employee['arrival']} (Normale: 08:30)'),
                  Text('Retard: $lateMinutes min'),
                  Text('Sanction: ${_calculatePenaltyFromMinutes(lateMinutes)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 16)),
                  const SizedBox(height: 10),
                  const Text('Motif fourni:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(employee['lateMotif'] ?? employee['motif'] ?? 'Aucun motif fourni',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                  const Divider(height: 30),
                ],
                if (hasOvertime) ...[
                  const Text('DÉTAILS HEURES SUPP',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  Text('Départ à ${employee['departure']} (Normale: 18:30)'),
                  Text('Heures supplémentaires: ${_calculateHeuresSupp(employee['departure'])}'),
                  const SizedBox(height: 10),
                  const Text('Motif fourni:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(employee['overtimeMotif'] ?? employee['motif'] ?? 'Aucun motif fourni',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                  const Divider(height: 30),
                ],
                if (employee['validationStatus'] == 'En attente') ...[
                  const Text('ACTION ADMINISTRATEUR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Commentaire (obligatoire si rejet):',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  TextField(
                    controller: _rejectionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Motif du rejet...',
                    ),
                    maxLines: 3,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (employee['validationStatus'] == 'En attente') ...[
              TextButton(
                onPressed: () {
                  if (_rejectionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez saisir un motif de rejet')));
                    return;
                  }
                  _updateStatus(employee, 'Rejeté', _rejectionController.text);
                  Navigator.pop(context);
                },
                child: const Text('REJETER', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateStatus(employee, 'Validé', '');
                  Navigator.pop(context);
                },
                child: const Text('VALIDER'),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('FERMER'),
              ),
            ],
          ],
        );
      },
    );
  }

  void _updateStatus(Map<String, dynamic> employee, String status, String reason) {
    setState(() {
      employee['validationStatus'] = status;
      if (status == 'Rejeté') {
        employee['rejectionReason'] = reason.isNotEmpty ? reason : 'Non spécifié';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tableau de bord Admin'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
        ),
        actions: [

          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Présence'),
          BottomNavigationBarItem(icon: Icon(Icons.person_off), label: 'Absence'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Retard'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Heure supp'),
          BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'Pénalité'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCurrentTab() {
    final filteredEmployees = _employees.where((emp) {
      bool statusMatch = false;
      final hasLate = _isLate(emp['arrival']);
      final hasOvertime = _isOvertime(emp['departure']);
      final isAbsent = _isAbsent(emp);

      switch (_selectedIndex) {
        case 0:
          statusMatch = !hasLate && !hasOvertime && !isAbsent;
          break;
        case 1:
          statusMatch = isAbsent;
          break;
        case 2:
          statusMatch = hasLate;
          break;
        case 3:
          statusMatch = hasOvertime;
          break;
        case 4:
          statusMatch = hasLate;
          break;
      }

      final nameMatch = _searchQuery.isEmpty ||
          emp['name'].toLowerCase().contains(_searchQuery.toLowerCase());

      bool dateMatch = true;
      if (_selectedDateRange != null) {
        dateMatch = emp['date'].isAfter(_selectedDateRange!.start) &&
            emp['date'].isBefore(_selectedDateRange!.end);
      }

      return statusMatch && nameMatch && dateMatch;
    }).toList();

    return ListView.builder(
      itemCount: filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = filteredEmployees[index];
        final hasLate = _isLate(employee['arrival']);
        final hasOvertime = _isOvertime(employee['departure']);
        final isAbsent = _isAbsent(employee);
        final lateMinutes = hasLate ? _calculateLateMinutes(employee['arrival']) : 0;

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(child: Icon(employee['avatar'])),
            title: Text(employee['name'], style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statut: ${employee['status']}', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
                Text('Date: ${DateFormat('dd/MM/yyyy').format(employee['date'])}', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
                if (hasLate && _selectedIndex != 4)
                  Text('Retard: $lateMinutes min', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
                if (hasLate && _selectedIndex == 4)
                  Text('Pénalité: ${_calculatePenaltyFromMinutes(lateMinutes)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                if (hasOvertime)
                  Text('Heures supp: ${_calculateHeuresSupp(employee['departure'])}', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
                if (isAbsent && employee['absenceMotif'] != null)
                  Text('Motif: ${employee['absenceMotif']}',
                      style: const TextStyle(fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: (hasLate || hasOvertime || isAbsent)
                ? _buildStatusBadge(employee['validationStatus'])
                : null,
            onTap: () {
              if (hasLate || hasOvertime || isAbsent) {
                _showValidationDialog(employee);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'Validé':
        return const Chip(
          label: Text('Validé'),
          backgroundColor: Colors.green,
          labelStyle: TextStyle(color: Colors.white),
        );
      case 'Rejeté':
        return const Chip(
          label: Text('Rejeté'),
          backgroundColor: Colors.red,
          labelStyle: TextStyle(color: Colors.white),
        );
      default:
        return const Chip(
          label: Text('En attente'),
          backgroundColor: Colors.orange,
          labelStyle: TextStyle(color: Colors.white),
        );
    }
  }

  @override
  void dispose() {
    _filterController.dispose();
    _rejectionController.dispose();
    _absenceMotifController.dispose();
    super.dispose();
  }
}