import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';
import 'package:proyecto_moviles2/services/ticket_service.dart';
import 'package:proyecto_moviles2/screens/create_ticket_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart'; // No olvides instalarlo

class ViewTicketsScreen extends StatefulWidget {
  final String userId;
  final List<Ticket>? tickets;

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
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body:
          widget.tickets != null
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
      MaterialPageRoute(builder: (_) => CreateTicketScreen()),
    );
  }

  void _navigateToTicketDetail(BuildContext context, Ticket ticket) {
    // Aquí puedes implementar una pantalla de detalle si deseas
  }

  /// ✅ Función corregida: solo guarda PDF local en Android/iOS
  Future<void> _generatePdf(Ticket ticket) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Ticket de soporte',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey600),
                  borderRadius: pw.BorderRadius.circular(10),
                  color: PdfColors.grey100,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Título:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      ticket.titulo,
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.SizedBox(height: 10),

                    pw.Text(
                      'Descripción:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      ticket.descripcion,
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.SizedBox(height: 10),

                    pw.Text(
                      'Fecha de creación:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(_dateFormat.format(ticket.fechaCreacion)),
                    pw.SizedBox(height: 10),

                    pw.Text(
                      'Estado:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(_capitalize(ticket.estado)),
                    pw.SizedBox(height: 10),

                    if (ticket.prioridad != null &&
                        ticket.prioridad!.isNotEmpty) ...[
                      pw.Text(
                        'Prioridad:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(_capitalize(ticket.prioridad!)),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                '',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    try {
      final bytes = await pdf.save();

      // Solicita permiso
      if (await Permission.storage.request().isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de almacenamiento denegado')),
        );
        return;
      }

      // Guarda en carpeta Descargas
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final filePath =
          '${downloadsDir.path}/ticket_${ticket.titulo}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF guardado en Descargas:\n$filePath')),
      );

      // Abre el PDF
      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
    }
  }
}
