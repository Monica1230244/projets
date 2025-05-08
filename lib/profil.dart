import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projets/utilisateur.dart';
import 'package:projets/constants.dart';
import 'connect.dart';
import 'connect_page.dart';

class ProfilEmploye extends StatefulWidget {
  const ProfilEmploye({super.key});

  @override
  State<ProfilEmploye> createState() => _ProfilEmployeState();
}

class _ProfilEmployeState extends State<ProfilEmploye> {
  Map<String, dynamic>? employeData;
  bool isLoading = true;
  String? errorMessage;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    chargerDonneesEmploye();
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> chargerDonneesEmploye() async {
    try {
      final authBox = Hive.box('authBox');
      final Users? user = authBox.get('stocker_user') as Users?;

      if (user == null || user.id == null) {
        setState(() {
          errorMessage = "Aucun utilisateur connecté !";
          isLoading = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('user')
          .select('''
              nom, prenom, tel, adresse, datenaissance, email,
              idtype, idposte
          ''')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        setState(() {
          errorMessage = "Utilisateur non trouvé dans la base de données";
          isLoading = false;
        });
        return;
      }

      final typeFuture = Supabase.instance.client
          .from('type')
          .select('nomtype')
          .eq('idtype', response['idtype'])
          .maybeSingle();

      final posteFuture = Supabase.instance.client
          .from('poste')
          .select('nom_poste')
          .eq('idposte', response['idposte'])
          .maybeSingle();

      final results = await Future.wait([typeFuture, posteFuture]);

      setState(() {
        employeData = {
          ...response,
          'type': results[0],
          'poste': results[1]
        };
        isLoading = false;
      });

    } catch (e, stack) {
      Logger().e("Erreur de chargement", error: e, stackTrace: stack);
      setState(() {
        errorMessage = "Erreur lors du chargement du profil";
        isLoading = false;
      });
    }
  }

  void deconnexion() async {
    await Hive.box('authBox').clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => Connect()),
          (route) => false,
    );
  }

  String _getNestedValue(Map<String, dynamic>? data, List<String> keys) {
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
  String _formatPhoneNumber(String phone) {
    if ( phone.isEmpty) return 'Non spécifié';

    final tel = phone.toString();

    if (tel.length == 8) return "01$tel";
    if (tel.length == 9) return "0$tel";
    return tel;
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text("$label :",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
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
        title: const Text("Profil employé",style: TextStyle(color: Colors.black,
            fontWeight: FontWeight.bold,fontSize: 25),),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      )
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    ClipOval(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.photo,color: Colors.white,),
                      label: const Text("Ajouter une photo",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildRow("Nom", employeData?['nom']?.toString() ?? 'Non spécifié'),
              _buildRow("Prénom", employeData?['prenom']?.toString() ?? 'Non spécifié'),
              _buildRow("Téléphone",_formatPhoneNumber( employeData?['tel']?.toString()??'Non spécifié')),
              _buildRow("Adresse", employeData?['adresse']?.toString() ?? 'Non spécifié'),
              _buildRow("Date de naissance", employeData?['datenaissance']?.toString() ?? 'Non spécifié'),
              _buildRow("Email", employeData?['email']?.toString() ?? 'Non spécifié'),
              _buildRow("Type", _getNestedValue(employeData, ['type', 'nomtype'])),
              _buildRow("Poste", _getNestedValue(employeData, ['poste', 'nom_poste'])),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout,color: Colors.white,),
                  label: const Text("Déconnexion",style: TextStyle(color: Colors.white),),
                  onPressed: deconnexion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2B9BD7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
