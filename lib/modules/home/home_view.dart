import 'package:calculo_numerico/modules/metodos/bissecao.dart';
import 'package:calculo_numerico/modules/metodos/gauss_seidel.dart';
import 'package:calculo_numerico/modules/metodos/integracao_numerica_trapezios.dart';
import 'package:calculo_numerico/modules/metodos/interpolacao_polinomial.dart';
import 'package:calculo_numerico/modules/metodos/interpolacao_polinomial_minimos_quadrados.dart';
import 'package:calculo_numerico/modules/metodos/interpolacao_polinomial_newton.dart';
import 'package:calculo_numerico/modules/metodos/lagrange.dart';
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
            MetodoCard(
              context: context,
              titulo: 'Interpolação Polinomial - Forma de Lagrange',
              icone: Icons.polyline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LagrangeView()),
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Forma de Newton',
              icone: Icons.gesture,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InterpolacaoPolinomialNewtonView()),
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Método dos Mínimios Quadrados',
              icone: Icons.token,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MinimosQuadradosView()),
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Métodos dos Trapézios',
              icone: Icons.view_column_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IntegracaoTrapezioView())
              ),
              isActive: true,
            ),
          ],
        ),
      ),
    );
  }
}