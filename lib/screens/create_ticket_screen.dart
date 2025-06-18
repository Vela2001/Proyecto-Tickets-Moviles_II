import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';  // para acceder a la key
import 'package:proyecto_moviles2/services/ticket_service.dart';

class CreateTicketScreen extends StatefulWidget {
  @override
  _CreateTicketScreenState createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'media';
  String _category = 'general';
  bool _isLoading = false;
  bool _priorityDetermined = false;
  bool _canCreateTicket = false;
  final TicketService _ticketService = TicketService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(  // para evitar overflow
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Por favor ingrese un título'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada de la falla',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  if (value.length < 20) {
                    return 'La descripción debe tener al menos 20 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_priorityDetermined)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(_priority),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Prioridad: ${_priority.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['general', 'login', 'pago', 'tecnico']
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        if (!_priorityDetermined)
                          ElevatedButton(
                            onPressed: _analyzePriority,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text(
                              'ANALIZAR PRIORIDAD',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (_priorityDetermined)
                          ElevatedButton(
                            onPressed: _canCreateTicket ? _submitTicket : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'CREAR TICKET',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _analyzePriority() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final description = _descriptionController.text;
      _priority = await _determinePriorityWithAI(description);
      setState(() {
        _priorityDetermined = true;
        _canCreateTicket = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al analizar prioridad: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _submitTicket() async {
    setState(() => _isLoading = true);

    try {
      await _ticketService.crearTicket(
        titulo: _titleController.text.trim(),
        descripcion: _descriptionController.text.trim(),
        prioridad: _priority,
        categoria: _category,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Ticket creado con prioridad ${_priority.toUpperCase()}!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

 Future<String> _determinePriorityWithAI(String description) async {
  final apiKey = dotenv.env['HUGGINGFACE_API_KEY'] ?? '';

  if (apiKey.isEmpty) {
    throw Exception('API Key de Hugging Face no configurada.');
  }

  final response = await http.post(
    Uri.parse(
        'https://api-inference.huggingface.co/models/nlptown/bert-base-multilingual-uncased-sentiment'),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'inputs': description}),
  );

  if (response.statusCode == 200) {
    final List<dynamic> outerList = jsonDecode(response.body);

    if (outerList.isNotEmpty && outerList[0] is List && outerList[0].isNotEmpty) {
      final List<dynamic> predictions = outerList[0];

      // La predicción más probable es la primera en la lista
      final bestPrediction = predictions[0];
      final label = bestPrediction['label'] as String;

      // Mapeo de estrellas a prioridad
      if (label.startsWith('1') || label.startsWith('2')) return 'alta';
      if (label.startsWith('3')) return 'media';
      if (label.startsWith('4') || label.startsWith('5')) return 'baja';

      return 'media'; // default
    } else {
      throw Exception('Respuesta inesperada: lista vacía o mal formato.');
    }
  } else {
    throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
  }
}


}
