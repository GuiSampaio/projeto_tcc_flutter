import 'package:cloud_firestore/cloud_firestore.dart';

class TipoCrime {
  String cid;
  String tipo;

  TipoCrime();

  TipoCrime.fromDocument(DocumentSnapshot document) {
    cid = document.id;
    tipo = document.data()["tipo"];
  }

  Map<String, dynamic> toMap() {
    return {"id": cid, "tipo": tipo};
  }
}
