import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:projets/constants.dart';
import 'package:projets/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


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
      elevation: 2,
      child: ExpansionTile(
        iconColor: Colors.black,
        backgroundColor: Colors.white,
        title: Text("${user['nom'] ?? ''} ${user['prenom'] ?? ''}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        children: [
          _buildRow("Téléphone", user['tel']?.toString() ?? ''),
          _buildRow("Adresse", user['adresse'] ?? ''),
          _buildRow("Date de naissance", user['datenaissance'] ?? ''),
          _buildRow("Email", user['email'] ?? ''),
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
                    final dateNaissanceController = TextEditingController(text: user['datenaissance']);
                    List<Map<String, dynamic>> types = await Supabase.instance.client.from('type').select();
                    List<Map<String, dynamic>> postes = await Supabase.instance.client.from('poste').select();
                    String? selectedTypeId = user['idtype']?.toString();
                    String? selectedPosteId = user['idposte']?.toString();
                    showDialog(
                      context: context,
                      builder: (context) {
                        bool isUpdating = false;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("Modifier les informations"),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    TextField(cursorColor: Colors.blue,
                                        controller: nomController, decoration: InputDecoration(
                                          labelStyle: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                                          labelText: "Nom",
                                          enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blue),
                                          ),)),
                                    TextField(cursorColor: Colors.blue,
                                        controller: prenomController, decoration: InputDecoration(
                                          labelStyle: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                                          labelText: "Prénom",
                                          enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blue),
                                          ),)),
                                    TextField(cursorColor: Colors.blue,
                                        controller: telController, decoration: InputDecoration(
                                          labelStyle: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                                          labelText: "Téléphone",
                                          enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blue),
                                          ),)),
                                    TextField(cursorColor: Colors.blue,
                                        controller: adresseController, decoration: InputDecoration(
                                          labelStyle: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                                          labelText: "Adresse",
                                          enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blue),
                                          ),)),
                                    TextField(cursorColor: Colors.blue,
                                        controller: emailController, decoration: InputDecoration(
                                          labelStyle: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                                          labelText: "Email",
                                          enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blue),
                                          ),)),
                                    TextField(cursorColor: Colors.blue,
                                        controller: dateNaissanceController, decoration: InputDecoration(
                                          labelStyle: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                                          labelText: "Date de naissance",
                                          enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blue),
                                          ),)),
                                    DropdownButtonFormField<String>(
                                      value: selectedTypeId,
                                      decoration: InputDecoration(
                                          labelStyle: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                                          labelText: 'Type',
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                      dropdownColor: Colors.white,
                                      items: types.map<DropdownMenuItem<String>>((type) {
                                        return DropdownMenuItem<String>(
                                          value: type['idtype'].toString(),
                                          child: Text(type['nomtype']),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedTypeId = value!;
                                        });
                                      },
                                    ),
                                    // Dropdown pour le poste
                                    DropdownButtonFormField<String>(
                                      value: selectedPosteId,
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                                          labelText: 'Poste',
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                      dropdownColor: Colors.white,
                                      items: postes.map<DropdownMenuItem<String>>((poste) {
                                        return DropdownMenuItem<String>(
                                          value: poste['idposte'].toString(),
                                          child: Text(poste['nom_poste']),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedPosteId = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: Text("Annuler",
                                    style: TextStyle(color: Colors.blue))),
                                ElevatedButton(

                                  onPressed: isUpdating ? null : () async {
                                    setState(() => isUpdating = true);
                                    final updatedData = {
                                      'nom': nomController.text.trim(),
                                      'prenom': prenomController.text.trim(),
                                      'tel': telController.text.trim(),
                                      'adresse': adresseController.text.trim(),
                                      'email': emailController.text.trim(),
                                      'datenaissance': dateNaissanceController.text.trim(),
                                      'idtype': int.tryParse(selectedTypeId ?? ''),
                                      'idposte': int.tryParse(selectedPosteId ?? ''),
                                    };

                                    try {
                                      await Supabase.instance.client
                                          .from('user')
                                          .update(updatedData)
                                          .eq('id', user['id']);

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Mise à jour réussie"),
                                        backgroundColor: Colors.green,
                                      ));
                                      await chargerTousLesUtilisateurs();
                                    } catch (e) {
                                      Logger().e("Erreur update", error: e);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Erreur lors de la mise à jour"),
                                        backgroundColor: Colors.red,
                                      ));
                                      setState(() => isUpdating = false);
                                    }
                                  },
                                  child: isUpdating ?
                                  CircularProgressIndicator(
                                    color: Colors.blue,) :
                                  Text("Modifier",style: TextStyle(color: Colors.blue),),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Modifier"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                ),
              ],
            ),
          )
        ],
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




