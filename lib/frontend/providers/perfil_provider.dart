import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _perfil;

  Map<String, dynamic>? get perfil => _perfil;

  Future<void> cargarPerfil(String userId) async {
    final response = await _supabase
        .from('usuario')
        .select()
        .eq('id', userId)
        .single();

    _perfil = response;
    notifyListeners();
  }

  Future<void> actualizarPerfil(Map<String, dynamic> datos) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('perfiles').upsert({
      ...datos,
      'user_id': userId,
    });

    _perfil = datos;
    notifyListeners();
  }

  void limpiarPerfil() {
    _perfil = null;
    notifyListeners();
  }
}
