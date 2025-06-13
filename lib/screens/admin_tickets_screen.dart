import 'package:flutter/material.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';
import 'package:proyecto_moviles2/services/ticket_service.dart';

class AdminTicketsScreen extends StatefulWidget {
  @override
  _AdminTicketsScreenState createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  String _filterStatus = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administrar Tickets')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: _filterStatus,
              items: ['todos', 'pendiente', 'en_proceso', 'resuelto']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _filterStatus = value!);
              },
            ),
          ),
          Expanded(
            child: _buildTicketsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList() {
    final stream = _filterStatus == 'todos'
        ? TicketService().obtenerTodosLosTickets()
        : TicketService().obtenerTicketsPorEstado(_filterStatus);

    return StreamBuilder<List<Ticket>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay tickets disponibles'));
        }

        final tickets = snapshot.data!;

        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return Card(
              child: ListTile(
                title: Text(ticket.titulo),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estado: ${ticket.estado}'),
                    Text('Prioridad: ${ticket.prioridad}'),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Navegar a pantalla de detalle para administrador
                },
              ),
            );
          },
        );
      },
    );
  }
}
