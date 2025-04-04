import 'package:flutter/material.dart';
import 'package:projets/user.dart';
import 'admin_page.dart';
import 'package:intl/intl.dart';
import 'connect_admin.dart';


class Accueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Waouh Monde",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),),
          SizedBox(height: 40),
          CircleAvatar(
            radius: 70,
            backgroundColor: Colors.white, 
            backgroundImage: AssetImage('assets/images/logo1.png'),
          ),
          SizedBox(height: 25),
          MenuButton(icon: Icons.login, text: "Marquer arrivée",
              onTap: () => marquerArrivee(context)
          ),
          SizedBox(height:25 ),
          MenuButton(icon: Icons.logout, text: "Marquer départ",onTap: () => marquerDepart(context)
          ),
          SizedBox(height:25 ),
          MenuButton(icon: Icons.dashboard, text: "Consulter tableau de bord personnel", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Presence() ),
            );
          }),
          SizedBox(height:25 ),
          MenuButton(icon: Icons.analytics, text: "Consulter tableau de bord", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          }),
          SizedBox(height:25),

          MenuButton(icon: Icons.person, text: "Créer compte utilisateur", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateEmployee()),
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

  const MenuButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
