import 'package:flutter/material.dart';
import 'package:projets/user.dart';
import 'admin_page.dart';
import 'package:intl/intl.dart';


class Accueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(child: Text("Waouh Monde"),)
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/image/img2.jpg'),
          ),
          SizedBox(height: 30),
          MenuButton(icon: Icons.login, text: "Marquer arrivée", onTap: () => marquerArrivee(context)),
          MenuButton(icon: Icons.logout, text: "Marquer départ", onTap: () => marquerDepart(context)),
          MenuButton(icon: Icons.dashboard, text: "Consulter tableau de bord personnel", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Presence() ),
            );
          }),
          MenuButton(icon: Icons.analytics, text: "Consulter tableau de bord", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Rapport()),
            );
          }),
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
      SnackBar(content: Text("Présence marquée avec succès à $heureArrivee")),
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
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                String motif = motifController.text.trim();
                if (motif.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Motif envoyé à l'administrateur : $motif")),
                  );
                }
              },
              child: Text("Envoyer"),
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
      SnackBar(content: Text("Départ marqué avec succès à $heureDepart")),
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
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                String motif = motifController.text.trim();
                if (motif.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Motif envoyé à l'administrateur : $motif")),
                  );
                }
              },
              child: Text("Envoyer"),
            ),
          ],
        );
      },
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  MenuButton({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }
}
