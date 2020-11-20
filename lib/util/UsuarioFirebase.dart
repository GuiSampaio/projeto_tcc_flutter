import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rota_segura/data/Usuario.dart';

class UsuarioFirebase {
  static User getUsuarioAtual() {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser;
  }

  static Future<Usuario> getDadosUsuarioLogado() async {
    User user = getUsuarioAtual();
    String idUsuario = user.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;

    DocumentSnapshot snapshot =
        await db.collection("users").doc(idUsuario).get();

    Map<String, dynamic> dados = snapshot.data();
    String email = dados["email"];
    String nome = dados["nome"];
    String users = dados["user"];

    Usuario usuario = Usuario();
    usuario.idUsuario = idUsuario;
    usuario.email = email;
    usuario.nome = nome;
    usuario.user = users;

    return usuario;
  }
}
