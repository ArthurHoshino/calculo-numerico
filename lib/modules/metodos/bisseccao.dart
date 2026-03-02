import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import '../../core/componentes/componentes.dart';

/// Armazena os dados de uma única linha da tabela (uma iteração)
class PassoIteracao {
  final int k;
  final double a;
  final double b;
  final double xk;
  final double fa;
  final double fxk;
  final double error;

  PassoIteracao({
    required this.k,
    required this.a,
    required this.b,
    required this.xk,
    required this.fa,
    required this.fxk,
    required this.error,
  });

  // Getter para o produto f(a) * f(xk)
  double get faTimesFxk => fa * fxk;
}

/// Armazena o resultado completo de uma raiz encontrada
class RootResult {
  final int id;
  final double finalRoot;
  final List<PassoIteracao> steps;

  RootResult({required this.id, required this.finalRoot, required this.steps});
}

class BisseccaoView extends StatefulWidget {
  const BisseccaoView({super.key});

  @override
  State<BisseccaoView> createState() => _BisseccaoViewState();
}

class _BisseccaoViewState extends State<BisseccaoView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _functionController = TextEditingController(text: "x^3 - 9*x + 3");
  final _rootsCountController = TextEditingController(text: "0");
  final _toleranceController = TextEditingController(text: "0.0001");
  final _qtdCasasDecimaisController = TextEditingController(text: "5");

  // State
  List<RootResult> _results = [];
  int _selectedRootIndex = 0; // Para o seletor de abas
  bool _calculating = false;
  int qtdCasasDecimais = 5;

  // Algoritmo de Busca e Bissecção
  void _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _calculating = true;
      _results = [];
      _selectedRootIndex = 0;
    });

    try {
      final funcExpression = _functionController.text;

      // Transformamos a String em uma função 'f' antes dos loops.
      final f = funcExpression.toSingleVariableFunction('x');

      final tolerance = double.parse(_toleranceController.text.replaceAll(',', '.'));
      final maxRootsInput = int.tryParse(_rootsCountController.text) ?? 0;
      qtdCasasDecimais = int.tryParse(_qtdCasasDecimaisController.text) ?? 5;


      // 1. Fase de Isolamento (Bracketing)
      List<List<double>> intervals = [];
      double startRange = -100;
      double endRange = 100;
      double step = 0.5;

      double prevX = startRange;
      double prevY = f(startRange).toDouble();

      for (double x = startRange + step; x <= endRange; x += step) {
        if (maxRootsInput > 0 && intervals.length >= maxRootsInput) break;

        double y = f(x).toDouble();

        if (prevY * y < 0) {
          intervals.add([prevX, x]);
        }

        prevX = x;
        prevY = y;
      }

      // 2. Fase de Refinamento (Bissecção)
      List<RootResult> computedResults = [];

      for (int i = 0; i < intervals.length; i++) {
        double a = intervals[i][0];
        double b = intervals[i][1];
        List<PassoIteracao> steps = [];

        int k = 0;
        double error = double.infinity;
        double xk = 0;

        while (error > tolerance && k < 1000) {
          k++;
          xk = (a + b) / 2;

          double fa = f(a).toDouble();
          double fxk = f(xk).toDouble();

          error = (b - a).abs();

          steps.add(PassoIteracao(
              k: k,
              a: a,
              b: b,
              xk: xk,
              fa: fa,
              fxk: fxk,
              error: error
          ));

          if (fa * fxk < 0) {
            b = xk;
          } else {
            a = xk;
          }
        }

        computedResults.add(RootResult(
          id: i + 1,
          finalRoot: xk,
          steps: steps,
        ));
      }

      setState(() {
        _results = computedResults;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao calcular: $e')),
      );
    } finally {
      setState(() => _calculating = false);
    }
  }

  void _limparFormulario() {
    _functionController.text = '';
    _rootsCountController.text = '';
    _toleranceController.text = '';

    setState(() {
      _calculating = false;
      _results = [];
    });
  }

  void _showInfo() {
    InfoDialog.show(
      context,
      titulo: 'Como usar',
      conteudo: [
        const Text('Este módulo resolve equações utilizando o Método da Bissecção.', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Campos de Entrada:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('• Função f(x): Digite a expressão matemática (ex: x^3 - 9*x + 3). Use "*" para multiplicação e "^" para potência.'),
        const SizedBox(height: 8),
        const Text('• Qtd. Raízes: Define quantas raízes o app deve buscar. Digite "0" para buscar em todo o intervalo padrão (-100 a 100).'),
        const SizedBox(height: 8),
        const Text('• Tolerância: Define a precisão desejada (ex: 0.0001). O cálculo para quando o intervalo (b-a) é menor que este valor.'),
        const SizedBox(height: 8),
        const Text('• Qtd. Casas Decimais: Define a precisão da exibição dos números na tabela. (Valor padrão: 5)'),
        const SizedBox(height: 16),
        const Text('Como Funciona:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('1. O app realiza uma varredura para isolar intervalos onde há mudança de sinal (Teorema de Bolzano).'),
        const Text('2. Em cada intervalo, aplica sucessivas divisões ao meio até convergir para a raiz dentro da tolerância definida.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bissecção'),
        actions: [
          IconButton(
            onPressed: _showInfo,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informações',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // --- INPUT AREA ---
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _functionController,
                        decoration: const InputDecoration(
                          labelText: 'Função f(x)',
                          hintText: 'Ex: x^2 - 4',
                          prefixIcon: Icon(Icons.functions),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Insira uma função' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rootsCountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Qtd. Raízes',
                                helperText: '0 para todas',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _toleranceController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Tolerância',
                                helperText: 'Ex: 0.001',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _qtdCasasDecimaisController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Qtd. casas decimais',
                                helperText: 'Ex: 10 (padrão 5)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Botão Secundário: Limpar
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _calculating ? null : _limparFormulario,
                              icon: const Icon(Icons.clear),
                              label: const Text('LIMPAR'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Botão Principal: Calcular
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _calculating ? null : _calculate,
                              icon: _calculating
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.calculate),
                              label: const Text('CALCULAR'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- RESULTS AREA ---
            if (_results.isNotEmpty) ...[
              const Divider(),
              // Seletor de Raízes (Chips)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _results.asMap().entries.map((entry) {
                    int idx = entry.key;
                    RootResult res = entry.value;
                    bool isSelected = _selectedRootIndex == idx;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('Raiz ${res.id}: ${res.finalRoot.toStringAsFixed(qtdCasasDecimais)}'),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() => _selectedRootIndex = idx);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Tabela (Agora integrada ao scroll principal do ListView)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columns: const [
                      DataColumn(label: Text('k', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('a', style: TextStyle(fontStyle: FontStyle.italic))),
                      DataColumn(label: Text('b', style: TextStyle(fontStyle: FontStyle.italic))),
                      DataColumn(label: Text('xk (Média)')),
                      DataColumn(label: Text('f(a)')),
                      DataColumn(label: Text('f(xk)')),
                      DataColumn(label: Text('f(a) . f(xk)')),
                      DataColumn(label: Text('Erro (b-a)')),
                    ],
                    rows: _results[_selectedRootIndex].steps.map((step) {
                      return DataRow(cells: [
                        DataCell(Text(step.k.toString())),
                        DataCell(Text(step.a.toStringAsFixed(qtdCasasDecimais))),
                        DataCell(Text(step.b.toStringAsFixed(qtdCasasDecimais))),
                        DataCell(Text(step.xk.toStringAsFixed(qtdCasasDecimais), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(step.fa.toStringAsFixed(qtdCasasDecimais))),
                        DataCell(Text(step.fxk.toStringAsFixed(qtdCasasDecimais))),
                        DataCell(Text(step.faTimesFxk.toStringAsFixed(qtdCasasDecimais))),
                        DataCell(Text(step.error.toStringAsFixed(qtdCasasDecimais), style: TextStyle(color: step.error > double.parse(_toleranceController.text) ? Colors.red.shade700 : Colors.green.shade700))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ] else if (!_calculating) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text("Insira os dados e calcule para ver a tabela.")),
              )
            ]
          ],
        ),
      ),
    );
  }
}
