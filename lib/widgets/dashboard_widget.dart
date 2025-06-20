// dashboard_widget.dart
import 'package:flutter/material.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';

class DashboardWidget extends StatelessWidget {
  final List<Ticket> tickets;

  DashboardWidget({required this.tickets});

  @override
  Widget build(BuildContext context) {
    final total = tickets.length;
    final pendientes = tickets.where((t) => t.estado == 'pendiente').length;
    final enProceso = tickets.where((t) => t.estado == 'en_proceso').length;
    final resueltos = tickets.where((t) => t.estado == 'resuelto').length;

    final bajas = tickets.where((t) => t.prioridad == 'baja').length;
    final medias = tickets.where((t) => t.prioridad == 'media').length;
    final altas = tickets.where((t) => t.prioridad == 'alta').length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Resumen de Tickets',
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildCard('Total', total, Colors.blue),
              _buildCard('Pendientes', pendientes, Colors.orange),
              _buildCard('En Proceso', enProceso, Colors.amber),
              _buildCard('Resueltos', resueltos, Colors.green),
              _buildCard('Alta Prioridad', altas, Colors.red),
              _buildCard('Media Prioridad', medias, Colors.blueGrey),
              _buildCard('Baja Prioridad', bajas, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String label, int count, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
