import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_moviles2/screens/login_screen.dart';
import 'package:proyecto_moviles2/screens/create_ticket_screen.dart';
import 'package:proyecto_moviles2/screens/view_tickets_screen.dart';
import 'package:proyecto_moviles2/screens/admin_tickets_screen.dart';
import 'package:proyecto_moviles2/services/ticket_service.dart';

class HomeScreen extends StatelessWidget {
  final TicketService _ticketService = TicketService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isAdmin =
        false; // Implementa la lógica para verificar si es admin

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
            // Botón para crear nuevo ticket
            _buildActionButton(
              context,
              icon: Icons.add,
              label: 'Crear Ticket',
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTicketScreen()),
                );
              },
            ),

            // Botón para ver mis tickets
            _buildActionButton(
              context,
              icon: Icons.list_alt,
              label: 'Mis Tickets',
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewTicketsScreen(userId: user!.uid),
                  ),
                );
              },
            ),

            // Botón para administrar tickets (solo admin)
            if (isAdmin)
              _buildActionButton(
                context,
                icon: Icons.admin_panel_settings,
                label: 'Administrar Tickets',
                color: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminTicketsScreen()),
                  );
                },
              ),

            // Botón para buscar tickets
            _buildActionButton(
              context,
              icon: Icons.search,
              label: 'Buscar Tickets',
              color: Colors.purple,
              onPressed: () {
                _showSearchDialog(context);
              },
            ),

            // Botón para reportes/estadísticas
            if (isAdmin)
              _buildActionButton(
                context,
                icon: Icons.analytics,
                label: 'Reportes',
                color: Colors.red,
                onPressed: () {
                  _generateReports(context);
                },
              ),

            // Botón para configuración
            _buildActionButton(
              context,
              icon: Icons.settings,
              label: 'Configuración',
              color: Colors.grey,
              onPressed: () {
                _showSettings(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTicketScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Crear Ticket Rápido',
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
      builder: (context) {
        return AlertDialog(
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
                onPressed: () {
                  String searchQuery = _searchController.text.trim();
                  if (searchQuery.isNotEmpty) {
                    // Llamar a la función de búsqueda de tickets por título
                    _searchTickets(context, searchQuery);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Por favor ingrese un valor para buscar')),
                    );
                  }
                  Navigator.pop(context); // Cerrar el diálogo
                },
                child: Text('Buscar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _searchTickets(BuildContext context, String searchQuery) {
    final ticketService = TicketService();

    // Obtener tickets que coincidan con el título
    ticketService.buscarTicketsPorTitulo(searchQuery).listen((tickets) {
      // Mostrar los resultados de la búsqueda
      if (tickets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontraron tickets con ese título')),
        );
      } else {
        // Navegar a una pantalla que muestre los resultados de la búsqueda
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewTicketsScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              tickets: tickets,
            ),
          ),
        );
      }
    });
  }

  Future<void> _generateReports(BuildContext context) async {
    // Implementar generación de reportes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generando reportes...')),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar a pantalla de perfil
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notificaciones'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar a configuración de notificaciones
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Ayuda'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar a pantalla de ayuda
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
