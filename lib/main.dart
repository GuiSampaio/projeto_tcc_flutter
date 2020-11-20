import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rota_segura/model/maps_model.dart';
import 'package:rota_segura/model/user_model.dart';
import 'package:rota_segura/telas/Home.dart';
import 'package:rota_segura/telas/Rotas.dart';
import 'package:scoped_model/scoped_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: UserModel(),
      child: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          return ScopedModel<MapsModel>(
            model: MapsModel(model),
            child: MaterialApp(
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              supportedLocales: [const Locale('pt', 'BR')],
              home: Home(),
              theme: ThemeData(
                  primarySwatch: Colors.blue, primaryColor: Colors.white),
              initialRoute: "/",
              onGenerateRoute: Rotas.gerarRotas,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
