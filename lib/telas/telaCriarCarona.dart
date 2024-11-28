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
  final String baseUrl = 'https://94b2-2804-954-fd0b-1400-7c78-f0c6-ffdb-c101.ngrok-free.app'; // URL base da API

  // Método para criar carona
  Future<void> _criarCarona() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userResponse = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );
      if (userResponse.statusCode == 200) {
        final List<dynamic> users = json.decode(userResponse.body);
        final user = users.firstWhere(
          (user) => user['email'] == widget.userEmail,
          orElse: () => null,
        );

        if (user == null) {
          throw Exception('Usuário não encontrado');
        }

        final carona = {
          'motorista_id': user['id'],
          'destino': _destinoController.text.trim(),
          'horario': _horarioController.text.trim(),
          'vagas': int.parse(_vagasController.text.trim()),
        };

        final caronaResponse = await http.post(
          Uri.parse('$baseUrl/carona'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(carona),
        );

        if (caronaResponse.statusCode == 201) {
          final newCarona = json.decode(caronaResponse.body);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Carona criada com sucesso!')),
          );
          Navigator.pop(context, newCarona); // Retorna com a nova carona criada
        } else {
          throw Exception('Erro ao criar carona: ${caronaResponse.body}');
        }
      } else {
        throw Exception('Erro ao carregar dados do usuário');
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
              // Campo Destino
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
              // Campo Horário
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
              // Campo Vagas
              TextFormField(
                controller: _vagasController,
                decoration: const InputDecoration(labelText: 'Vagas'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o número de vagas';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Informe um número válido de vagas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Botão de criação
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
