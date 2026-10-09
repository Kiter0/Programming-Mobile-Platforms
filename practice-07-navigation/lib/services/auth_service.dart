
import 'package:flutter/foundation.dart';

enum UserRole { guest, user, admin }

class AuthService extends ChangeNotifier {
  UserRole _role = UserRole.guest;

  UserRole get role => _role;

  bool get isLoggedIn => _role != UserRole.guest;

  bool get isAdmin => _role == UserRole.admin;

  void loginAsUser() {
    _role = UserRole.user;
    notifyListeners();
  }

  void loginAsAdmin() {
    _role = UserRole.admin;
    notifyListeners();
  }

  void logout() {
    _role = UserRole.guest;
    notifyListeners();
  }
}