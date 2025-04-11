
import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:projets/accueil_page.dart';
import 'package:projets/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectPage extends StatefulWidget {
  @override
  State<ConnectPage> createState() => ConnectPageState();
}

class ConnectPageState extends State<ConnectPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController mdpController = TextEditingController();


  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  Future<void>  loadSavedCredentials() async {
    final authBox = Hive.box('authBox');
    final response= authBox.get("email");
    Logger().i(response);

  }

  String hashPassword(String password) {
    return Crypt.sha512(password, rounds: 10000, salt: "abcdefghijklmnop").toString();
  }

  Future<void> login() async {


    try {

      String email = emailController.text.trim();
      String mdp = mdpController.text.trim();

      if (email.isEmpty || mdp.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez remplir tous les champs'),
            backgroundColor: Colors.blue,
          ),
        );
        return;
      }

      String hashedPassword = hashPassword(mdp);

      final response = await Supabase.instance.client
          .from('user')
          .select()
          .eq('email', email)
          .eq('motpasse', hashedPassword)
          .maybeSingle();

      if (response != null) {

        /*final authBox = Hive.box('authBox');
        await authBox.put("email", emailController.text);*/



        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Accueil()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email ou mot de passe incorrect.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              primaryColor,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 3,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTextField('Email', Icons.email, emailController),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTextField('Mot de passe', Icons.lock, mdpController, isPassword: true),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (value) {},
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                return primaryColor;
                              },
                            ),
                          ),
                          Text('Se rappeler de moi'),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      await login();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 30)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      cursorColor: Colors.black,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF2B9BD7)),
        prefixIcon: Icon(icon, color: Color(0xFF2B9BD7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2B9BD7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2B9BD7), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2B9BD7), width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}