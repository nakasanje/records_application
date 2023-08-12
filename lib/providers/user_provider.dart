import 'package:flutter/widgets.dart';
import '../constants/auth_methods.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  UserModel _user = UserModel(
    email: "",
    uid: "",
    username: "",
    photoUrl: "",
    role: "",
  );
  final AuthMethods _authMethods = AuthMethods();

  UserModel get getUser => _user;

  Future<void> refreshUser() async {
    UserModel user = await _authMethods.getUserDetails();
    _user = user;

    notifyListeners();
  }
}
