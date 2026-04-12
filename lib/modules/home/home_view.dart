import 'package:calculo_numerico/modules/metodos/bissecao.dart';
import 'package:calculo_numerico/modules/metodos/gauss_seidel.dart';
import 'package:calculo_numerico/modules/metodos/interpolacao_polinomial.dart';
import 'package:calculo_numerico/modules/metodos/newton_raphson.dart';
import 'package:flutter/material.dart';

import '../../core/componentes/componentes.dart';
import '../metodos/triangulacao_gauss.dart';

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
              titulo: 'Bisseção',
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewtonRaphsonView())
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Triangulação de Gauss',
              icone: Icons.calculate,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TriangulacaoGaussView())
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Gauss-Seidel',
              icone: Icons.functions,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GaussSeidelView()),
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Interpolação Polinomial',
              icone: Icons.scatter_plot,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InterpolacaoPolinomialView()),
              ),
              isActive: true,
            ),
          ],
        ),
      ),
    );
  }
}