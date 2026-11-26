import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../data/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        _errorMessage = 'Usuario no encontrado con este correo electrónico.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.password != password) {
        _errorMessage = 'Contraseña incorrecta. Por favor verifica tus datos.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        _errorMessage = 'Ya existe una cuenta registrada con este correo.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newUser = UserModel(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
        role: 'client',
      );

      final id = await _dbHelper.createUser(newUser);
      _currentUser = newUser.copyWith(id: id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al registrar la cuenta: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        _errorMessage = 'No se encontró ninguna cuenta registrada con este correo.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await _dbHelper.updateUserPassword(email, newPassword);
      if (!success) {
        _errorMessage = 'No se pudo actualizar la contraseña. Inténtalo de nuevo.';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error al restablecer la contraseña: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
