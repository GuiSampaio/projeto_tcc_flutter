import 'package:flutter/cupertino.dart';
import 'package:rota_segura/model/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class MapsModel extends Model {
  UserModel user;
  bool isLoading = false;

  MapsModel(this.user) {
    if (user.isLoggedIn()) {}
  }

  static MapsModel of(BuildContext context) =>
      ScopedModel.of<MapsModel>(context);
}
