import 'package:hive/hive.dart';

part 'utilisateur.g.dart';

@HiveType(typeId: 0)
class Users extends HiveObject {
  @HiveField(0)
  String? email;

  @HiveField(1)
  String id;

  @HiveField(2)
  String nom;

  @HiveField(3)
  String prenom;

  @HiveField(4)
  String poste;

  @HiveField(5)
  String createdAt;

  @HiveField(6)
  String type;

  @HiveField(7)
  String datenaissance;

  @HiveField(8)
  String adresse;

  @HiveField(9)
  int tel;



  Users({required this.email,
    required this.id,
    required this.nom,
    required this.prenom,
    required this.poste,
    required this.createdAt,
    required this.type,
    required this.datenaissance,
    required this.adresse,
    required this.tel,
  });



  factory Users.fromSupabase(Map<String, dynamic> data) {
    return Users(
      email: data['email'],
      id: data['id'],
      nom: data['nom'],
      prenom: data['prenom'],
      poste: data['idposte'],
      createdAt: data['created_at'],
      type: data['idtype'],
      datenaissance: data['datenaissance'],
      adresse: data['adresse'],
      tel: data['tel'],

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'poste': poste,
      'created_at': createdAt,
      'type': type,
      'datenaissance': datenaissance,
      'adresse': adresse,
      'tel': tel,
    };
  }
}






