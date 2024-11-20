import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({Key? key}) : super(key: key);

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _tipoUsuario = 'Usuário';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = {
      'nome': _nomeController.text.trim(),
      'email': _emailController.text.trim(),
      'senha': _senhaController.text.trim(),
      'tipo': _tipoUsuario,
    };

    try {
      await DatabaseHelper.instance.insertUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar usuário!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Cabeçalho "Cadastre-se" com botão de voltar
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.deepPurple,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0), // Ajuste da posição
                  child: const Text(
                    "Cadastre-se",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context); // Retorna para a tela anterior
                  },
                ),
              ),
            ],
          ),
          // Formulário
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campo de Nome
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.deepPurple.withOpacity(0.2),
                        ),
                        child: TextFormField(
                          controller: _nomeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nome é obrigatório';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person),
                            border: InputBorder.none,
                            hintText: "Nome",
                          ),
                        ),
                      ),
                      // Campo de Email
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.deepPurple.withOpacity(0.2),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email é obrigatório';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.email),
                            border: InputBorder.none,
                            hintText: "Email",
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      // Campo de Senha
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.deepPurple.withOpacity(0.2),
                        ),
                        child: TextFormField(
                          controller: _senhaController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Senha é obrigatória';
                            }
                            return null;
                          },
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            border: InputBorder.none,
                            hintText: "Senha",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Seleção de Tipo de Usuário
                      const Text(
                        'Selecione o tipo de usuário:',
                        style: TextStyle(fontSize: 16),
                      ),
                      ListTile(
                        title: const Text('Motorista'),
                        leading: Radio(
                          value: 'Motorista',
                          groupValue: _tipoUsuario,
                          onChanged: (value) {
                            setState(() {
                              _tipoUsuario = value.toString();
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Usuário'),
                        leading: Radio(
                          value: 'Usuário',
                          groupValue: _tipoUsuario,
                          onChanged: (value) {
                            setState(() {
                              _tipoUsuario = value.toString();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botão de Cadastro
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.deepPurple,
                        ),
                        child: TextButton(
                          onPressed: _isLoading ? null : _cadastrar,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "CADASTRAR",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}