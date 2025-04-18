import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:projets/presence_page.dart';
import 'package:projets/utilisateur.dart';
import 'package:projets/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_page.dart';
import 'package:intl/intl.dart';
import 'connect_admin.dart';
import 'constants.dart';
import 'menu_bouton.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'user.dart';

class Accueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 110,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/logo1.png'),
          ),
          MenuButton(
            icon: Icons.login,
            text: "Marquer arrivée",
            onTap:
                () =>
                    _verifierPositionEtMarquerDepart(context, estArrivee: true),
          ),
          MenuButton(
            icon: Icons.logout,
            text: "Marquer départ",
            onTap:
                () => _verifierPositionEtMarquerDepart(
                  context,
                  estArrivee: false,
                ),
          ),
          MenuButton(
            icon: Icons.dashboard,
            text: "Consulter tableau de bord personnel",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PresenceUser()),
              );
            },
          ),
          MenuButton(
            icon: Icons.analytics,
            text: "Consulter tableau de bord",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminDashboard()),
              );
            },
          ),
          MenuButton(
            icon: Icons.person,
            text: "Créer compte utilisateur",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateEmployee()),
              );
            },
          ),
        ],
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
          SnackBar(content: Text("Permission de localisation refusée")),
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
            content: Text(
              "Vous êtes à ${(distance).toStringAsFixed(0)} mètres de l'entreprise. Veuillez vous rendre dans l'entreprise.",
            ),
          ),
        );
      }
    } catch (e) {
      Logger().e(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de géolocalisation: ${e.toString()}")),
      );
    }
  }

  Future<void> marquerArrivee(BuildContext context) async {
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
             'statut':'En attente',
      };
      Logger().i(pointage);

           await Supabase.instance.client.from('pointage').insert(pointage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Présence marquée avec succès à $heureArrivee"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
          showDialog(
        context: context,
        builder: (context) {
          TextEditingController motifController = TextEditingController();
          return AlertDialog(
            title: Text("Motif de retard"),
            content: TextField(
              controller: motifController,
              decoration: InputDecoration(hintText: "Entrez votre motif"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler", style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () async {
                  String motif = motifController.text.trim();
                  if (motif.isNotEmpty) {
                    Navigator.pop(context);

                    final pointage = {
                      'idemploye':user.id,
                      'date_heure': now.toIso8601String(),
                      'type': "Arrivee",
                      'statut':'En attente',
                      'motif':motifController.text,
                    };
                    Logger().i(pointage);
                    await Supabase.instance.client.from('pointage').insert(pointage);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Présence marquée avec succès à $heureArrivee",
                        ),
                      ),
                    );
                  }
                },
                child: Text("Envoyer", style: TextStyle(color: Colors.blue)),
              ),
            ],
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
        'statut':'En attente',
      };
      Logger().i(pointage);

      await Supabase.instance.client.from('pointage').insert(pointage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Départ marqué avec succès à $heureDepart"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          TextEditingController raisonController = TextEditingController();
          return AlertDialog(
            title: Text("Motif d'heure supplémentaire"),
            content: TextField(
              controller: raisonController,
              decoration: InputDecoration(hintText: "Entrez votre motif"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler", style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () async {
                  String motif = raisonController.text.trim();
                  if (motif.isNotEmpty) {
                    Navigator.pop(context);
                    final pointage = {
                      'idemploye':user.id,
                      'date_heure': now.toIso8601String(),
                      'type': "Départ",
                      'statut':'En attente',
                      'raison':raisonController.text,
                    };
                    Logger().i(pointage);
                    await Supabase.instance.client.from('pointage').insert(pointage);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Départ marqué avec succès : $motif",
                        ),
                      ),
                    );

                  }
                },
                child: Text("Envoyer", style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );
    }
  }
}
