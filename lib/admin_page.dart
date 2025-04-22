import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String _selectedFilter = 'Tous';
  final List<String> _filterOptions = ['Tous', 'Présents', 'Absents', 'Retards', 'Heures Supp','Pénalité'];
  bool _isLoading = true;
  List<Map<String, dynamic>> _employees = [];
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _supabase
          .from('pointage')
          .select(''' *, user(id,nom,prenom) ''')
          .order('date_heure', ascending: false);

      Logger().i(response);

      _employees = response.map<Map<String, dynamic>>((record) {
        DateTime dateHeure = DateTime.parse(record['date_heure']);
        String date = DateFormat('dd MMMM yyyy', 'fr_FR').format(dateHeure);
        String heureArrivee = record['type'] == 'Arrivee' ? DateFormat('HH:mm').format(dateHeure) : '';
        String heureDepart = record['type'] == 'Départ' ? DateFormat('HH:mm').format(dateHeure) : '';
        final user = record['user'] as Map<String, dynamic>? ?? {};
        final nomComplet = '${user['prenom']} ${user['nom']}';
       String status = _determineStatus(record, dateHeure);
       Logger().d(status);
        String penalty = status == 'Retard' ? _calculatePenalty(heureArrivee) : '';
        String heuresSupp = status == 'Heures Supp' ? _calculateHeuresSupp(heureDepart) : '';

            return {

          'id':record['idemploye'],
          'nom': nomComplet,
          'arrival': heureArrivee,
          'departure': heureDepart,
          'date': date,
          'date_heure': dateHeure,
          'status': status,
          'avatar': Icons.person,
          'lateMotif': record['motif'] ?? record['raison'] ?? '',
          'overtimeMotif': record['motif'] ?? record['raison'] ?? '',
          'validationStatus': record['validation_status'] ?? 'En attente',
          'penalty': penalty,
          'heuresSupp': heuresSupp,
          'absenceMotif': status == 'Absent' ? (record['motif'] ?? record['raison'] ?? '') : null,
          'rejectionReason': record['rejection_reason'],
        };
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Logger().e(e);
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
      return 'Présent';
    } else if (type == 'Départ') {
      DateTime limiteDepart = DateTime(dateHeure.year, dateHeure.month, dateHeure.day, 18, 30);
      if (dateHeure.isAfter(limiteDepart)) {
        return 'Heures Supp';
      }
      return 'Présent';
    } else if (type == 'Absence') {
      return 'Absent';
    }

    return 'Inconnu';
  }

  static String _calculatePenalty(String arrivalTime) {
    final lateMinutes = _calculateLateMinutes(arrivalTime);
    return _calculatePenaltyFromMinutes(lateMinutes);
  }

  static int _calculateLateMinutes(String arrivalTime) {
    if (arrivalTime.isEmpty) return 0;
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
      return '5.000 F (retard de $lateMinutes min)';
    } else if (lateMinutes < 30) {
      return '10.000 F (retard de $lateMinutes min)';
    } else if (lateMinutes < 40) {
      return '15.000 F (retard de $lateMinutes min)';
    } else if (lateMinutes < 50) {
      return '20.000 F (retard de $lateMinutes min)';
    } else if (lateMinutes < 60) {
      return '25.000 F (retard de $lateMinutes min)';
    } else {
      return '30.000 F (retard de $lateMinutes min)';
    }
  }

  String _calculateHeuresSupp(String departure) {
    if (departure.isEmpty) return '';
    final time = departure.split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    final suppMinutes = (hour - 18) * 60 + (minute - 30);
    return '${suppMinutes ~/ 60}h ${suppMinutes % 60}min';
  }

  bool _isLate(String? arrival) {
    if (arrival == null || arrival.isEmpty) return false;
    final time = arrival.split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    return hour > 8 || (hour == 8 && minute > 30);
  }

  bool _isOvertime(String? departure) {
    if (departure == null || departure.isEmpty) return false;
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

  Widget _buildFilterSection() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filterOptions.map((option) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(option),
                  selected: _selectedFilter == option,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? option : 'Tous';
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.blue[800]!.withOpacity(0.2),
                  checkmarkColor: Colors.blue[800],
                  labelStyle: TextStyle(
                    color: _selectedFilter == option ? Colors.blue[800] : Colors.blue,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
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
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filtrer les résultats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _filterController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: 'Rechercher par nom',
                    labelStyle: const TextStyle(color: Color(0xFF000000)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF000000))
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF000000)),
                    ),
                    prefixIcon: const Icon(Icons.search),
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
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                              children: <TextSpan>[
                                if (_selectedDateRange == null)
                                  const TextSpan(text: 'Sélectionner une période'),
                                if (_selectedDateRange != null) ...[
                                  const TextSpan(text: 'Du '),
                                  TextSpan(
                                    text: DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  const TextSpan(text: ' au '),
                                  TextSpan(
                                    text: DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
                            _selectedFilter = 'Tous';
                          });
                        },
                        child: const Text('Annuler', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Appliquer', style: TextStyle(color: Colors.black)),
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
      bool matchesStatus = true;

      switch (_selectedFilter) {
        case 'Présents':
          matchesStatus = emp['status'] == 'Présent';
          break;
        case 'Absents':
          matchesStatus = emp['status'] == 'Absent';
          break;
        case 'Retards':
          matchesStatus = emp['status'].contains('Retard');
          break;
        case 'Heures Supp':
          matchesStatus = emp['status'].contains('Heures Supp');
          break;
        case 'Pénalité':
          matchesStatus = _isLate(emp['arrival']);
          break;
      }

      final nameMatch = _searchQuery.isEmpty ||
          emp['nom'].toLowerCase().contains(_searchQuery.toLowerCase());

      bool dateMatch = true;
      if (_selectedDateRange != null) {
        final empDate = DateFormat('dd MMMM yyyy', 'fr_FR').parse(emp['date']);
        dateMatch = empDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            empDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }

      return matchesStatus && nameMatch && dateMatch;
    }).toList();
  }

  void _showAddAbsenceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
          backgroundColor: Colors.white,
          title: Text('Validation ${employee['nom']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAbsent) ...[
                  const Text('DÉTAILS ABSENCE',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Text('Date: ${employee['date']}'),
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
                  Text('Arrivé à ${employee['arrival']} (Normal: 08:30)'),
                  Text('Retard: $lateMinutes min'),
                  Text('Sanction: ${_calculatePenaltyFromMinutes(lateMinutes)}',
                      style: const TextStyle(
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
                  Text('Heures supplémentaires: ${employee['heuresSupp']}'),
                  const SizedBox(height: 10),
                  const Text('Motif fourni:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(employee['overtimeMotif'] ?? employee['motif'] ?? 'Aucun motif fourni',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                  const Divider(height: 30),
                ],
                if (employee['validationStatus'] == 'En attente') ...[
                  const Text('Commentaire :',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  TextField(
                    controller: _rejectionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Motif du rejet',
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
                  updateStatus(
                    employeeId: employee['id'].toString(),
                    newStatus: 'Rejeté',
                  );
                  Navigator.pop(context);
                },
                child: const Text('REJETER', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  updateStatus(
                    employeeId: employee['id'].toString(),
                    newStatus: 'Validé',
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('VALIDER', style: TextStyle(color: Colors.black)),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('FERMER', style: TextStyle(color: Colors.black)),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> updateStatus({
    required String employeeId,
    required String newStatus,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      Logger().i(employeeId);

      // Requête pour mettre à jour le statut dans la table pointage
      await supabase
          .from('pointage')
          .update({
        'statut': newStatus,
       // 'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('idemploye', employeeId);


      Logger().i('Statut employé $employeeId mis à jour: $newStatus');

    } catch (e) {
      Logger().e('Erreur mise à jour statut employé: $e');
      throw Exception('Erreur lors de la mise à jour du statut');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tableau de bord Admin'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildFilterSection(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = filteredEmployees[index];
                  final hasLate = _isLate(employee['arrival']);
                  final hasOvertime = _isOvertime(employee['departure']);
                  final isAbsent = _isAbsent(employee);
                  final lateMinutes = hasLate ? _calculateLateMinutes(employee['arrival']) : 0;
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.all(5),
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(employee['avatar'], color: Colors.blue)),
                      title: Text(employee['nom'], style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Statut: ${employee['status']}', style: const TextStyle(
                              color: Colors.black)),
                          Text('Date: ${employee['date']}', style: const TextStyle(
                              color: Colors.black)),
                          if (hasLate && _selectedIndex != 4)
                            Text('Retard: $lateMinutes min', style: const TextStyle(
                                color: Colors.black)),
                          if (hasLate && _selectedIndex == 4)
                            Text('Pénalité: ${_calculatePenaltyFromMinutes(lateMinutes)}',
                                style: const TextStyle(
                                    color: Colors.black)),
                          if (hasOvertime)
                            Text('Heures supp: ${employee['heuresSupp']}', style: const TextStyle(
                                color: Colors.black)),
                          if (isAbsent && employee['absenceMotif'] != null)
                            Text('Motif: ${employee['absenceMotif']}',
                                style: const TextStyle(fontStyle: FontStyle.italic)),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'Validé':
        return const Chip(
          label: Text('Validé'),
          backgroundColor: Color(0xFF2B9BD7),
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
          backgroundColor: Colors.grey,
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