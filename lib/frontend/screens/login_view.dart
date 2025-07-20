import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_de_tramites_unap/frontend/providers/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;

  Future<void> _login() async {
    setState(() => _cargando = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ok = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _cargando = false);

    if (!ok) {
      await showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Error'),
          content: Text('Credenciales incorrectas'),
        ),
      );
      _emailController.clear();
      _passwordController.clear();
      setState(() {}); // Fuerza el rebuild para limpiar los campos
    }
    // Si ok == true, el cambio de pantalla lo maneja app.dart automáticamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            _cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Iniciar sesión'),
                  ),
          ],
        ),
      ),
    );
  }
}
