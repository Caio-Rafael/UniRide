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
  final String baseUrl = 'http://192.168.1.9:5000';

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
                    mainAxisSize:
                        MainAxisSize.min, // Permite que os ícones fiquem juntos
                    children: [
                      if (widget.userId == carona['motorista_id'])
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async {
                            // Navegação para a tela de edição de carona
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TelaEditarCarona(carona: carona),
                              ),
                            );
                            // Atualizar a lista de caronas após editar
                            if (result != null) {
                              setState(() {
                                _caronasFuture = _fetchCaronas();
                              });
                            }
                          },
                        ),
                      if (widget.userId == carona['motorista_id'])
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmar Exclusão'),
                                  content: const Text(
                                      'Tem certeza que deseja excluir esta carona?'),
                                  actions: <Widget>[
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

                            if (confirm == true) {
                              await _deleteCarona(carona['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Carona excluída com sucesso')),
                              );
                            }
                          },
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
