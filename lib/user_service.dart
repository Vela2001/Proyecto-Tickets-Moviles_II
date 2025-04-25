import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.password,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return User(
      id: doc.id,
      name: data['nombre'] ?? '',
      password: data['clave'] ?? '',
    );
  }
}

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('usuarios');

  // Agregar un nuevo usuario
  Future<void> addUser({required String name, required String password}) async {
    await _usersCollection.add({
      'nombre': name,
      'clave': password,
      'fecha_creacion': FieldValue.serverTimestamp(),
    });
  }

  // Obtener lista de usuarios (en tiempo real)
  Stream<List<User>> getUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    });
  }

  // Eliminar un usuario
  Future<void> deleteUser(String userId) async {
    await _usersCollection.doc(userId).delete();
  }
}