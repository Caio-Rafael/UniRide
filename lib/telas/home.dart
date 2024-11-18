import 'package:flutter/material.dart';

class TelaHome extends StatelessWidget {
  final String userType;

  const TelaHome({Key? key, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Definir o Drawer (menu hambúrguer) que irá aparecer da direita para a esquerda
      drawer: Drawer(
        child: Column(
          children: [
            // Cabeçalho do Drawer
            UserAccountsDrawerHeader(
              accountName: Text('Nome do Usuário'), // Alterar conforme necessário
              accountEmail: Text('email@dominio.com'), // Alterar conforme necessário
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.blue),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            // Itens do Menu
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Fechar o Drawer
              },
            ),
            ListTile(
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context); // Fechar o Drawer e navegar para configurações
                // Navegar para a tela de configurações
              },
            ),
            ListTile(
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context); // Fechar o Drawer e navegar para o perfil
                // Navegar para a tela de perfil
              },
            ),
            ListTile(
              title: const Text('Sair'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
                // Realizar logout, se necessário
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Página Inicial'),
        // Adicionando o ícone do menu (hamburguer) à AppBar
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Abrir o Drawer (menu hambúrguer)
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Removido a mensagem 'Bem-vindo' e o botão de sair
            // Aqui você pode adicionar outros elementos da tela principal
          ],
        ),
      ),
      // Botão flutuante (visível apenas para motoristas)
      floatingActionButton: userType == 'Motorista'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CriarCaronaScreen(),
                  ),
                );
              },
              child: const Icon(Icons.directions_car),
              tooltip: 'Criar Carona',
            )
          : null,
    );
  }
}

// Tela para a criação de carona (CRUD do motorista)
class CriarCaronaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Carona')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Formulário para Criar Carona',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Aqui seria o formulário de criação de carona (parte do CRUD)
          ],
        ),
      ),
    );
  }
}
