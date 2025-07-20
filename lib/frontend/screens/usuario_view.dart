import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/perfil_provider.dart';
import '../providers/auth_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:html' as html show window, document, AnchorElement, Blob, Url;

class UsuarioView extends StatefulWidget {
  const UsuarioView({super.key});

  @override
  State<UsuarioView> createState() => _UsuarioViewState();
}

class _UsuarioViewState extends State<UsuarioView> {
  bool _loading = true;
  bool _editMode = false;
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPerfil());
  }

  Future<void> _loadPerfil() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    final userId = authProvider.userId;
    if (userId != null) {
      await perfilProvider.cargarPerfil(userId);
    }
    final perfil = perfilProvider.perfil;
    if (perfil != null) {
      _nombreController.text = perfil['nombre']?.toString() ?? '';
      _apellidoController.text = perfil['apellido']?.toString() ?? '';
      _emailController.text = perfil['email']?.toString() ?? '';
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _guardarCambios() async {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;
    if (userId != null) {
      await perfilProvider.actualizarPerfil({
        'id': userId,
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'email': _emailController.text.trim(),
      });
      setState(() {
        _editMode = false;
      });
    }
  }

  void _cancelarEdicion() {
    final perfil = Provider.of<PerfilProvider>(context, listen: false).perfil;
    _nombreController.text = perfil?['nombre']?.toString() ?? '';
    _apellidoController.text = perfil?['apellido']?.toString() ?? '';
    _emailController.text = perfil?['email']?.toString() ?? '';
    setState(() {
      _editMode = false;
    });
  }

  Future<void> _exportarDatos(Map<String, dynamic>? perfil) async {
    if (perfil == null) return;
    final jsonString = jsonEncode(perfil);

    try {
      if (!kIsWeb) {
        // Código para móvil (sin cambios)
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Permiso denegado'),
              content: const Text('No se concedió el permiso de almacenamiento.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
          return;
        }
        
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/usuario_export.json');
        await file.writeAsString(jsonString);
        
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Exportación exitosa'),
            content: Text('Archivo guardado en:\n${file.path}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      } else {
        // Código para web - descarga el archivo JSON
        final bytes = Uint8List.fromList(jsonString.codeUnits);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'usuario_export.json';
        
        html.document.body!.children.add(anchor);
        anchor.click();
        
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Exportación exitosa'),
            content: const Text('El archivo JSON se ha descargado correctamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('No se pudo guardar el archivo.\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF8F8F8);
    const Color darkGrey = Color(0xFF333333);
    const Color lightGrey = Color(0xFFE0E0E0);

    final perfil = Provider.of<PerfilProvider>(context).perfil;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: darkGrey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  const Text(
                    'INFORMACION ACADEMICA',
                    style: TextStyle(
                      color: darkGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: lightGrey,
                    child: const Icon(Icons.person, color: darkGrey, size: 22),
                  ),
                ],
              ),
            ),
            // Cuerpo principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          // Columna de campos
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ProfileField(
                                  label: 'CÓDIGO:',
                                  value: perfil?['codigo']?.toString() ?? '',
                                ),
                                const SizedBox(height: 18),
                                _ProfileField(
                                  label: 'NOMBRE(S):',
                                  value: _editMode
                                      ? null
                                      : perfil?['nombre']?.toString() ?? '',
                                  controller: _editMode ? _nombreController : null,
                                  enabled: _editMode,
                                ),
                                const SizedBox(height: 18),
                                _ProfileField(
                                  label: 'APELLIDOS:',
                                  value: _editMode
                                      ? null
                                      : perfil?['apellido']?.toString() ?? '',
                                  controller: _editMode ? _apellidoController : null,
                                  enabled: _editMode,
                                ),
                                const SizedBox(height: 18),
                                _ProfileField(
                                  label: 'CREDITOS:',
                                  value: perfil?['credits']?.toString() ?? '',
                                ),
                                const SizedBox(height: 18),
                                _ProfileField(
                                  label: 'CICLO:',
                                  value: perfil?['ciclo']?.toString() ?? '',
                                ),
                                const SizedBox(height: 18),
                                _ProfileField(
                                  label: 'E-MAIL:',
                                  value: _editMode
                                      ? null
                                      : perfil?['email']?.toString() ?? '',
                                  controller: _editMode ? _emailController : null,
                                  enabled: _editMode,
                                ),
                              ],
                            ),
                          ),
                          // Estrella decorativa
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Icon(
                                Icons.star,
                                size: 100,
                                color: lightGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            // Botones abajo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: _editMode
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _cancelarEdicion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                          ),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _guardarCambios,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Guardar'),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _editMode = true;
                            });
                          },
                          child: const Text('Modificar'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => _exportarDatos(perfil),
                          child: const Text('Exportar datos'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String? value;
  final TextEditingController? controller;
  final bool enabled;
  const _ProfileField({
    required this.label,
    this.value,
    this.controller,
    this.enabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: controller != null
          ? TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                labelText: null,
                hintText: label,
              ),
              style: const TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.normal,
                fontSize: 15,
                letterSpacing: 1,
              ),
            )
          : Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value ?? '',
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }
}
