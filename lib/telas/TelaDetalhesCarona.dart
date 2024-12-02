import 'package:flutter/material.dart';

class TelaDetalhesCarona extends StatelessWidget {
  final Map<String, dynamic> carona;

  const TelaDetalhesCarona({super.key, required this.carona});

  @override
  Widget build(BuildContext context) {
    List<String> nomesPassageiros = [];
    if (carona['passageiros'] != null) {
      nomesPassageiros = List<String>.from(carona['passageiros']
          .map((passageiro) => passageiro['nome'] ?? 'Nome não disponível'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Carona'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Destino: ${carona['bairro']}, ${carona['logradouro']}, ${carona['localidade']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Horário: ${carona['horario']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Vagas: ${carona['vagas']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Detalhes adicionais:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              carona['descricao'] ?? 'Nenhuma descrição fornecida',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Passageiros:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (nomesPassageiros.isEmpty)
              const Text(
                'Nenhum passageiro na carona',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
              ...nomesPassageiros.map((nome) => Text(
                    nome,
                    style: const TextStyle(fontSize: 16),
                  )),
          ],
        ),
      ),
    );
  }
}
