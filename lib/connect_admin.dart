import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

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
  final _positionController = TextEditingController();

  String? _selectedDepartement;
  bool _isLoading = false;

  final List<String> _departement = [
    'Informatique',
    'Commercial',
    'Sécrétariat',
    'Direction Général'
  ];

  String? _selectedPoste;
  final List<String> _poste = [
    'Developpeur web',
    'Developpeur mobile',
    'Stagiaire',
    'Gestionnaire Support & Qualité',
    'Gestionnaire Commercial',
    'Gestionnaire Projet',
    'Designer',
    'Sécrétaire',
    'Directeur Général'
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_autoGeneratePassword);
    _lastNameController.addListener(_autoGeneratePassword);
    _emailController.addListener(_autoGeneratePassword);
    _positionController.addListener(_autoGeneratePassword);
  }

  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      12,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
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
    _positionController.dispose();
    _firstNameController.removeListener(_autoGeneratePassword);
    _lastNameController.removeListener(_autoGeneratePassword);
    _emailController.removeListener(_autoGeneratePassword);
    _positionController.removeListener(_autoGeneratePassword);
    super.dispose();
  }

  void _createEmployee() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        _formKey.currentState?.reset();
        setState(() {
          _selectedDepartement = null;
          _selectedPoste = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Créer un compte employé', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
      ),
      body: SingleChildScrollView(
        child:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              TextFormField(
                controller: _firstNameController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: 'Nom*',
                  labelStyle: TextStyle(color: Color(0xFF000000)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF2B9BD7))
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF2B9BD7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF2B9BD7)),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: 'Prénom*',
                  labelStyle: TextStyle(color: Color(0xFF000000)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF2B9BD7))
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF2B9BD7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF2B9BD7)),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: 'Email*',
                  labelStyle: TextStyle(color: Color(0xFF000000)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF2B9BD7))
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF2B9BD7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF2B9BD7)),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.blue),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _selectedDepartement,
                decoration: InputDecoration(
                  labelText: 'Département*',
                  labelStyle: TextStyle(color: Color(0xFF000000)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF2B9BD7))
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF2B9BD7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF2B9BD7)),
                  ),
                  prefixIcon: Icon(Icons.business, color: Colors.blue),
                ),

                hint: Text('Sélectionnez un département'),
                items: _departement.map((String department) {
                  return DropdownMenuItem<String>(

                    value: department,

                    child: Text(department),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {

                    _selectedDepartement = newValue;
                  });
                  _autoGeneratePassword();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _selectedPoste,
                decoration: InputDecoration(
                  labelText: 'Poste*',
                  labelStyle: TextStyle(color: Color(0xFF000000)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF2B9BD7))
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF2B9BD7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF2B9BD7)),
                  ),
                  prefixIcon: Icon(Icons.business, color: Colors.blue),
                ),
                hint: Text('Sélectionnez un poste'),
                items: _poste.map((String poste) {
                  return DropdownMenuItem<String>(
                    value: poste,
                    child: Text(poste),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPoste = newValue;
                  });
                  _autoGeneratePassword();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Text(
                'Identifiants de connexion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                cursorColor: Colors.black,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe*',
                  labelStyle: TextStyle(color: Color(0xFF000000)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF2B9BD7))
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
                            Clipboard.setData(ClipboardData(text: _passwordController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Mot de passe copié')),
                            );
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
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createEmployee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'CRÉER LE COMPTE',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}