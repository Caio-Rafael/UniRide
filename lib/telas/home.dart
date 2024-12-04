import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './telaCriarCarona.dart';
import './TelaDetalhesCarona.dart';
import './telaEditarCarona.dart';

class TelaHome extends StatefulWidget {
  final String userEmail;
  final int userId;
  final String userType;

  const TelaHome(
      {super.key,
      required this.userEmail,
      required this.userType,
      required this.userId});

  @override
  _TelaHomeState createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  late Future<List<Map<String, dynamic>>> _caronasFuture;
  final String baseUrl = 'https://260a-2804-954-faa5-4e00-b434-1f33-2bb8-cb4d.ngrok-free.app';

  @override
  void initState() {
    super.initState();
    _caronasFuture = _fetchCaronas();
  }

  Future<List<Map<String, dynamic>>> _fetchCaronas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carona'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "ngrok-skip-browser-warning": "69420",
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Erro ao carregar caronas: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar caronas: $e');
    }
  }

  Future<void> _deleteCarona(int caronaId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/carona/$caronaId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "ngrok-skip-browser-warning": "69420",
        },
      );
      if (response.statusCode == 204) {
        setState(() {
          _caronasFuture = _fetchCaronas();
        });
      } else {
        throw Exception('Erro ao deletar carona: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar carona: $e')),
      );
    }
  }

  Future<void> _entrarNaCarona(int caronaId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carona/$caronaId/entrar'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "ngrok-skip-browser-warning": "69420",
        },
        body: json.encode({'user_id': widget.userId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entrou na carona com sucesso!')),
        );
        setState(() {
          _caronasFuture = _fetchCaronas();
        });
      } else {
        throw Exception('Erro ao entrar na carona: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar na carona: $e')),
      );
    }
  }

  Future<void> _sairDaCarona(int caronaId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carona/$caronaId/sair'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "ngrok-skip-browser-warning": "69420",
        },
        body: json.encode({'user_id': widget.userId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saiu da carona com sucesso!')),
        );
        setState(() {
          _caronasFuture = _fetchCaronas();
        });
      } else {
        throw Exception('Erro ao sair da carona: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair da carona: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usuário: ${widget.userEmail}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Tipo: ${widget.userType}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Início'),
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Perfil'),
              leading: const Icon(Icons.account_circle),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Configurações'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Sair'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _caronasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar caronas: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final caronas = snapshot.data ?? [];

          if (caronas.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma carona disponível.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: caronas.length,
            itemBuilder: (context, index) {
              final carona = caronas[index];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Destino: ${carona['bairro']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Horário: ${carona['horario']}'),
                      Text('Vagas: ${carona['vagas']}'),
                    ],
                  ),
                  leading: const Icon(Icons.directions_car, color: Colors.blue),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.userId == carona['motorista_id'])
                        Row(
                          children: [
                            // Botão de editar
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TelaEditarCarona(carona: carona),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    _caronasFuture = _fetchCaronas();
                                  });
                                }
                              },
                            ),
                            // Botão de excluir
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Confirmação antes de excluir
                                bool? confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Excluir carona'),
                                      content: const Text(
                                          'Tem certeza de que deseja excluir esta carona?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  await _deleteCarona(carona['id']);
                                }
                              },
                            ),
                          ],
                        ),
                      // Botão de sair
                      IconButton(
                        icon: const Icon(Icons.exit_to_app, color: Colors.red),
                        onPressed: () => _sairDaCarona(carona['id']),
                      ),
                      // Botão de entrar
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () => _entrarNaCarona(carona['id']),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TelaDetalhesCarona(carona: carona),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.userType == 'Motorista'
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CriarCaronaScreen(userEmail: widget.userEmail),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _caronasFuture = _fetchCaronas();
                  });
                }
              },
              tooltip: 'Criar Carona',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
