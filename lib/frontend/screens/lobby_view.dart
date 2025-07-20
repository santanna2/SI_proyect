import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'usuario_view.dart';

class LobbyView extends StatefulWidget {
  const LobbyView({super.key});

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  String _selected = 'pagina principal';

  void _navigate(String option) {
    setState(() {
      _selected = option;
    });
    if (option == 'informacion academica') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UsuarioView()),
      );
    } else if (option == 'pagina principal') {
      // Ya estamos en el lobby, solo actualiza el centro si tienes lógica extra
      // Aquí podrías resetear el estado si fuera necesario
    }
  }

  Widget _buildMainPanel() {
    switch (_selected) {
      case 'pagina principal':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MainPanelButton(
              text: 'MANUAL DE USUARIO',
              color: const Color(0xFF333333),
              textColor: Colors.white,
            ),
            const SizedBox(height: 24),
            _MainPanelButton(
              text: 'INFORMACION DE USUARIO',
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF9C4), Color(0xFFFFE0E0)],
              ),
              textColor: Colors.black87,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UsuarioView()),
                );
              },
            ),
            const SizedBox(height: 24),
            _MainPanelButton(
              text: 'NOTIFICACIONES',
              color: const Color(0xFF333333),
              textColor: Colors.white,
            ),
            const SizedBox(height: 24),
            _MainPanelButton(
              text: 'OTROS',
              color: const Color(0xFF333333),
              textColor: Colors.white,
            ),
          ],
        );
      // Puedes agregar más casos para otras opciones del menú si lo deseas
      default:
        return const Center(child: Text('Selecciona una opción del menú'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores base
    const Color darkGrey = Color(0xFF333333);
    const Color lightGrey = Color(0xFFF5F5F5);
    const Color veryLightGrey = Color(0xFFFAFAFA);
    const Color activeRed = Colors.red;
    const Color pastelYellow = Color(0xFFFFF9C4);
    const Color pastelPink = Color(0xFFFFE0E0);

    return Scaffold(
      backgroundColor: lightGrey,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: veryLightGrey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SidebarButton(
                  'pagina principal',
                  active: _selected == 'pagina principal',
                  onPressed: () => _navigate('pagina principal'),
                ),
                _SidebarButton(
                  'informacion academica',
                  active: _selected == 'informacion academica',
                  onPressed: () => _navigate('informacion academica'),
                ),
                _SidebarButton('matriculas'),
                _SidebarButton('tramites'),
                _SidebarButton('cursos'),
                _SidebarButton('pagos'),
                const SizedBox(height: 24),
                _SidebarButton(
                  'salir',
                  icon: Icons.logout,
                  onPressed: () async {
                    await Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  color: lightGrey,
                  child: Row(
                    children: [
                      // Logo/avatar
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: darkGrey,
                        child: const Icon(Icons.school, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 24),
                      // Two horizontal lines (titles)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 8,
                            color: Colors.black,
                            margin: const EdgeInsets.only(bottom: 8),
                          ),
                          Container(
                            width: 80,
                            height: 8,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Profile icon as button
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const UsuarioView()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: darkGrey,
                          child: const Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main panel
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      children: [
                        // Main buttons/groups
                        Expanded(
                          child: _buildMainPanel(),
                        ),
                        // Decorative star icon
                        Container(
                          margin: const EdgeInsets.only(left: 32),
                          child: Icon(
                            Icons.star,
                            color: darkGrey,
                            size: 64,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final String text;
  final bool active;
  final IconData? icon;
  final VoidCallback? onPressed;

  const _SidebarButton(this.text, {this.active = false, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextButton.icon(
        onPressed: onPressed ?? () {},
        icon: icon != null
            ? Icon(icon, color: active ? Colors.red : Colors.black54)
            : const SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(
            color: active ? Colors.red : Colors.black87,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
            fontFamily: 'Sans-serif',
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: active ? Colors.red.withOpacity(0.08) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _MainPanelButton extends StatelessWidget {
  final String text;
  final Color? color;
  final Gradient? gradient;
  final Color textColor;
  final VoidCallback? onTap;

  const _MainPanelButton({
    required this.text,
    this.color,
    this.gradient,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: color,
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sans-serif',
          ),
        ),
      ),
    );
  }
}
