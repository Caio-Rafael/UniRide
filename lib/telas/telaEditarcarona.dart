import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Telaeditarcarona extends StatefulWidget {
  final Map<String, dynamic> carona; // Recebe os dados da carona para edição

  const Telaeditarcarona({super.key, required this.carona});

  @override
  _TelaeditarcaronaState createState() => _TelaeditarcaronaState();
}

class _TelaeditarcaronaState extends State<Telaeditarcarona> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _localidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _destinoController = TextEditingController();
  final _horarioController = TextEditingController();
  final _vagasController = TextEditingController();

  final String baseUrl = 'http://192.168.1.9:5000';

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _cepController.text = widget.carona['cep'] ?? '';
    _logradouroController.text = widget.carona['logradouro'] ?? '';
    _bairroController.text = widget.carona['bairro'] ?? '';
    _localidadeController.text = widget.carona['localidade'] ?? '';
    _ufController.text = widget.carona['uf'] ?? '';
    _destinoController.text = widget.carona['destino'] ?? '';
    _horarioController.text = widget.carona['horario'] ?? '';
    _vagasController.text = widget.carona['vagas'].toString();
  }

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

  Future<void> _atualizarCarona() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final caronaAtualizada = {
        'destino': _destinoController.text.trim(),
        'horario': _horarioController.text.trim(),
        'vagas': int.parse(_vagasController.text.trim()),
        'cep': _cepController.text.trim(),
        'logradouro': _logradouroController.text.trim(),
        'bairro': _bairroController.text.trim(),
        'localidade': _localidadeController.text.trim(),
        'uf': _ufController.text.trim(),
      };

      final response = await http.put(
        Uri.parse('$baseUrl/carona/${widget.carona["id"]}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(caronaAtualizada),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carona atualizada com sucesso!')),
        );
        Navigator.pop(context, caronaAtualizada);
      } else {
        throw Exception('Erro ao atualizar carona: ${response.body}');
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
        title: const Text('Editar Carona'),
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
                // Botão de atualização
                ElevatedButton(
                  onPressed: _atualizarCarona,
                  child: const Text('Atualizar Carona'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
