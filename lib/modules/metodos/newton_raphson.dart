import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';

class PassoIteracao {
  final int k;
  final double x;
  final double fx1;
  final double fx2;
  final double error;

  PassoIteracao({
    required this.k,
    required this.x,
    required this.fx1,
    required this.fx2,
    required this.error,
  });

  double get proximoPasso => x - (fx1 / fx2);
}

class RaizEncontrada {
  final int iteracao;
  final double raizFinal;
  final List<PassoIteracao> passos;

  RaizEncontrada({
    required this.iteracao,
    required this.raizFinal,
    required this.passos,
  });
}

class NewtonRaphsonView extends StatefulWidget {
  const NewtonRaphsonView({super.key});

  @override
  State<NewtonRaphsonView> createState() => _NewtonRaphsonState();
}

class _NewtonRaphsonState extends State<NewtonRaphsonView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _functionController = TextEditingController(text: '2*x^3 + 3*x^2 - 2');
  final _toleranciaController = TextEditingController(text: '0.0001');
  final _valorInicial = TextEditingController(text: '0.5');
  final _qtdCasasDecimaisController = TextEditingController(text: '5');

  // Estado
  RaizEncontrada? _resultadoFinal;
  bool _calculando = false;
  int qtdCasasDecimais = 0;

  void _calcular() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _calculando = true;
      _resultadoFinal = null;
    });

    try {
      final funcaoExpressao = _functionController.text;
      final fDeX = funcaoExpressao.toSingleVariableFunction('x');
      final fPrimeiraDeX = fDeX.derivative('x');
      final tolerancia = double.parse(_toleranciaController.text);
      qtdCasasDecimais = _qtdCasasDecimaisController.text.isEmpty ? 5 : int.parse(_qtdCasasDecimaisController.text);

      List<PassoIteracao> passos = [];
      double valorAtual = double.parse(_valorInicial.text);
      double proxValor = 0;
      double error = double.infinity;
      int k = 0;
      final maxIteracoes = 1000;

      while (error > tolerancia && k < maxIteracoes) {
        k++;
        double fx1 = fDeX(valorAtual).toDouble();
        double fx2 = fPrimeiraDeX(valorAtual).toDouble();
        proxValor = valorAtual - (fx1 / fx2);
        
        error = (proxValor - valorAtual).abs();

        passos.add(PassoIteracao(
          k: k,
          x: proxValor,
          fx1: fx1,
          fx2: fx2,
          error: error 
        ));
        
        valorAtual = proxValor;
      }

      _resultadoFinal = RaizEncontrada(
          iteracao: k,
          raizFinal: valorAtual,
          passos: passos
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao calcular: $e')),
      );
    } finally {
      setState(() => _calculando = false);
    }
  }

  void _limparFormulario() {
    _functionController.text = '';
    _valorInicial.text = '';
    _toleranciaController.text = '';
    _qtdCasasDecimaisController.text = '';

    setState(() {
      _calculando = false;
      _resultadoFinal = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Método de Newton-Raphson')),
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
                          hintText: 'Ex: x^7 - 1000',
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
                              controller: _valorInicial,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: const InputDecoration(
                                labelText: 'Chute Inicial (x0)',
                                helperText: 'Ex: 2.0',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _toleranciaController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                              onPressed: _calculando ? null : _limparFormulario,
                              icon: const Icon(Icons.clear),
                              label: const Text('LIMPAR'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Botão Principal: Calcular
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _calculando ? null : _calcular,
                              icon: _calculando
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
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
            // Agora valida apenas se a lista única de passos não está vazia
            if (_resultadoFinal != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  color: Colors.green.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.green.shade200, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Raiz Encontrada: ${_resultadoFinal!.raizFinal.toStringAsFixed(qtdCasasDecimais)}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tabela Newton-Raphson direta, sem seletores de abas
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columns: const [
                      DataColumn(label: Text('k', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('x', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('f(x)')),
                      DataColumn(label: Text("f'(x)")),
                      DataColumn(label: Text('Erro')),
                    ],
                    // Mapeando diretamente a variável _steps (sua lista única)
                    rows: _resultadoFinal!.passos.map((step) {
                      double tolerancy = double.tryParse(_toleranciaController.text.replaceAll(',', '.')) ?? 0.0;

                      return DataRow(cells: [
                        DataCell(Text(step.k.toString())),
                        DataCell(Text(step.x.toStringAsFixed(qtdCasasDecimais), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(step.fx1.toStringAsFixed(qtdCasasDecimais))),
                        DataCell(Text(step.fx2.toStringAsFixed(qtdCasasDecimais))),
                        DataCell(
                          Text(
                            step.error.toStringAsFixed(qtdCasasDecimais),
                            style: TextStyle(
                              color: step.error > tolerancy ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ] else if (!_calculando) ...[
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
