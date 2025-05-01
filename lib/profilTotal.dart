import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:projets/constants.dart';
import 'package:projets/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'connect_admin.dart';

class Profiltotal extends StatefulWidget {
  const Profiltotal({super.key});

  @override
  State<Profiltotal> createState() => _ProfiltotalState();
}

class _ProfiltotalState extends State<Profiltotal> {
  List<Map<String, dynamic>> utilisateurs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    chargerTousLesUtilisateurs();
  }

  Future<void> chargerTousLesUtilisateurs() async {
    try {


      final response = await Supabase.instance.client
          .from('user')
          .select('id,nom, prenom, tel, adresse, datenaissance, email, idtype, idposte');

      utilisateurs = List<Map<String, dynamic>>.from(response);
Logger().i(response);
      for (var user in utilisateurs) {
        final typeData = await Supabase.instance.client
            .from('type')
            .select('nomtype')
            .eq('idtype', user['idtype']);

        final posteData = await Supabase.instance.client
            .from('poste')
            .select('nom_poste')
            .eq('idposte', user['idposte']);

        user['type'] = typeData.isNotEmpty ? typeData.first : {};
        user['poste'] = posteData.isNotEmpty ? posteData.first : {};

      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Logger().e("Erreur", error: e);
      setState(() {
        isLoading = false;
        errorMessage = "Erreur lors du chargement des utilisateurs";
      });
    }
  }

  String _getNestedValue(Map<String, dynamic> data, List<String> keys) {
    try {
      dynamic current = data;
      for (final key in keys) {
        current = current[key];
        if (current == null) return 'Non spécifié';
      }
      return current.toString();
    } catch (e) {
      return 'Non spécifié';
    }
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ExpansionTile(
        iconColor: Colors.black,
        backgroundColor: Colors.white,
        title: Text("${user['nom']?.toString() ?? ''}"
            " ${user['prenom']?.toString() ?? ''}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        children: [
          _buildRow("Téléphone", user['tel']?.toString() ??''),
          _buildRow("Adresse", user['adresse']?.toString() ??''),
          _buildRow("Date de naissance", user['datenaissance']?.toString() ??''),
          _buildRow("Email", user['email']?.toString() ?? ''),
          _buildRow("Type", _getNestedValue(user, ['type', 'nomtype'])),
          _buildRow("Poste", _getNestedValue(user, ['poste', 'nom_poste'])),

    SizedBox(height: 10),

          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final nomController = TextEditingController(text: user['nom']);
                final prenomController = TextEditingController(text: user['prenom']);
                final telController = TextEditingController(text: user['tel'].toString());
                final adresseController = TextEditingController(text: user['adresse']);
                final emailController = TextEditingController(text: user['email']);

                showDialog(
                  context: context,
                  builder: (context) {
                    bool isUpdating = false;
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          shadowColor: Colors.blue,
                          title: Text("Modifier les informations"),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  style: TextStyle(color: Colors.black),
                                    cursorColor: Colors.blue,
                                    controller: nomController, decoration: InputDecoration(labelText: "Nom",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),)),
                                TextField(style: TextStyle(color: Colors.black),
                                    cursorColor: Colors.blue,
                                    controller: prenomController, decoration: InputDecoration(labelText: "Prénom",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),)),
                                TextField(style: TextStyle(color: Colors.black),
                                    cursorColor: Colors.blue,
                                    controller: telController, decoration: InputDecoration(labelText: "Téléphone",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),)),
                                TextField(style: TextStyle(color: Colors.black),
                                    cursorColor: Colors.blue,
                                    controller: adresseController, decoration: InputDecoration(labelText: "Adresse",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),)),
                                TextField(style: TextStyle(color: Colors.black),
                                    cursorColor: Colors.blue,
                                    controller: emailController, decoration: InputDecoration(labelText: "Email",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),)),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Annuler",style: TextStyle(color: Colors.blue),),
                            ),
                            ElevatedButton(
                              onPressed: isUpdating ? null : () async {
                                setState(() => isUpdating = true);
                                final updatedData = {
                                  'nom': nomController.text.trim(),
                                  'prenom': prenomController.text.trim(),
                                  'tel': telController.text.trim(),
                                  'adresse': adresseController.text.trim(),
                                  'email': emailController.text.trim(),
                                };

                                try {
                                  await Supabase.instance.client
                                      .from('user')
                                      .update(updatedData)
                                      .eq('id', user['id']);


                                  final authBox = Hive.box('authBox');
                                  final Users? currentUser = authBox.get('stocker_user') as Users?;

                                  if (currentUser != null && currentUser.id == user['id']) {
                                    final updatedUser = Users(
                                      id: currentUser.id,
                                      nom: updatedData['nom'] ?? '',
                                      prenom: updatedData['prenom'] ?? '',
                                      email: updatedData['email'] ?? '',
                                      tel: int.tryParse(updatedData['tel']?.toString() ?? '0') ?? 0,
                                      adresse: updatedData['adresse'] ?? '',
                                      datenaissance: currentUser.datenaissance ?? '',
                                      poste: currentUser.poste ?? '',
                                      type: currentUser.type ?? '',
                                      createdAt: currentUser.createdAt ?? '',
                                    );
                                    await authBox.put('stocker_user', updatedUser);
                                  }

                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("Informations mises à jour avec succès"),
                                    backgroundColor: Colors.green,
                                  ));

                                  // Recharge les données à l'écran
                                  await chargerTousLesUtilisateurs();
                                } catch (e) {
                                  Logger().e("Erreur mise à jour", error: e);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("Erreur lors de la mise à jour"),
                                    backgroundColor: Colors.red,
                                  ));
                                  setState(() => isUpdating = false);
                                }
                              },
                              child: isUpdating
                                  ? CircularProgressIndicator(color: Colors.blue)
                                  : Text("Modifier",style: TextStyle(color: Colors.blue)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              icon: Icon(Icons.edit),
              label: Text("Modifier",),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(width: 80),
          ElevatedButton.icon(
          onPressed: () async {
          final id = user['id'];
          try {
            print("ID à désactiver : $id");
          await Supabase.instance.client
              .from('user')
              .update({'is_active': false})
              .eq('id', id);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Utilisateur désactivé"),
          backgroundColor: Colors.red,
          ));
          } catch (e) {
          Logger().e("Erreur désactivation", error: e);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erreur lors de la désactivation"),
          backgroundColor: Colors.red,
          ));
          }
          },
          icon: Icon(Icons.block),
          label: Text("Désactiver"),
          style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          ),
          ),
        ],
      ),
          )
    ]
    ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
      child: Row(
        children: [
          Text("$label : ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text("Profil de tous les utilisateurs",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 25)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      )
      )
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ListView.builder(
        itemCount: utilisateurs.length,
        itemBuilder: (context, index) {
          return _buildUserCard(utilisateurs[index]);
        },
      ),
    );
  }
}
