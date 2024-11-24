import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import './telaCriarCarona.dart';

class TelaHome extends StatefulWidget {
  final String userEmail;
  final String userType;

  const TelaHome({Key? key, required this.userEmail, required this.userType})
      : super(key: key);

  @override
  _TelaHomeState createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  late Future<List<Map<String, dynamic>>> _caronasFuture;

  @override
  void initState() {
    super.initState();
    _caronasFuture = _fetchCaronas();
  }

  Future<List<Map<String, dynamic>>> _fetchCaronas() async {
    return await DatabaseHelper.instance.getAllCarona();
  }

  void _atualizarCaronas() {
    setState(() {
      _caronasFuture = _fetchCaronas();
    });
  }

  Future<Map<String, dynamic>?> _getUserInfo() async {
    return await DatabaseHelper.instance.getUserByEmail(widget.userEmail);
  }

  Future<void> _excluirCarona(int id) async {
    try {
      await DatabaseHelper.instance.deleteCarona(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carona excluída com sucesso!')),
      );
      _atualizarCaronas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir carona: $e')),
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
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(
                  'Erro ao carregar dados do usuário.',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final user = snapshot.data!;
            return Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user['nome']),
                  accountEmail: Text(user['email']),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.blue),
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Configurações'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Sair'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ],
            );
          },
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

          return FutureBuilder<Map<String, dynamic>?>(
            future: _getUserInfo(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError || !userSnapshot.hasData) {
                return Center(
                  child: Text(
                    'Erro ao carregar informações do usuário.',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final currentUser = userSnapshot.data!;
              final currentUserId = currentUser['id'];

              return ListView.builder(
                itemCount: caronas.length,
                itemBuilder: (context, index) {
                  final carona = caronas[index];
                  final podeExcluir = widget.userType == 'Motorista' &&
                      carona['motorista_id'] == currentUserId;

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Destino: ${carona['destino']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Horário: ${carona['horario']}'),
                          Text('Vagas: ${carona['vagas']}'),
                        ],
                      ),
                      leading: const Icon(Icons.directions_car, color: Colors.blue),
                      trailing: podeExcluir
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Excluir Carona'),
                                      content: const Text(
                                          'Tem certeza que deseja excluir esta carona?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  await _excluirCarona(carona['id']);
                                }
                              },
                            )
                          : null,
                    ),
                  );
                },
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
                if (result == true) _atualizarCaronas();
              },
              child: const Icon(Icons.add),
              tooltip: 'Criar Carona',
            )
          : null,
    );
  }
}
