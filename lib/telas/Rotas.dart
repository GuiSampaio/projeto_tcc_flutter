import 'package:flutter/material.dart';
import 'package:rota_segura/telas/Home.dart';
import 'package:rota_segura/telas/Login_screen.dart';
import 'package:rota_segura/telas/Report_screen.dart';
import 'package:rota_segura/telas/Signup_screen.dart';

class Rotas {
  static Route<dynamic> gerarRotas(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Home());
      case "/reportscreen":
        return MaterialPageRoute(builder: (_) => ReportScreen());
      case "/loginscreen":
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case "/signupscreen":
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      default:
        return _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada!"),
        ),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
