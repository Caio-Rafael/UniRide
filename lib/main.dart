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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaLogin(),
        '/cadastro': (context) => const TelaCadastro(),
        '/home': (context) => const TelaHome(userType: 'Motorista'),
      },
    );
  }
}

