import 'package:calculo_numerico/modules/metodos/bisseccao.dart';
import 'package:flutter/material.dart';

import '../../core/componentes/componentes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Métodos Numéricos')),
      body: SafeArea(
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            MetodoCard(
              context: context,
              titulo: 'Bissecção',
              icone: Icons.content_cut,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BisseccaoView()),
              ),
              isActive: true,
            ),
            // Futuros métodos aqui (Newton, Secante, etc.)
            MetodoCard(
              context: context,
              titulo: 'Newton-Raphson',
              icone: Icons.timeline,
            ),
            MetodoCard(
              context: context,
              titulo: 'Secante',
              icone: Icons.auto_graph_rounded,
            ),
          ],
        ),
      ),
    );
  }
}