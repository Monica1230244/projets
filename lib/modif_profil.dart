// edit_user.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:projets/tous_profil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController emailController;
  late TextEditingController telController;
  late TextEditingController adresseController;
  late TextEditingController dateNaissanceController;

  List<Map<String, dynamic>> types = [];
  List<Map<String, dynamic>> postes = [];

  String? selectedTypeId;
  String? selectedPosteId;

  bool isUpdating = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = widget.user;

    nomController = TextEditingController(text: user['nom']);
    prenomController = TextEditingController(text: user['prenom']);
    emailController = TextEditingController(text: user['email']);
    telController = TextEditingController(text: user['tel'].toString());
    adresseController = TextEditingController(text: user['adresse']);
    dateNaissanceController = TextEditingController(text: user['datenaissance']);

    selectedTypeId = user['idtype']?.toString();
    selectedPosteId = user['idposte']?.toString();

    chargerTypesEtPostes();
  }

  Future<void> chargerTypesEtPostes() async {
    types = await Supabase.instance.client.from('type').select();
    postes = await Supabase.instance.client.from('poste').select();
    setState(() {});
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDateNaissance(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dateNaissanceController.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),


        builder: (BuildContext context , Widget? child){
          return Theme(
            data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary:Color(0xFF2B9BD7),
                  surface: Colors.white,
                  onSurface: Colors.black,
                )
            ),
            child: child!,
          );
        }
    );




    if (picked != null) {
      final formattedDate = DateFormat('dd MMMM yyyy', 'fr_FR').format(picked);
      setState(() {
        dateNaissanceController.text = formattedDate;
      });
    }
  }

  Future<void> modifierUtilisateur() async {
    setState(() => isUpdating = true);

    final updatedData = {
      'nom': nomController.text.trim(),
      'prenom': prenomController.text.trim(),
      'email': emailController.text.trim(),
      'tel': telController.text.trim(),
      'adresse': adresseController.text.trim(),
      'datenaissance': dateNaissanceController.text.trim(),
      'idtype': selectedTypeId ?? '',
      'idposte': selectedPosteId ?? '',
    };

    try {
      await Supabase.instance.client
          .from('user')
          .update(updatedData)
          .eq('id', widget.user['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mise à jour réussie"), backgroundColor: Colors.green),
      );

      Navigator.pop(context, true); // Retour avec succès
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour"), backgroundColor: Colors.red),
      );
    }

    setState(() => isUpdating = false);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text("Modifier l'utilisateur")),
      body: types.isEmpty || postes.isEmpty
          ? Center(
          child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child:Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    ClipOval(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.black12,
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? const Icon(Icons.person, size: 60, color: Colors.black)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.photo,color: Colors.white,),
                      label: const Text("Ajouter une photo",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        backgroundColor: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                  cursorColor: Colors.blue,
                  controller: nomController, decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                    labelText: "Nom",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),)),
              SizedBox(height: 20),
              TextField(cursorColor: Colors.blue,
                  controller: prenomController, decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                    labelText: "Prénom",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),)),
              SizedBox(height: 20),
              TextField(cursorColor: Colors.blue,
                  controller: telController, decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                    labelText: "Téléphone",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),)),
              SizedBox(height: 20),
              TextField(cursorColor: Colors.blue,
                  controller: adresseController, decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                    labelText: "Adresse",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),)),
              SizedBox(height: 20),
              TextField(cursorColor: Colors.blue,
                  controller: emailController, decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                    labelText: "Email",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),)),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDateNaissance(context),
                child: AbsorbPointer(
                  child: TextField(
                    cursorColor: Colors.blue,
                    controller: dateNaissanceController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.calendar_today, color: Colors.black),
                      labelStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                      labelText: "Date de naissance",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedTypeId,
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                  // Style du label en focus
                  floatingLabelStyle: TextStyle(color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  labelText: 'Type',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  // Bordure bleue quand le champ est focus
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
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
              SizedBox(height: 20),
              // Dropdown pour le poste
              DropdownButtonFormField<String>(
                value: selectedPosteId,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.black,fontSize: 20,
                      fontWeight: FontWeight.bold),
                  labelText: 'Poste',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
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
                  }
                  );
                },
              ),
                SizedBox(height: 30),
                Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: ElevatedButton.icon(
                onPressed: isUpdating ? null : modifierUtilisateur,
                label: isUpdating
                    ? SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                )
                    : Text("Modifier",style:TextStyle(fontSize: 20),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 135, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 10,
                ),
              ),
            ),
          ],
                ),

                ],
          ),
        ),
      ),

    );

  }
}
