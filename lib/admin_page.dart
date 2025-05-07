import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:projets/utilisateur.dart';
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
  final List<String> _filterOptions = ['Tous', 'Arrivée','Départ', 'Absents', 'Retards', 'Heures Supp','Pénalité'];
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
        String heureArrivee = '';
        String heureDepart = '';
        if (record['type'] == 'Arrivee') {
          heureArrivee = DateFormat("HH 'h' mm").format(dateHeure);
        } else if (record['type'] == 'Départ') {
          heureDepart = DateFormat("HH 'h' mm").format(dateHeure);
        }

        final user = record['user'] as Map<String, dynamic>? ?? {};
        final nomComplet = '${user['prenom']} ${user['nom']}';

        // Détermination du statut (présence à l'heure, retard, ou heures supplémentaires)
        String type = _determineStatus(record, dateHeure);

        // Calcul des heures supplémentaires si l'employé est en mode heures supplémentaires
        String heuresSupp = '';
        if (type == 'Heures Supp') {
          heuresSupp = _calculateHeuresSupp(heureDepart);
        }

        // Motif de retard
        String lateMotif = record['motif'] ?? record['raison'] ?? '';

        return {
          'id': record['idemploye'],
          'idpointage': record['id'],
          'nom': nomComplet,
          'arrival': heureArrivee,
          'departure': heureDepart,
          'date': date,
          'date_heure': dateHeure,
          'type': type,
          'avatar': Icons.person,
          'heuresSupp': heuresSupp,
          'overtimeMotif': record['raison'] ?? '',
          'lateMotif': lateMotif,
          'statut': record['statut'],
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
        return 'Arrivée';
      }
      return 'Arrivée';
    } else if (type == 'Départ') {
      DateTime limiteDepart = DateTime(dateHeure.year, dateHeure.month, dateHeure.day, 18, 30);
      if (dateHeure.isAfter(limiteDepart)) {
        return 'Heures Supp';
      }
      return 'Départ';
    } else if (type == 'Absence') {
      return 'Absent';
    }

    return 'Inconnu';
  }

  String formatMinutesToHours(int totalMinutes) {
    if (totalMinutes <= 0) return "0h00mn";
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return "$hours h ${minutes.toString().padLeft(2, '0')} mn";
  }
  
  static int _calculateLateMinutes(String arrivalTime) {
    if (arrivalTime.isEmpty) return 0;
    final parts = arrivalTime.split('h');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final lateMinutes= (hour - 8) * 60 + (minute - 30);
    return lateMinutes;
  }

  int calculerPenalite(int lateMinutes) {
//Logger().i(lateMinutes);
    int penaliteTotale = (lateMinutes ~/ 10) * 5000;  // Calcul de la pénalité totale
    return penaliteTotale;
  }


  String _calculateHeuresSupp(String departure) {
    if (departure.isEmpty) return '';
    try {
      final cleanedTime = departure.replaceAll(' ', ''); // Enlever les espaces
      final timeParts = cleanedTime.split('h');
      if (timeParts.length != 2) return '';

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final referenceHour = 18;
      final referenceMinute = 30;

      final totalReference = referenceHour * 60 + referenceMinute;
      final totalActual = hour * 60 + minute;

      if (totalActual <= totalReference) return '';

      final diffMinutes = totalActual - totalReference;
      return '${diffMinutes ~/ 60}h ${(diffMinutes % 60).toString().padLeft(2, '0')}mn';
    } catch (e) {
      Logger().e("Erreur calcul heures supp: $e");
      return '';
    }
  }
  bool _isLate(String? arrival) {
    if (arrival == null || arrival.isEmpty) return false;
    final time = arrival.split('h');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    return hour > 8 || (hour == 8 && minute > 30);
  }

  bool _isOvertime(String? departure) {
    if (departure == null || departure.isEmpty) return false;
    final time = departure.split('h');
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

  Future<List<Map<String, dynamic>>> get filteredEmployees async {
    if (_selectedFilter == 'Absents') {
      // Appeler la méthode pour récupérer les absences de tous les utilisateurs
      return await _getAllAbsences();
    }

    var filtered = _employees.where((emp) {
      bool matchesStatus = true;

      switch (_selectedFilter) {
        case 'Arrivée':
          matchesStatus = emp['type'] == 'Arrivée';
          break;
        case 'Départ':
          matchesStatus = emp['type'] == 'Départ';
          break;
        case 'Retards':
          matchesStatus = _isLate(emp['arrival']);
          break;
        case 'Heures Supp':
          matchesStatus = emp['type'].contains('Heures Supp');
          break;
        case 'Pénalité':
          matchesStatus = _isLate(emp['arrival']);
          break;
        case 'Absents':

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

    // Calcul des pénalités totales par personne
    if (_selectedFilter == 'Pénalité') {
      final Map<String, Map<String, dynamic>> employeePenalties = {};

      for (var emp in filtered) {
        final String employeeId = emp['id'].toString();
        final int lateMinutes = _calculateLateMinutes(emp['arrival']);
        final int penaltyAmount = calculerPenalite(lateMinutes);
        Logger().w("emp['arrival'] ${emp['nom']}, (emp['arrival'] ${emp['arrival']}, lateMinutes $lateMinutes, penaltyAmount $penaltyAmount");

        if (employeePenalties.containsKey(employeeId)) {
          employeePenalties[employeeId]!['totalMinutes'] += lateMinutes;
          employeePenalties[employeeId]!['total'] = calculerPenalite(employeePenalties[employeeId]!['totalMinutes']);
        } else {
          employeePenalties[employeeId] = {
            ...emp,
            'total': penaltyAmount,
            'type': 'Pénalité',
            'arrival': '', // Masquer l'heure d'arrivée
            'departure': '', // Masquer l'heure de départ
            'totalMinutes': lateMinutes
          };

        }
      }
      return employeePenalties.values.toList();
    }
    return filtered;
  }
  Future<List<Map<String, dynamic>>> _getAllAbsences() async {
    try {
      // Récupérer tous les utilisateurs
      final responseUsers = await Supabase.instance.client
          .from('user')
          .select('id, nom, prenom');

      if (responseUsers.isEmpty) {
        throw Exception('Aucun utilisateur trouvé');
      }

      final users = List<Map<String, dynamic>>.from(responseUsers);
      final today = DateTime.now();
      final debutMois = DateTime(today.year, today.month, 1);
      final List<Map<String, dynamic>> absencesList = [];

      for (final user in users) {
        final userId = user['id'];
        final userName = '${user['prenom']} ${user['nom']}';

        // Récupérer les jours de présence dans Supabase pour cet utilisateur
        final response = await Supabase.instance.client
            .from('pointage')
            .select('date_heure')
            .eq('idemploye', userId)
            .gte('date_heure', debutMois.toIso8601String())
            .lte('date_heure', today.toIso8601String());

        final pointages = List<Map<String, dynamic>>.from(response);

        // Jours où l'employé a pointé (au format yyyy-MM-dd)
        final joursPointes = pointages.map((e) {
          final date = DateTime.parse(e['date_heure']).toLocal();
          return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        }).toSet();

        // Liste des jours fériés au format 'YYYY-MM-DD'
        List<String> joursFeries = [
          '2025-01-01', // Nouvel an
          '2025-04-21', // Lundi de Pâques
          '2025-05-01', // Fête du travail
          '2025-05-08', // Victoire 1945
          '2025-05-29', // Ascension
          '2025-06-09', // Lundi de Pentecôte
          '2025-07-14', // Fête nationale
          '2025-08-15', // Assomption
          '2025-11-01', // Toussaint
          '2025-11-11', // Armistice
          '2025-12-25', // Noël
        ];

        List<String> toutesLesDates = [];
        for (DateTime d = debutMois;
        d.isBefore(today) || d.isAtSameMomentAs(today);
        d = d.add(Duration(days: 1))) {
          String dateStr = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
          if (d.weekday != DateTime.saturday &&
              d.weekday != DateTime.sunday &&
              !joursFeries.contains(dateStr)) {
            toutesLesDates.add(dateStr);
          }
        }

        // Absences = jours ouvrables sans pointage
        final joursAbsents = toutesLesDates.where((date) => !joursPointes.contains(date)).toList();

        // Ajouter les absences à la liste
        for (final jourAbsent in joursAbsents) {
          absencesList.add({
            'avatar': Icons.person,
            'nom': userName,
            'type': 'Absent',
            'date': jourAbsent,
            'arrival': '', // Masquer l'heure d'arrivée
            'departure': '', // Masquer l'heure de départ
          });
        }
      }

      return absencesList;
    } catch (e) {
      print("Erreur lors du chargement des absences : $e");
      return [];
    }

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
          title: Text('Validation du statut de  ${employee['nom']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasLate) ...[
                  const Text('DÉTAILS RETARD',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Text('Arrivé à ${employee['arrival']} (Normal: 08h30)'),
                  Text('Retard: ${formatMinutesToHours(lateMinutes)}'),
                  Text('Sanction: ${calculerPenalite(lateMinutes)}',
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
                  Text(employee['overtimeMotif'] ?? employee['raison'] ?? 'Aucun motif fourni',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                  const Divider(height: 30),
                ],
                if (employee['statut'] == 'En attente') ...[
                  const Text('Commentaire :',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  TextField(
                    controller: _rejectionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF000000))
                      ),
                      hintText: 'Motif du rejet',
                    ),
                    maxLines: 3,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (employee['statut'] == 'En attente') ...[
              TextButton(
                onPressed: () {
                  if (_rejectionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez saisir un motif de rejet')));
                    return;
                  }
                  updateStatus(
                    employeeId: employee['id'].toString(),
                     idpointage: employee['idpointage'].toString(), newStatus: 'Rejeté',
                  );
                  Navigator.pop(context);
                },
                child: const Text('REJETER', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  updateStatus(
                    employeeId: employee['id'].toString(),
                    newStatus: 'Validé',  idpointage: employee['idpointage'].toString(),
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
    required String idpointage,
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
          .eq('idemploye', employeeId)
           .eq('id',idpointage);
      await _fetchAllData();

      Logger().i(idpointage);
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: filteredEmployees, // Utilisez le Future ici
                builder: (context, snapshot) {
                  // Gérer les différents états du Future
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  }
                    // Les données sont disponibles
                    final employees = snapshot.data!;
                    return ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employee = employees[index];
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
                              child: Icon(employee['avatar'], color: Colors.blue), // Couleur bleue pour l'icône
                            ),
                            title: Text(employee['nom'], style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Type: ${employee['type']}', style: const TextStyle(
                                  color: Colors.black,
                                )),
                                Text('Date: ${employee['date']}', style: const TextStyle(
                                  color: Colors.black,
                                )),
                                if (employee['type'] == "Arrivée" )
                                  Text('Arrivé à ${employee['arrival']}', style: const TextStyle(
                                    color: Colors.black,
                                  )),
                                if (employee['type'] == "Départ" )
                                  Text('Départ à ${employee['departure']}', style: const TextStyle(
                                    color: Colors.black,
                                  )),
                                if (hasLate && _selectedIndex != 4)
                                  Text('Retard: ${formatMinutesToHours(lateMinutes)}', style: const TextStyle(
                                    color: Colors.black,
                                  )),
                                  if (_selectedFilter == 'Pénalité') ...[
                                    const SizedBox(height: 5),
                                    Text(
                                      'Pénalité totale: ${(employee['total'])} F',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ] else

                                      if (hasOvertime && employee['heuresSupp'].isNotEmpty)
                                        Text('Heures supp: ${employee['heuresSupp']}', style: const TextStyle(
                                          color: Colors.black,
                                        )),

                                if (_selectedFilter == 'Absent') ...[
                                  const SizedBox(height: 5),
                                    Text('Date: ${employee['date']  }', style: const TextStyle(
                                    color: Colors.black,
                                    )),
                                ],
                              ],
                            ),
                            trailing: (hasLate || hasOvertime || isAbsent)
                                ? _buildStatusBadge(employee['statut'])
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