import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:projets/presence_page.dart';
import 'package:projets/profil.dart';
import 'package:projets/utilisateur.dart';
import 'package:projets/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_page.dart';
import 'package:intl/intl.dart';
import 'connect_admin.dart';
import 'connect_page.dart';
import 'constants.dart';
import 'menu_bouton.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'user.dart';

class Accueil extends StatefulWidget {
  @override
  AccueilState createState() => AccueilState();
}

class AccueilState extends State<Accueil> {
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 110,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/logo1.png'),
            ),
            LoadingMenuButton(
              icon: Icons.login,
              text: "Marquer arrivée",
              onPressed: () async {
                await _verifierPositionEtMarquerDepart(context, estArrivee: true);
              },
            ),


            LoadingMenuButton(
              icon: Icons.logout,
              text: "Marquer départ",
              onPressed: () async {
                await _verifierPositionEtMarquerDepart(context, estArrivee: false);
              },
            ),


            LoadingMenuButton(
              icon: Icons.dashboard,
              text: "Consulter tableau de bord personnel",
              onPressed: () async {

                await  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PresenceUser()),
                );

              },
            ),

            LoadingMenuButton(
              icon: Icons.person,
              text: "Profil",
              onPressed: () async {

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilEmploye()),
                );
              },
            ),

         LoadingMenuButton(
              icon: Icons.analytics,
              text: "Consulter tableau de bord",
              onPressed: () async {

               await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDashboard()),
                );
              },
            ),



            LoadingMenuButton(
              icon: Icons.person,
              text: "Créer compte utilisateur",
              onPressed: () async {

               await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEmployee()),
                );
              },
            ),


          ],
        ),
        ),
      ),
    );
  }

  Future<void> _verifierPositionEtMarquerDepart(
    BuildContext context, {
    required bool estArrivee,
  }) async {
    try {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              padding: EdgeInsets.all(25),
              content: Text("Permission de localisation refusée",style: TextStyle(fontSize: 25),
              )
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        entrepriseLat,
        entrepriseLon,
      );

      if (distance <= distanceSeuil) {
        if (estArrivee) {
          marquerArrivee(context);
        } else {
          marquerDepart(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            padding: EdgeInsets.all(30),
            content: Text(
              "Vous êtes à ${(distance).toStringAsFixed(0)} mètres de l'entreprise. "
                  "Veuillez vous rendre dans l'entreprise.",style: TextStyle(fontSize: 20),
            ),
          ),
        );
      }
    } catch (e) {
      Logger().e(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            padding: EdgeInsets.all(30),
            content: Text("Erreur de géolocalisation: ${e.toString()}",style: TextStyle(fontSize: 25),
            )
        ),
      );
    }
  }

  Future<void> marquerArrivee(BuildContext context) async {
    setState(() => isLoading = true);

    DateTime now = DateTime.now();
    DateTime limite = DateTime(now.year, now.month, now.day, 8, 30);
    String heureArrivee = DateFormat('HH:mm').format(now);



    final authBox = Hive.box('authBox');
    Users user =  authBox.get('stocker_user');
    user.id;
    if (now.isBefore(limite)) {
           final Map<String,dynamic> pointage = {
        'idemploye':user.id,
        'date_heure': now.toIso8601String(),
        'type': "Arrivee",

      };
      Logger().i(pointage);

           await Supabase.instance.client.from('pointage').insert(pointage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.all(25),
          content: Text("Présence marquée avec succès à $heureArrivee",style: TextStyle(fontSize: 20),),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          TextEditingController motifController = TextEditingController();
          bool isLoading = false;

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shadowColor: Colors.blue,
                title: Text("Motif de retard"),
                content: TextField(
                  cursorColor: Colors.blue,
                  controller: motifController,
                  decoration: InputDecoration(
                    hintText: "Entrez votre motif",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Annuler", style: TextStyle(color: Colors.blue)),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      String motif = motifController.text.trim();
                      if (motif.isNotEmpty) {
                        setState(() => isLoading = true);

                        final pointage = {
                          'idemploye': user.id,
                          'date_heure': now.toIso8601String(),
                          'type': "Arrivee",
                          'statut': 'En attente',
                          'motif': motif,
                        };

                        Logger().i(pointage);

                        await Supabase.instance.client
                            .from('pointage')
                            .insert(pointage);

                        setState(() => isLoading = false);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            padding: EdgeInsets.all(25),
                            content: Text(
                              "Présence marquée avec succès à $heureArrivee",
                              style: TextStyle(fontSize: 20),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                        : Text("Envoyer", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              );
            },
          );
        },
      );
    }

  }

  Future<void> marquerDepart(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime limite = DateTime(now.year, now.month, now.day, 18, 30);
    String heureDepart = DateFormat('HH:mm').format(now);

    final authBox = Hive.box('authBox');
    Users user =  authBox.get('stocker_user');
    user.id;
    if (now.isBefore(limite)) {
      final Map<String,dynamic> pointage = {
        'idemploye':user.id,
        'date_heure': now.toIso8601String(),
        'type': "Départ",

      };
      Logger().i(pointage);

      await Supabase.instance.client.from('pointage').insert(pointage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.all(25),
          content: Text("Départ marqué avec succès à $heureDepart",style: TextStyle(fontSize: 20),),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          TextEditingController raisonController = TextEditingController();
          bool isLoading = false;

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shadowColor: Colors.blue,
                title: Text("Motif d'heure supplémentaire"),
                content: TextField(
                  cursorColor: Colors.blue,
                  controller: raisonController,
                  decoration: InputDecoration(
                    hintText: "Entrez votre motif",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Annuler", style: TextStyle(color: Colors.blue)),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      String motif = raisonController.text.trim();
                      if (motif.isNotEmpty) {
                        setState(() => isLoading = true);

                        final pointage = {
                          'idemploye': user.id,
                          'date_heure': now.toIso8601String(),
                          'type': "Départ",
                          'statut': 'En attente',
                          'raison': motif,
                        };

                        Logger().i(pointage);
                        await Supabase.instance.client
                            .from('pointage')
                            .insert(pointage);

                        setState(() => isLoading = false);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            padding: EdgeInsets.all(25),
                            content: Text(
                              "Départ marqué avec succès : $motif",
                              style: TextStyle(fontSize: 20),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                        : Text("Envoyer", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              );
            },
          );
        },
      );

    }
  }
}
