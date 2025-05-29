import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  static const _authKey = 'user_auth';
  bool _isAuthenticated = false;
  String? _currentUserEmail;

  // Добавляем в класс
  AuthService() {
    _loadAuthState();
  }
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.containsKey(_authKey);
      if (_isAuthenticated) {
        _currentUserEmail = prefs.getString(_authKey)?.split(':').first;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки состояния аутентификации: $e');
    }
  }

  Future<void> register(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authKey, '$email:$password');
      _isAuthenticated = true;
      _currentUserEmail = email;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка регистрации: $e');
      throw Exception('Не удалось сохранить данные');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString(_authKey);

      if (authData == null || authData != '$email:$password') {
        throw Exception('Неверные учетные данные');
      }

      _isAuthenticated = true;
      _currentUserEmail = email;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка входа: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authKey);
      _isAuthenticated = false;
      _currentUserEmail = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка выхода: $e');
      throw Exception('Не удалось выйти');
    }
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserEmail => _currentUserEmail;
}
