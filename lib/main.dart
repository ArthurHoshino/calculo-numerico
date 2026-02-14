import 'package:calculo_numerico/modules/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';

import 'core/componentes/componentes.dart';

void main() {
  runApp(const NumericalMethodsApp());
}

class NumericalMethodsApp extends StatelessWidget {
  const NumericalMethodsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Métodos Numéricos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
      ),
      home: const HomeView(),
    );
  }
}
