import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';
import 'package:proyecto_moviles2/services/ticket_service.dart';
import 'package:proyecto_moviles2/screens/create_ticket_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class ViewTicketsScreen extends StatefulWidget {
  final String userId;
  final List<Ticket>? tickets; // Lista opcional para tickets filtrados

  const ViewTicketsScreen({Key? key, required this.userId, this.tickets}) : super(key: key);

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
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: widget.tickets != null
          ? _buildTicketsList(widget.tickets!)
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
        tooltip: 'Crear Ticket',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error al cargar tickets'),
          Text(error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
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
            title: Text(ticket.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado: ${_capitalize(ticket.estado)}'),
                Text('Creado: ${_dateFormat.format(ticket.fechaCreacion)}'),
                if (ticket.prioridad != null && ticket.prioridad!.isNotEmpty)
                  Text('Prioridad: ${_capitalize(ticket.prioridad!)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () => _generatePdf(ticket),
                  tooltip: 'Generar PDF',
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
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
      MaterialPageRoute(builder: (_) =>  CreateTicketScreen()),
    );
  }

  void _navigateToTicketDetail(BuildContext context, Ticket ticket) {
    // Implementa navegación a detalle del ticket si tienes pantalla para ello
  }

Future<void> _generatePdf(Ticket ticket) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Ticket', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Título: ${ticket.titulo}', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 8),
            pw.Text('Descripción: ${ticket.descripcion}', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Text('Estado: ${_capitalize(ticket.estado)}'),
            pw.Text('Fecha de creación: ${_dateFormat.format(ticket.fechaCreacion)}'),
            if (ticket.prioridad != null && ticket.prioridad!.isNotEmpty)
              pw.Text('Prioridad: ${_capitalize(ticket.prioridad!)}'),
          ],
        );
      },
    ),
  );

  try {
    final bytes = await pdf.save();

    if (kIsWeb) {
      // Descarga PDF en web
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..download = 'ticket_${ticket.titulo}_${DateTime.now().millisecondsSinceEpoch}.pdf'
        ..style.display = 'none';

      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF descargado')),
      );
    } else {
      // Para Android/iOS/desktop (no web)
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/ticket_${ticket.titulo}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF guardado en ${file.path}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al generar PDF: $e')),
    );
  }
}

}


