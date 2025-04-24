// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utilisateur.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsersAdapter extends TypeAdapter<Users> {
  @override
  final int typeId = 0;

  @override
  Users read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Users(
      email: fields[0] as String?,
      id: fields[1] as String,
      nom: fields[2] as String,
      prenom: fields[3] as String,
      poste: fields[4] as String,
      createdAt: fields[5] as String,
      type: fields[6] as String,
      datenaissance: fields[7] as String,
      adresse: fields[8] as String,
      tel: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Users obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.nom)
      ..writeByte(3)
      ..write(obj.prenom)
      ..writeByte(4)
      ..write(obj.poste)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.datenaissance)
      ..writeByte(8)
      ..write(obj.adresse)
      ..writeByte(9)
      ..write(obj.tel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
