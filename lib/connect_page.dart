import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:projets/accueil_page.dart';
import 'package:projets/constants.dart';
import 'package:projets/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectPage extends StatefulWidget {
  @override
  State<ConnectPage> createState() => ConnectPageState();
}

class ConnectPageState extends State<ConnectPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController mdpController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }
// mot de passe crypté
  String hashPassword(String password) {
    return Crypt.sha512(
      password,
      rounds: 10000,
      salt: "abcdefghijklmnop",
    ).toString();
  }

  Future<void> login() async {
    setState(() {
      _isLoading = true; // Active le loading
    });

    try {
      //deux variables déclarées
      String email = emailController.text.trim();
      String mdp = mdpController.text.trim();
//verfier si tous les chmaps sont remplis
      if (email.isEmpty || mdp.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez remplir tous les champs'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // declaré une variable pour recuperer le mdp crypté
      String hashedPassword = hashPassword(mdp);
      // requete pour verifier si un utilisateur a le meme email et mdp crypte qui est renseigné
      final supabaseResponse =
          await Supabase.instance.client
              .from('user')
              .select()
              .eq('email', email)
              .eq('motpasse', hashedPassword)
              .maybeSingle();
      Logger().i("Réponse Supabase: $supabaseResponse");

      if (supabaseResponse != null) {
          //appel de la boite
          final authBox = Hive.box('authBox');
          //declarer une variable a qui on a affecte l'objet qui prend en parametre la variable retournée
          Users user = Users.fromSupabase(supabaseResponse);
          //stocker les informations dans une clé principale
          await authBox.put('stocker_user', user);
          //recuperer et afficher les données stockées
          Logger().d("Données stockées: ${authBox.get('stocker_user')}");

       //navige vers la page accueil
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Accueil()),
        );
        //en cas d'erreur affiche ce message
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email ou mot de passe incorrect.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Logger().e(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
//methode pour reinitialiser un mdp oublié
  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Réinitialisation du mot de passe'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Entrez votre email pour recevoir un lien de réinitialisation :',
                ),
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: emailController.text),
                  decoration: InputDecoration(
                    hintText: 'Votre email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Veuillez entrer un email valide'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await Supabase.instance.client.auth.resetPasswordForEmail(
                      email,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Un email de réinitialisation a été envoyé à $email',
                        ),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de l\'envoi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: Text('Envoyer'),
              ),
            ],
          ),
    );
  }
//formulaire pour renseigner les informations
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, primaryColor],
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
                    child: _buildTextField(
                      'Email',
                      Icons.email,
                      emailController,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTextField(
                      'Mot de passe',
                      Icons.lock,
                      mdpController,
                      isPassword: true,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _handleForgotPassword,
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async{
                      if(!_isLoading){
                        await login();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      cursorColor: Colors.blue,
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
