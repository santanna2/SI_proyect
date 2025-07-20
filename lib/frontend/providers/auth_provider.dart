import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  String? _userId;
  String? get userId => _userId;

  /// ¿Hay un usuario autenticado?
  bool get isAuthenticated => _userId != null;

  // Cambia esto para que currentUser devuelva el id si está autenticado
  String? get currentUser => _userId;

  AuthProvider() {
    restoreSession();
  }

  Future<void> restoreSession() async {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    if (user != null) {
      _userId = user.id;
    } else {
      _userId = null;
    }
    notifyListeners();
  }

  /// Inicia sesión con email y contraseña.
  /// Devuelve true si el login fue exitoso.
  Future<bool> login(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (res.user != null) {
        _userId = res.user!.id;
        notifyListeners();
        return true;
      } else {
        _userId = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _userId = null;
      notifyListeners();
      return false;
    }
  }

  /// Registra un nuevo usuario.
  /// Devuelve true si el registro fue exitoso.
  Future<bool> register(String email, String password) async {
    final res = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
    );
    if (res.user != null) {
      _userId = res.user!.id;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Cierra la sesión actual.
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _userId = null;
    notifyListeners(); // <-- Esto es fundamental
  }
}
