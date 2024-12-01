import 'package:carunit/auth/cadastro.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:carunit/auth/login.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaLogin(),
        '/cadastro': (context) => const TelaCadastro(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args != null) {
            final userEmail = args['email'] as String;
            final userType = args['type'] as String;
            final userId = args['id'] as int;

            return MaterialPageRoute(
              builder: (context) => TelaHome(
                userId: userId,
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
