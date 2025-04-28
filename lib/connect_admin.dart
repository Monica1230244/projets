import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

class CreateEmployee extends StatefulWidget {
  @override
  _CreateEmployeeState createState() => _CreateEmployeeState();
}

class _CreateEmployeeState extends State<CreateEmployee> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthDateController = TextEditingController();

  DateTime? _selectedDate;

  String? _selectedtype;
  String? _selectedDepartement;
  String? _selectedPoste;
  bool  isLoading = false;

  List<Map<String, dynamic>> _departements = [];
  List<Map<String, dynamic>> _postes = [];
  List<Map<String, dynamic>> _types = [];

  List<Map<String, dynamic>> getFilteredPostes() {
    if (_selectedDepartement == null) return [];

    return _postes.where((poste) {
      final dept = poste['departement'] as Map<String, dynamic>?;
      return dept != null && dept['nom_departement'] == _selectedDepartement;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_autoGeneratePassword);
    _lastNameController.addListener(_autoGeneratePassword);
    _emailController.addListener(_autoGeneratePassword);
    _loadDepartementsAndPostes();
  }

  Future<void> _loadDepartementsAndPostes() async {
    setState(() => isLoading = true);
    try {
      final departements = await Supabase.instance.client
          .from('departement')
          .select()
          .order('nom_departement');

      final postes = await Supabase.instance.client
          .from('poste')
          .select('*,departement (id_departement, nom_departement)')
          .order('nom_poste');

      final type= await Supabase.instance.client
          .from('type')
          .select()
          .order('nomtype');


      setState(() {
        _departements = List<Map<String, dynamic>>.from(departements);
        _postes = List<Map<String, dynamic>>.from(postes);
        _types = List<Map<String, dynamic>>.from(type);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des données: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _generateRandomPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        12,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void _autoGeneratePassword() {
    if (_firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _selectedDepartement != null &&
        _selectedPoste != null &&
        _passwordController.text.isEmpty) {
      setState(() {
        _passwordController.text = _generateRandomPassword();
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    super.dispose();

  }

  Future<void> _createEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);


    if (_selectedPoste == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un poste.')),
      );
      setState(() => isLoading = false);
      return;
    }
    try {
      Logger().i(_selectedtype);

      final type = _types.firstWhere(
            (d) => d['nomtype'] == _selectedtype,
      );
      Logger().i(type);
      final poste = _postes.firstWhere((p) => p['nom_poste'] == _selectedPoste);
      Logger().i(poste);

      final birthDate = _selectedDate!;
      final birthDateTimes = birthDate.toIso8601String();

      Logger().i(birthDateTimes);

      final userData = {
        'nom': _firstNameController.text,
        'prenom': _lastNameController.text,
        'email': _emailController.text,
        'tel': _phoneController.text,
        'adresse': _addressController.text,
        'datenaissance': birthDateTimes,
        'idposte': poste['idposte'],
        'idtype': type['idtype'],
        'motpasse':
            Crypt.sha512(
              _passwordController.text,
              rounds: 10000,
              salt: "abcdefghijklmnop",
            ).toString(),

      };
      Logger().i(userData);

      if (userData['idposte'] == null) {
        Logger().e(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID du poste est manquant.')),
        );
        setState(() => isLoading = false);
        return;
      }
      await Supabase.instance.client.from('user').insert(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compte employé créé avec succès')),
      );

      _formKey.currentState?.reset();
      setState(() {
        _selectedDepartement = null;
        _selectedPoste = null;
        _passwordController.clear();
      });
    }  catch (e) {
      Logger().e(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création: ${e.toString()}')),
      );

    } finally {
      setState(() => isLoading = false);
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }

    final phoneRegExp = RegExp(r'^\d{10}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Numéro de téléphone invalide (10 chiffres requis)';
    }

    return null;
  }

  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: _birthDateController,
          decoration: InputDecoration(
            labelText: 'Date de naissance*',
            labelStyle: TextStyle(color: Colors.black),
            prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF2B9BD7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF2B9BD7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF2B9BD7)),
            ),
          ),
          validator: (value) {
            if (_selectedDate == null && (value == null || value.isEmpty)) {
              return 'Ce champ est obligatoire';
            }
            return null;
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2B9BD7),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text =
        "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
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
        title: Text(
          'Créer un compte employé',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.blue,
        ),
      ))
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              _buildTextFormField(
                controller: _firstNameController,
                label: 'Nom*',
                icon: Icons.person,
                validator:
                    (v) => v!.isEmpty ? 'Ce champ est obligatoire' : null,
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _lastNameController,
                label: 'Prénom*',
                icon: Icons.person,
                validator:
                    (v) => v!.isEmpty ? 'Ce champ est obligatoire' : null,
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _phoneController,
                label: 'Téléphone*',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _addressController,
                label: 'Adresse*',
                icon: Icons.location_on,
                validator:
                    (v) => v!.isEmpty ? 'Ce champ est obligatoire' : null,
              ),
              SizedBox(height: 16),
              _buildDatePickerField(),

              SizedBox(height: 16),

              _buildtypeDropdown(),

              SizedBox(height: 16),
              _buildTextFormField(
                controller: _emailController,
                label: 'Email*',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.isEmpty) return 'Ce champ est obligatoire';
                  if (!v.contains('@') || !v.contains('.'))
                    return 'Email invalide';
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildDepartmentDropdown(),
              SizedBox(height: 16),
              _buildPosteDropdown(),
              SizedBox(height: 20),
              Text(
                'Identifiants de connexion',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildPasswordField(),
              SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildtypeDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: _selectedtype,
      decoration: _buildInputDecoration('Type*', Icons.business),
      hint: Text('Sélectionnez'),
      items:
      _types.map<DropdownMenuItem<String>>((type) {
        return DropdownMenuItem<String>(
          value: type['nomtype'].toString(),
          child: Text(type['nomtype'].toString()),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedtype = newValue;

        });
        _autoGeneratePassword();
      },
      validator: (value) => value == null ? 'Ce champ est obligatoire' : null,
    );
  }




  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.blue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2B9BD7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2B9BD7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2B9BD7)),
        ),
        prefixIcon: Icon(icon, color: Colors.blue),
      ),
      validator: validator,
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: _selectedDepartement,
      decoration: _buildInputDecoration('Département*', Icons.business),
      hint: Text('Sélectionnez'),
      items:
          _departements.map<DropdownMenuItem<String>>((dept) {
            return DropdownMenuItem<String>(
              value: dept['nom_departement'].toString(),
              child: Text(dept['nom_departement'].toString()),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedDepartement = newValue;
          _selectedPoste = null;
        });
        _autoGeneratePassword();
      },
      validator: (value) => value == null ? 'Ce champ est obligatoire' : null,
    );
  }

  Widget _buildPosteDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: _selectedPoste,
      decoration: _buildInputDecoration('Poste*', Icons.work),
      hint: Text('Sélectionnez'),
      items:
          getFilteredPostes().map<DropdownMenuItem<String>>((poste) {
            return DropdownMenuItem<String>(
              value: poste['nom_poste'].toString(),
              child: Text(poste['nom_poste'].toString()),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedPoste = newValue;
        });
        _autoGeneratePassword();
      },
      validator: (value) => value == null ? 'Ce champ est obligatoire' : null,
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFF2B9BD7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFF2B9BD7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFF2B9BD7)),
      ),
      prefixIcon: Icon(icon, color: Colors.blue),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      cursorColor: Colors.black,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Mot de passe*',
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2B9BD7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2B9BD7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2B9BD7)),
        ),
        prefixIcon: Icon(Icons.lock, color: Colors.blue),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_passwordController.text.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
            IconButton(
              icon: Icon(Icons.copy, color: Colors.blue),
              onPressed: () {
                if (_passwordController.text.isNotEmpty) {
                  Clipboard.setData(
                    ClipboardData(text: _passwordController.text),
                  );
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Mot de passe copié')));
                }
              },
            ),
          ],
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est obligatoire';
        }
        if (value.length < 8) {
          return '8 caractères minimum';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _createEmployee,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'CRÉER LE COMPTE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

}
