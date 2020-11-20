import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:rota_segura/data/crimes.dart';
import 'package:rota_segura/data/tipo_crime.dart';
import 'package:rota_segura/model/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class ReportModel extends Model {
  UserModel user;
  bool isLoading = false;
  List<TipoCrime> tipoCrimes = [];
  List<Crimes> crimes = [];

  static ReportModel of(BuildContext context) =>
      ScopedModel.of<ReportModel>(context);

  getTipoCrime() async {
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("tipo_crime").get();

    return tipoCrimes = query.docs.map((doc) => TipoCrime.fromDocument(doc)).toList();
  }

  getCrimes(value) async {
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("crime").doc(value).collection("crimes").get();

    return crimes = query.docs.map((doc) => Crimes.fromDocument(doc)).toList();
  }
}
