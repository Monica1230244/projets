import 'package:crypt/crypt.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:projets/accueil_page.dart';
import 'package:projets/constants.dart';
import 'package:projets/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Connect extends StatefulWidget {
  @override
  State<Connect> createState() => ConnectPageState();
}

final Uri _url = Uri.parse(
  "mailto:contact@waouhmonde.com?subject=Demande d'assistance pour la création de compte&body=Bonjour,Je rencontre des difficultés pour créer un compte sur votre plateforme et j'aurais besoin de votre assistance pour finaliser la procédure. Pourriez-vous m'indiquer les étapes à suivre ?Je vous remercie par avance pour votre aide.%20",
);

class ConnectPageState extends State<Connect> {
  TextEditingController emailController = TextEditingController();
  TextEditingController mdpController = TextEditingController();
  String  emailUser="";
  bool _isLoading = false;
  bool _obscurePassword = true;


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
      //verfier si tous les champs sont remplis
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

        if (supabaseResponse != null) {
          if (supabaseResponse['is_active'] == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Votre compte est désactivé. Veuillez contacter l'administrateur.",
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Si le compte est actif, continuer normalement :
          final authBox = Hive.box('authBox');
          Users user = Users.fromSupabase(supabaseResponse);
          await authBox.put('stocker_user', user);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Accueil()),
          );
        }
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
    } finally {
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
            backgroundColor: Colors.white,
            title: Text('Réinitialisation du mot de passe'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Entrez votre email pour recevoir un lien de réinitialisation :',
                ),
                SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Votre email',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 2.0),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler', style: TextStyle(color: primaryColor)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();

                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Veuillez entrer un email valide'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    // 1. Envoi du code OTP
                    // final res  = await Supabase.instance.client.auth.signInWithOtp(email: email, shouldCreateUser: false);
                    final res = await EmailOTP.sendOTP(email: email);
                    // 2. Demander le code reçu par email
                    if (res) {
                      setState(() {
                        emailUser = email;
                      });
                      Navigator.pop(context);
                      await showDialog<String>(
                        context: context,
                        builder: (context) {
                          TextEditingController codeController =
                              TextEditingController();
                          return AlertDialog(
                            title: Text("Entrez le code reçu"),
                            content: TextField(
                              obscureText: true,
                              controller: codeController,
                              decoration: InputDecoration(
                                hintText: "Code à 6 chiffres",
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, null),
                                child: Text(
                                  "Annuler",
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final res = EmailOTP.verifyOTP(
                                    otp: codeController.text.trim(),
                                  );
                                  if (res) {
                                    Navigator.pop(context);
                                    await showDialog<String>(
                                      context: context,
                                      builder: (context) {
                                        TextEditingController pwdController =
                                            TextEditingController();
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Text("Nouveau mot de passe"),
                                          content: TextField(
                                            controller: pwdController,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Saisir nouveau mot de passe",
                                              border: OutlineInputBorder(),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 2.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    null,
                                                  ),
                                              child: Text(
                                                "Annuler",
                                                style: TextStyle(
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                final updatedData = {
                                                  'motpasse':
                                                  hashPassword(pwdController.text.trim()) ,
                                                };

                                                try {
                                                  Logger().i(emailUser);
                                                 await Supabase.instance.client
                                                      .from('user')
                                                      .update(updatedData)
                                                     .eq('email',emailUser.trim());

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Mise à jour réussie",
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );

                                                  Navigator.pop(
                                                    context
                                                  ); // Retour avec succès
                                                } catch (e) {
                                                  Logger().e(e.toString());
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text("Erreur lors de la mise à jour"
                                                        ,
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: _isLoading
                                                  ? SizedBox(
                                                width: 15,
                                                height: 15,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.blue,
                                                  ),
                                                ),
                                              )
                                                  : Text(
                                                "Modifier",
                                                style: TextStyle(
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Code incorrect."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: _isLoading
                                    ? SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue,
                                    ),
                                  ),
                                )
                                    :Text(
                                  "Valider",
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    Navigator.pop(context); // Fermer la boîte principale
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Mot de passe réinitialisé avec succès."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Erreur : $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: _isLoading
                    ? SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                )
                    :Text('Envoyer', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
    );
  }

  //formulaire pour renseigner les informations
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset(
                    'assets/images/logo1.png',
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
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_isLoading) {
                        await login();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 115,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
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
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _handleForgotPassword,
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Text(
                      "Vous n'avez pas de compte ?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _launchUrl,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'Contacter l\'administrateur !',
                              style: TextStyle(color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}


  Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Impossible de lancer $_url');
  }
}
