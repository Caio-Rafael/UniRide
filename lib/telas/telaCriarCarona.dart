import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CriarCaronaScreen extends StatefulWidget {
  final String userEmail;

  const CriarCaronaScreen({super.key, required this.userEmail});

  @override
  _CriarCaronaScreenState createState() => _CriarCaronaScreenState();
}

class _CriarCaronaScreenState extends State<CriarCaronaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinoController = TextEditingController();
  final _horarioController = TextEditingController();
  final _vagasController = TextEditingController();

  Future<void> _criarCarona() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.get(Uri.parse('http://localhost:5000/users'));
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        final user = users.firstWhere((user) => user['email'] == widget.userEmail);

        final carona = {
          'motorista_id': user['id'],
          'destino': _destinoController.text.trim(),
          'horario': _horarioController.text.trim(),
          'vagas': int.parse(_vagasController.text.trim()),
        };

        final caronaResponse = await http.post(
          Uri.parse('http://localhost:5000/carona'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(carona),
        );

        if (caronaResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Carona criada com sucesso!')),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Erro ao criar carona');
        }
      } else {
        throw Exception('Erro ao carregar usuários');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Carona'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _destinoController,
                decoration: const InputDecoration(labelText: 'Destino'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o destino';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _horarioController,
                decoration: const InputDecoration(labelText: 'Horário'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o horário';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vagasController,
                decoration: const InputDecoration(labelText: 'Vagas'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o número de vagas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _criarCarona,
                child: const Text('Criar Carona'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}