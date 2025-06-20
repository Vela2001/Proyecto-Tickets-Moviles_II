import 'package:flutter/material.dart';
import 'package:proyecto_moviles2/model/usuario_model.dart';
import 'package:proyecto_moviles2/services/usuario_service.dart';
import 'package:proyecto_moviles2/screens/admin_create_user_screen.dart';

class AdminUsersScreen extends StatelessWidget {
  final UsuarioService _usuarioService = UsuarioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administrar Usuarios')),
      body: StreamBuilder<List<Usuario>>(
        stream: _usuarioService.obtenerUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('No hay usuarios registrados'));

          final usuarios = snapshot.data!;
          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return ListTile(
                title: Text(usuario.nombreCompleto),
                subtitle: Text('${usuario.username} - ${usuario.rol}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _mostrarFormularioEditar(context, usuario);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmar = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('¿Eliminar usuario?'),
                            content: Text(
                                '¿Estás seguro de eliminar a ${usuario.nombreCompleto}?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Cancelar')),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Eliminar')),
                            ],
                          ),
                        );
                        if (confirmar == true) {
                          await _usuarioService.eliminarUsuario(usuario.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Crear nuevo usuario',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminCreateUserScreen()),
          );
        },
      ),
    );
  }

  void _mostrarFormularioEditar(BuildContext context, Usuario usuario) {
    final nombreController =
        TextEditingController(text: usuario.nombreCompleto);
    final usernameController = TextEditingController(text: usuario.username);
    final emailController = TextEditingController(text: usuario.email);
    String rolSeleccionado = usuario.rol;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Editar Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre completo'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Correo electrónico'),
                  readOnly: true,
                  style: TextStyle(
                      color: Colors.grey), // opcional, para que se vea inactivo
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: rolSeleccionado,
                  decoration: InputDecoration(labelText: 'Rol'),
                  items: ['usuario', 'admin'].map((rol) {
                    return DropdownMenuItem(
                      value: rol,
                      child: Text(rol),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => rolSeleccionado = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              child: Text('Guardar'),
              onPressed: () async {
                final actualizado = Usuario(
                  id: usuario.id,
                  username: usernameController.text.trim(),
                  email: usuario.email,
                  nombreCompleto: nombreController.text.trim(),
                  fechaCreacion: usuario.fechaCreacion,
                  ultimoLogin: usuario.ultimoLogin,
                  emailVerificado: usuario.emailVerificado,
                  rol: rolSeleccionado,
                );

                await _usuarioService.actualizarUsuario(actualizado);
                Navigator.pop(context);
                usernameController.dispose();
                nombreController.dispose();
                emailController.dispose();
              },
            ),
          ],
        ),
      ),
    );
  }
}
