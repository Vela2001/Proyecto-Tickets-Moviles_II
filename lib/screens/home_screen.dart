import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_moviles2/screens/login_screen.dart';
import 'package:proyecto_moviles2/screens/create_ticket_screen.dart';
import 'package:proyecto_moviles2/screens/view_tickets_screen.dart';
import 'package:proyecto_moviles2/screens/admin_tickets_screen.dart';
import 'package:proyecto_moviles2/services/ticket_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TicketService _ticketService = TicketService();
  User? _user;
  String _userRole = '';
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndRole();
  }

  Future<void> _loadUserAndRole() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      // Usuario no autenticado, redirigir a login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userRole = (userDoc.data()?['rol'] ?? '').toString();
          _isLoadingRole = false;
        });
      } else {
        setState(() {
          _userRole = '';
          _isLoadingRole = false;
        });
      }
    } catch (e) {
      setState(() {
        _userRole = '';
        _isLoadingRole = false;
      });
      print('Error al cargar rol: $e');
    }
  }

  bool get isAdmin => _userRole.toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return Scaffold(
        appBar: AppBar(title: Text('Sistema de Tickets')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sistema de Tickets'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionButton(
              icon: Icons.add,
              label: 'Crear Ticket',
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateTicketScreen()),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.list_alt,
              label: 'Mis Tickets',
              color: Colors.green,
              onPressed: () {
                if (_user == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewTicketsScreen(userId: _user!.uid),
                  ),
                );
              },
            ),
            if (isAdmin)
              _buildActionButton(
                icon: Icons.admin_panel_settings,
                label: 'Administrar Tickets',
                color: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminTicketsScreen()),
                  );
                },
              ),
            _buildActionButton(
              icon: Icons.search,
              label: 'Buscar Tickets',
              color: Colors.purple,
              onPressed: () => _showSearchDialog(context),
            ),
            if (isAdmin)
              _buildActionButton(
                icon: Icons.analytics,
                label: 'Reportes',
                color: Colors.red,
                onPressed: () => _generateReports(context),
              ),
            _buildActionButton(
              icon: Icons.settings,
              label: 'Configuración',
              color: Colors.grey,
              onPressed: () => _showSettings(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateTicketScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Crear Ticket Rápido',
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buscar Tickets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Título del Ticket',
                hintText: 'Ingrese el título del ticket',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final searchQuery = _searchController.text.trim();
                if (searchQuery.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor ingrese un valor para buscar')),
                  );
                  return;
                }
                if (_user == null) return;

                try {
                  final tickets = await _ticketService.buscarTicketsPorTituloYUsuarioLocal(searchQuery, _user!.uid);


                  if (tickets.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No se encontraron tickets con ese título')),
                    );
                  } else {
                    Navigator.pop(context); // Cierra el diálogo antes de navegar
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewTicketsScreen(
                          userId: _user!.uid,
                          tickets: tickets,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al buscar tickets: $e')),
                  );
                }
              },
              child: Text('Buscar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReports(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generando reportes...')),
    );
    // Aquí agrega la lógica para generar reportes
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                // Navegar a perfil si tienes esa pantalla
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notificaciones'),
              onTap: () {
                Navigator.pop(context);
                // Navegar a notificaciones si tienes esa pantalla
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Ayuda'),
              onTap: () {
                Navigator.pop(context);
                // Navegar a ayuda si tienes esa pantalla
              },
            ),
          ],
        ),
      ),
    );
  }
}
