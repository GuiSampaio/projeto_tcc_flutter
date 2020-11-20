import 'package:flutter/material.dart';
import 'package:rota_segura/model/report_model.dart';
import 'package:rota_segura/model/user_model.dart';
import 'package:rota_segura/telas/Report_screen_content.dart';
import 'package:scoped_model/scoped_model.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    final List<String> itensMenu = ["Configurações", "Deslogar"];
    _escolhaMenuItem(String escolha) {
      switch (escolha) {
        case "Deslogar":
          UserModel.of(context).signOut();
          break;
        case "Configurações":
          break;
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Reportar Local"),
          actions: [
            PopupMenuButton<String>(
              //child: Sco,
              onSelected: _escolhaMenuItem,
              itemBuilder: (context) {
                return itensMenu.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: ScopedModel<ReportModel>(
          model: ReportModel(),
          child: ScopedModelDescendant<ReportModel>(
              builder: (context, child, model) {
            if (model.isLoading && UserModel.of(context).isLoggedIn())
              return Center(
                child: CircularProgressIndicator(),
              );
            else if (!UserModel.of(context).isLoggedIn()) {
              return Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      (Icons.report_off),
                      size: 80.0,
                      color: Colors.redAccent,
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Text(
                      "Faça o login para reportar um local!",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(color: Colors.grey)),
                      child: Text(
                        "Entrar",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      textColor: Colors.black,
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.pushNamed(context, "/loginscreen");
                      },
                    ),
                  ],
                ),
              );
            } else {
              return ReportScreenContent();
            }
          }),
        ));
  }
}
