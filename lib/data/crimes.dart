
import 'package:cloud_firestore/cloud_firestore.dart';

class Crimes {
  String cid;
  String descricao;


Crimes();

  Crimes.fromDocument(DocumentSnapshot document) {
    cid = document.id;
    descricao = document.data()["descricao"];
  }

  Map<String, dynamic> toMap() {
    return {
      "descricao": descricao
    };
  }

}