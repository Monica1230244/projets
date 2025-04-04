import 'package:flutter/material.dart';

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
  final _confirmPasswordController = TextEditingController();
  final _positionController = TextEditingController();

  String? _selectedDepartment;
  bool _isLoading = false;

  final List<String> _departments = [
    'Developpeur',
    'Gestionnaire Support & Qualité',
    'Gestionnaire Commercial',
    'Designer',
    'Sécrétariat',
    'Directeur Général'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _positionController.dispose();
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


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compte employé créé avec succès (simulation)')),
        );


        _formKey.currentState?.reset();
        setState(() {
          _selectedDepartment = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

          backgroundColor:   Color(0xFF2B9BD7),


      appBar: AppBar(
        title: Text('Créer un compte employé',style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body:
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFF2B9BD7),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Nom*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
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
                  decoration: InputDecoration(
                    labelText: 'Prénom*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
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
                  decoration: InputDecoration(
                    labelText: 'Email*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
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
                TextFormField(
                  controller: _positionController,
                  decoration: InputDecoration(
                    labelText: 'Poste*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est obligatoire';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: InputDecoration(
                    labelText: 'Département*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  hint: Text('Sélectionnez un département'),
                  items: _departments.map((String department) {
                    return DropdownMenuItem<String>(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDepartment = newValue;
                    });
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
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
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
                SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer mot de passe*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),

                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Color(0xFF2B9BD7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'CRÉER LE COMPTE',
                        style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                          color: Colors.white
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