import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'frontend/providers/auth_provider.dart';
import 'frontend/providers/perfil_provider.dart';
import 'backend/services/supabase_service.dart';
import 'frontend/screens/login_view.dart';
import 'frontend/screens/home_view.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _error = null;
      _initialized = false;
    });
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await SupabaseService.init();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo inicializar la app. Verifica tu conexión a internet.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 24),
                  Text(
                    'No se pudo conectar a internet.\n\n'
                    'Por favor, verifica tu conexión y vuelve a intentarlo.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _initialize,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PerfilProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sistema de Trámites UNAP',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const LoginView();
    } else {
      return const HomeView();
    }
  }
}
