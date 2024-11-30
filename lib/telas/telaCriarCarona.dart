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
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _localidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _destinoController = TextEditingController();
  final _horarioController = TextEditingController();
  final _vagasController = TextEditingController();

  final String baseUrl =
      'http://192.168.1.9:5000';

  // Método para buscar endereço pelo CEP
  Future<void> _buscarEndereco() async {
    final cep = _cepController.text.trim();
    if (cep.isEmpty || cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um CEP válido de 8 dígitos')),
      );
      return;
    }

    try {
      final response =
          await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('erro')) {
          throw Exception('CEP não encontrado');
        }

        setState(() {
          _logradouroController.text = data['logradouro'] ?? '';
          _bairroController.text = data['bairro'] ?? '';
          _localidadeController.text = data['localidade'] ?? '';
          _ufController.text = data['uf'] ?? '';
        });
      } else {
        throw Exception('Erro ao buscar endereço');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

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
          'cep': _cepController.text.trim(),
          'logradouro': _logradouroController.text.trim(),
          'bairro': _bairroController.text.trim(),
          'localidade': _localidadeController.text.trim(),
          'uf': _ufController.text.trim(),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Campo CEP
                TextFormField(
                  controller: _cepController,
                  decoration: const InputDecoration(labelText: 'CEP'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.length == 8) _buscarEndereco();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 8) {
                      return 'Informe um CEP válido';
                    }
                    return null;
                  },
                ),
                // Campos preenchidos automaticamente
                TextFormField(
                  controller: _logradouroController,
                  decoration: const InputDecoration(labelText: 'Logradouro'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(labelText: 'Bairro'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _localidadeController,
                  decoration: const InputDecoration(labelText: 'Localidade'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _ufController,
                  decoration: const InputDecoration(labelText: 'UF'),
                  readOnly: true,
                ),
                // Outros campos
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
      ),
    );
  }
}
