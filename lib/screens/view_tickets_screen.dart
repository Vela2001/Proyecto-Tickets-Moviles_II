import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';
import 'package:proyecto_moviles2/services/ticket_service.dart';
import 'package:proyecto_moviles2/screens/create_ticket_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io'; // Asegúrate de tener esta importación
import 'package:path_provider/path_provider.dart';

class ViewTicketsScreen extends StatefulWidget {
  final String userId;
  final List<Ticket>? tickets; // Agregar la lista de tickets filtrados

  const ViewTicketsScreen({Key? key, required this.userId, this.tickets})
      : super(key: key);

  @override
  State<ViewTicketsScreen> createState() => _ViewTicketsScreenState();
}

class _ViewTicketsScreenState extends State<ViewTicketsScreen> {
  final TicketService _ticketService = TicketService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: widget.tickets != null
          ? _buildTicketsList(widget.tickets!) // Si hay tickets filtrados
          : StreamBuilder<List<Ticket>>(
              stream: _ticketService.obtenerTicketsPorUsuario(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildTicketsList(snapshot.data!);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTicket(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    debugPrint('Error al cargar tickets: $error');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error al cargar tickets'),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No hay tickets creados'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _navigateToCreateTicket(context),
            child: const Text('Crear primer ticket'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(List<Ticket> tickets) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 2,
          child: ListTile(
            leading: _buildStatusIndicator(ticket.estado),
            title: Text(
              ticket.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado: ${_capitalize(ticket.estado)}'),
                Text('Creado: ${_dateFormat.format(ticket.fechaCreacion)}'),
                if (ticket.prioridad != null)
                  Text('Prioridad: ${_capitalize(ticket.prioridad)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.print),
                  onPressed: () => _generatePdf(ticket),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _navigateToTicketDetail(context, ticket),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(String status) {
    final color = _getStatusColor(status);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en_proceso':
        return Colors.blue;
      case 'resuelto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _navigateToCreateTicket(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTicketScreen()),
    );
  }

  void _navigateToTicketDetail(BuildContext context, Ticket ticket) {
    // Implementa la navegación a la pantalla de detalle
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => TicketDetailScreen(ticket: ticket),
    // ));
  }

  // Función para generar el PDF del ticket
  void _generatePdf(Ticket ticket) async {
    final pdf = pw.Document();

    // Crear el PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Ticket: ${ticket.titulo}',
                  style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Estado: ${_capitalize(ticket.estado)}'),
              pw.Text('Prioridad: ${_capitalize(ticket.prioridad ?? '')}'),
              pw.Text('Creado: ${_dateFormat.format(ticket.fechaCreacion)}'),
              pw.SizedBox(height: 20),
              pw.Text('Descripción:'),
              pw.Text(ticket.descripcion),
            ],
          );
        },
      ),
    );

    // Guardar el PDF en la memoria del dispositivo o compartir
    final outputFile = await getTemporaryDirectory();
    final file = File("${outputFile.path}/ticket_${ticket.id}.pdf");

    await file.writeAsBytes(await pdf.save());

    print("PDF generado en: ${file.path}");
    // Aquí puedes agregar lógica para mostrar una notificación o compartir el archivo si lo deseas.
  }
}
