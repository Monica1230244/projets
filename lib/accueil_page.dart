import 'package:flutter/material.dart';
import 'package:projets/user.dart';
import 'admin_page.dart';
import 'package:intl/intl.dart';
import 'connect_admin.dart';
import 'menu_bouton.dart';


class Accueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
            onTap: () => marquerArrivee(context),
          ),
          MenuButton(
            icon: Icons.logout,
            text: "Marquer départ",
            onTap: () => marquerDepart(context),
          ),
          MenuButton(
            icon: Icons.dashboard,
            text: "Consulter tableau de bord personnel",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Presence()),
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
    );
  }
}

void marquerArrivee(BuildContext context) {
  DateTime now = DateTime.now();
  DateTime limite = DateTime(now.year, now.month, now.day, 8, 30);
  String heureArrivee = DateFormat('HH:mm').format(now);

  if (now.isBefore(limite)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Présence marquée avec succès à $heureArrivee"),
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Annuler",style: TextStyle(color: Colors.blue),),
            ),
            TextButton(
              onPressed: () {
                String motif = motifController.text.trim();
                if (motif.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Motif envoyé à l'administrateur : $motif"),
                    ),
                  );
                }
              },
              child: Text("Envoyer",style: TextStyle(color: Colors.blue),),
            ),
          ],
        );
      },
    );
  }
}

void marquerDepart(BuildContext context) {
  DateTime now = DateTime.now();
  DateTime limite = DateTime(now.year, now.month, now.day, 18, 30);
  String heureDepart = DateFormat('HH:mm').format(now);

  if (now.isBefore(limite)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Départ marqué avec succès à $heureDepart"),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController motifController = TextEditingController();
        return AlertDialog(
          title: Text("Motif d'heure supplémentaire"),
          content: TextField(
            controller: motifController,
            decoration: InputDecoration(hintText: "Entrez votre motif"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Annuler",style: TextStyle(color: Colors.blue),),
            ),
            TextButton(
              onPressed: () {
                String motif = motifController.text.trim();
                if (motif.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Motif envoyé à l'administrateur : $motif"),
                    ),
                  );
                }
              },
              child: Text("Envoyer",style: TextStyle(color: Colors.blue),),
            ),
          ],
        );
      },
    );
  }
}

