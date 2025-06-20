import 'package:flutter/material.dart';
import 'package:proyecto_moviles2/services/auth_service.dart';
import 'package:proyecto_moviles2/model/usuario_model.dart';

class AdminCreateUserScreen extends StatefulWidget {
  @override
  _AdminCreateUserScreenState createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nombreCompletoController = TextEditingController();
  final _passwordController = TextEditingController();
  //final _adminPasswordController = TextEditingController();
  String _rolSeleccionado = 'usuario';

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _nombreCompletoController.dispose();
    _passwordController.dispose();
    //_adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      /*
      final admin = await AuthService().currentUser;
      final adminUsername = admin?.username;
      final adminPassword = _adminPasswordController.text.trim();

      if (adminUsername == null || adminPassword.isEmpty) {
        setState(() {
          _errorMessage = 'Credenciales del administrador no válidas';
        });
        return;
      }*/

      // 2. Crear el nuevo usuario (esto cierra sesión del admin)
      final nuevoUsuario = await AuthService().registerUser(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nombreCompleto: _nombreCompletoController.text.trim(),
        rol: _rolSeleccionado,
      );

      /*
      await AuthService().signInWithUsernameAndPassword(
        adminUsername,
        adminPassword,
      );*/

      // 4. Confirmación
      if (nuevoUsuario != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario creado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreCompletoController,
                  decoration: InputDecoration(labelText: 'Nombre completo'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Email inválido'
                      : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) => value != null && value.length >= 6
                      ? null
                      : 'Mínimo 6 caracteres',
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _rolSeleccionado,
                  decoration: InputDecoration(labelText: 'Rol'),
                  items: ['usuario', 'admin']
                      .map((rol) => DropdownMenuItem(
                            value: rol,
                            child: Text(rol),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _rolSeleccionado = value ?? 'usuario'),
                ),
                SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 10),
                /*SizedBox(height: 10),
                TextFormField(
                  controller: _adminPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Tu contraseña de administrador'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingresa tu contraseña para continuar'
                      : null,
                ),*/
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _crearUsuario,
                        child: Text('Crear Usuario'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
