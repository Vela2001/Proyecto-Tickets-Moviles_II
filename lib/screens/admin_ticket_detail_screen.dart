import 'package:flutter/material.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';
import 'package:proyecto_moviles2/services/ticket_service.dart';

class AdminTicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  AdminTicketDetailScreen({required this.ticket});

  @override
  _AdminTicketDetailScreenState createState() =>
      _AdminTicketDetailScreenState();
}

class _AdminTicketDetailScreenState extends State<AdminTicketDetailScreen> {
  late TextEditingController _tituloController;
  String _estado = '';
  String _prioridad = '';

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.ticket.titulo);
    _estado = widget.ticket.estado;
    _prioridad = widget.ticket.prioridad;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    final actualizado = Ticket(
      id: widget.ticket.id,
      titulo: _tituloController.text.trim(),
      descripcion: widget.ticket.descripcion,
      estado: _estado,
      prioridad: _prioridad,
      categoria: widget.ticket.categoria,
      userId: widget.ticket.userId,
      usuarioNombre: widget.ticket.usuarioNombre,
      fechaCreacion: widget.ticket.fechaCreacion,
      fechaActualizacion: DateTime.now(),
    );

    await TicketService().actualizarTicket(actualizado);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            DropdownButton<String>(
              value: _estado,
              items: ['pendiente', 'en_proceso', 'resuelto']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _estado = val!),
            ),
            DropdownButton<String>(
              value: _prioridad,
              items: ['baja', 'media', 'alta']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _prioridad = val!),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
