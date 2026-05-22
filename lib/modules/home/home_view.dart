import 'package:calculo_numerico/modules/metodos/bissecao.dart';
import 'package:calculo_numerico/modules/metodos/forma_simpson.dart';
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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _useDefaultValues = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos Numéricos'),
        actions: [
          Row(
            children: [
              const Text('Valores de Exemplo', style: TextStyle(fontSize: 14)),
              Switch(
                value: _useDefaultValues,
                onChanged: (value) {
                  setState(() {
                    _useDefaultValues = value;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.blue.shade200,
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
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
                MaterialPageRoute(builder: (context) => BisseccaoView(fillDefaultValues: _useDefaultValues)),
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
                MaterialPageRoute(builder: (context) => NewtonRaphsonView(fillDefaultValues: _useDefaultValues))
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Triangulação de Gauss',
              icone: Icons.calculate,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TriangulacaoGaussView(fillDefaultValues: _useDefaultValues))
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Gauss-Seidel',
              icone: Icons.functions,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GaussSeidelView(fillDefaultValues: _useDefaultValues)),
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Interpolação Polinomial',
              icone: Icons.scatter_plot,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InterpolacaoPolinomialView(fillDefaultValues: _useDefaultValues)),
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Interpolação Polinomial - Forma de Lagrange',
              icone: Icons.polyline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LagrangeView(fillDefaultValues: _useDefaultValues)),
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Forma de Newton',
              icone: Icons.gesture,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InterpolacaoPolinomialNewtonView(fillDefaultValues: _useDefaultValues)),
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Método dos Mínimios Quadrados',
              icone: Icons.token,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MinimosQuadradosView(fillDefaultValues: _useDefaultValues)),
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Método dos Trapézios',
              icone: Icons.view_column_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IntegracaoTrapezioView(fillDefaultValues: _useDefaultValues))
              ),
              isActive: true,
            ),
            MetodoCard(
              context: context,
              titulo: 'Regra 1/3 de Simpson',
              icone: Icons.bar_chart,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FormaSimpsonView(fillDefaultValues: _useDefaultValues))
              ),
              isActive: true,
            ),
          ],
        ),
      ),
    );
  }
}