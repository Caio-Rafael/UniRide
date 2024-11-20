import 'package:carunit/auth/cadastro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carunit/auth/login.dart';
import './auth/cadastro.dart';
import 'telas/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarUnit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Tela inicial será a de login
      routes: {
        '/': (context) => const TelaLogin(), // Tela de Login
        '/cadastro': (context) => const TelaCadastro(), // Tela de Cadastro
      },
      // Rota dinâmica para TelaHome (passando parâmetros)
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args != null) {
            final userEmail = args['email'] as String;
            final userType = args['type'] as String;

            return MaterialPageRoute(
              builder: (context) => TelaHome(
                userEmail: userEmail,
                userType: userType,
              ),
            );
          }
        }
        return null;
      },
    );
  }
}