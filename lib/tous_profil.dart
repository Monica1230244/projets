import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:projets/constants.dart';
import 'package:projets/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'modif_profil.dart';


class Profil extends StatefulWidget {
  const Profil({super.key});
  @override
  State<Profil> createState() => _ProfilState();
}
class _ProfilState extends State<Profil> {
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
          .select('id, nom, prenom, tel, adresse, datenaissance, email, idtype, idposte');

      utilisateurs = List<Map<String, dynamic>>.from(response);

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

      setState(() => isLoading = false);
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
      elevation: 20,
      child: Container(
        child: ExpansionTile(
          iconColor: Colors.black,
          backgroundColor: Colors.white,
          title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           /* CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, size: 12, color: Colors.blue),
            ),*/
            Text(
              "${user['nom'] ?? ''} ${user['prenom'] ?? ''}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              " ${_getNestedValue(user, ['type', 'nomtype'])}" ": ${_getNestedValue(user, ['poste', 'nom_poste'])}",
              style: TextStyle(fontSize: 18, color: Colors.black87,),
            ),
          ],
        ),
        children: [
            _buildRow("Téléphone", user['tel']?.toString() ?? ''),
            _buildRow("Adresse", user['adresse'] ?? ''),
            _buildRow("Date de naissance", user['datenaissance'] ?? ''),
            _buildRow("Email", user['email'] ?? ''),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserPage(user: user),
                        ),
                      );

                      if (updated == true) {
                        await chargerTousLesUtilisateurs();
                      }
                    },

                    icon: Icon(Icons.edit),
                    label: Text("Modifier"),
                    style: ElevatedButton.styleFrom(
                        elevation: 8,
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white),
                  ),
                  SizedBox(width: 80),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final id = user['id'];
                      try {
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
                        elevation: 4,
                        backgroundColor: Colors.black12,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
      child: Row(
        children: [
          Text("$label : ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black)),
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Profil de tous les utilisateurs",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator( strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),))
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




