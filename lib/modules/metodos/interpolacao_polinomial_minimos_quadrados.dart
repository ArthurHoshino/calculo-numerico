import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../core/componentes/componentes.dart';

class MinimosQuadradosView extends StatefulWidget {
  const MinimosQuadradosView({super.key});

  @override
  State<MinimosQuadradosView> createState() => _MinimosQuadradosViewState();
}

class _MinimosQuadradosViewState extends State<MinimosQuadradosView> {
  final _formKey = GlobalKey<FormState>();

  final List<({TextEditingController x, TextEditingController y})> _pontoControllers = [
    (x: TextEditingController(text: '-1'), y: TextEditingController(text: '4')),
    (x: TextEditingController(text: '0'), y: TextEditingController(text: '1')),
    (x: TextEditingController(text: '2'), y: TextEditingController(text: '-1')),
    (x: TextEditingController(text: '3'), y: TextEditingController(text: '5')),
  ];

  final _grauController = TextEditingController(text: '1');
  final _pontoAvaliacaoController = TextEditingController();

  bool _calculating = false;
  List<Fraction>? _coeficientes; // a0, a1, ...
  Fraction? _valorAvaliado;
  Fraction? _xAvaliado;

  void _addPonto() {
    setState(() {
      _pontoControllers.add((x: TextEditingController(), y: TextEditingController()));
    });
  }

  void _removePonto(int index) {
    if (_pontoControllers.length > 2) {
      setState(() {
        _pontoControllers[index].x.dispose();
        _pontoControllers[index].y.dispose();
        _pontoControllers.removeAt(index);
      });
    }
  }

  Fraction _fractionPow(Fraction base, int exponent) {
    Fraction result = Fraction(1);
    for (int i = 0; i < exponent; i++) {
      result = (result * base).reduce();
    }
    return result;
  }

  List<Fraction> _resolverSistemaLinear(List<List<Fraction>> A, List<Fraction> b) {
    int n = A.length;
    List<List<Fraction>> M = List.generate(n, (i) => List<Fraction>.from(A[i])..add(b[i]));

    for (int i = 0; i < n; i++) {
      int pivot = i;
      for (int j = i + 1; j < n; j++) {
        if (M[j][i].toDouble().abs() > M[pivot][i].toDouble().abs()) {
          pivot = j;
        }
      }
      List<Fraction> temp = M[i];
      M[i] = M[pivot];
      M[pivot] = temp;

      if (M[i][i] == Fraction(0)) {
        throw Exception("Sistema singular ou impossível de resolver com precisão.");
      }

      for (int j = i + 1; j < n; j++) {
        Fraction fator = (M[j][i] / M[i][i]).reduce();
        for (int k = i; k <= n; k++) {
          M[j][k] = (M[j][k] - (fator * M[i][k])).reduce();
        }
      }
    }

    List<Fraction> x = List.filled(n, Fraction(0));
    for (int i = n - 1; i >= 0; i--) {
      Fraction soma = Fraction(0);
      for (int j = i + 1; j < n; j++) {
        soma = (soma + (M[i][j] * x[j])).reduce();
      }
      x[i] = ((M[i][n] - soma) / M[i][i]).reduce();
    }
    return x;
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _calculating = true;
      _coeficientes = null;
      _valorAvaliado = null;
    });

    try {
      int m = int.parse(_grauController.text);
      if (m < 0) throw Exception("O grau do polinômio deve ser >= 0.");
      
      List<Fraction> px = [], py = [];
      for (var ctrl in _pontoControllers) {
        px.add(Fraction.fromString(ctrl.x.text.replaceAll(',', '.')));
        py.add(Fraction.fromString(ctrl.y.text.replaceAll(',', '.')));
      }

      int n = px.length;
      if (m >= n) {
        throw Exception("O grau do polinômio deve ser menor que o número de pontos para o Método dos Mínimos Quadrados ter uma solução de melhor ajuste única que não seja apenas interpolação exata, embora matematicamente possível, reajuste o grau.");
      }

      // Montando a matriz (m+1) x (m+1) e vetor (m+1)
      List<List<Fraction>> A = List.generate(m + 1, (i) => List.filled(m + 1, Fraction(0)));
      List<Fraction> B = List.filled(m + 1, Fraction(0));

      for (int j = 0; j <= m; j++) {
        for (int k = 0; k <= m; k++) {
          Fraction soma = Fraction(0);
          for (int i = 0; i < n; i++) {
            soma = (soma + _fractionPow(px[i], j + k)).reduce();
          }
          A[j][k] = soma;
        }

        Fraction somaB = Fraction(0);
        for (int i = 0; i < n; i++) {
          somaB = (somaB + (_fractionPow(px[i], j) * py[i])).reduce();
        }
        B[j] = somaB;
      }

      List<Fraction> coefs = _resolverSistemaLinear(A, B);

      Fraction? valorAvaliado, xAvaliado;
      if (_pontoAvaliacaoController.text.isNotEmpty) {
        xAvaliado = Fraction.fromString(_pontoAvaliacaoController.text.replaceAll(',', '.'));
        valorAvaliado = Fraction(0);
        for (int i = 0; i < coefs.length; i++) {
          valorAvaliado = (valorAvaliado! + (coefs[i] * _fractionPow(xAvaliado, i))).reduce();
        }
      }

      setState(() {
        _coeficientes = coefs;
        _valorAvaliado = valorAvaliado;
        _xAvaliado = xAvaliado;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _calculating = false);
    }
  }

  void _limpar() {
    setState(() {
      for (var ctrl in _pontoControllers) {
        ctrl.x.clear();
        ctrl.y.clear();
      }
      _grauController.text = '1';
      _pontoAvaliacaoController.clear();
      _coeficientes = null;
      _valorAvaliado = null;
    });
  }

  void _showInfo() {
    InfoDialog.show(
      context,
      titulo: 'Método dos Mínimos Quadrados',
      conteudo: [
        const Text(
          'O método dos Mínimos Quadrados encontra o polinômio de grau "m" que melhor se ajusta aos pontos fornecidos, minimizando a soma dos quadrados dos erros.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Como usar:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('• Insira os valores de x e y para cada ponto conhecido.'),
        const Text('• Adicione ou remova pontos conforme necessário (mínimo de 2).'),
        const Text('• Defina o grau do polinômio de ajuste (m). Deve ser menor que o número de pontos.'),
        const Text('• Opcionalmente, defina um valor de "x" para avaliar o polinômio P(x).'),
        const SizedBox(height: 16),
        const Text('Detalhes Técnicos:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('• Resolve o sistema de equações normais: X^T * X * A = X^T * Y.'),
        const Text('• Os cálculos utilizam frações para precisão total.'),
      ],
    );
  }

  String _formatFractionToLatex(Fraction f) {
    if (f.denominator == 1) return f.numerator.toString();
    String sign = f.isNegative ? '-' : '';
    return '$sign\\frac{${f.numerator.abs()}}{${f.denominator}}';
  }

  String _buildPolinomioLatex(List<Fraction> coefs) {
    String latex = 'P(x) = ';
    bool algumTermoAdicionado = false;

    for (int i = coefs.length - 1; i >= 0; i--) {
      if (coefs[i].toDouble().abs() < 1e-9) continue;

      Fraction c = coefs[i];
      if (algumTermoAdicionado && !c.isNegative) {
        latex += ' + ';
      }

      Fraction absC = c;
      if (absC != Fraction(1) || i == 0) {
        latex += _formatFractionToLatex(absC);
      }

      if (i > 0) {
        latex += i == 1 ? 'x' : 'x^{$i}';
      }
      algumTermoAdicionado = true;
    }
    if (!algumTermoAdicionado) return 'P(x) = 0';
    return latex;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mínimos Quadrados'),
          actions: [
            IconButton(
              onPressed: _showInfo,
              icon: const Icon(Icons.info_outline),
              tooltip: 'Informações',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pontos Conhecidos (x, y)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ..._pontoControllers.asMap().entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(children: [
                              Expanded(
                                  child: TextFormField(
                                      controller: entry.value.x,
                                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                      decoration: InputDecoration(
                                          labelText: 'x${entry.key}',
                                          border: const OutlineInputBorder()))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: TextFormField(
                                      controller: entry.value.y,
                                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                      decoration: InputDecoration(
                                          labelText: 'y${entry.key}',
                                          border: const OutlineInputBorder()))),
                              if (_pontoControllers.length > 2)
                                IconButton(
                                    icon: const Icon(Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () => _removePonto(entry.key))
                            ]),
                          )),
                      Center(
                          child: TextButton.icon(
                              onPressed: _addPonto,
                              icon: const Icon(Icons.add),
                              label: const Text('ADICIONAR PONTO'))),
                      const Divider(),
                      TextFormField(
                          controller: _grauController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Grau do polinômio de ajuste (m)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.stacked_line_chart))),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _pontoAvaliacaoController,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          decoration: const InputDecoration(
                              labelText: 'Valor de x para avaliar (Opcional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.ads_click))),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: OutlinedButton(
                                onPressed: _limpar, child: const Text('LIMPAR'))),
                        const SizedBox(width: 16),
                        Expanded(
                            child: FilledButton(
                                onPressed: _calculating ? null : _calcular,
                                child: _calculating
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('CALCULAR'))),
                      ])
                    ],
                  ),
                ),
              ),
            ),
            if (_coeficientes != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Polinômio Ajustado:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200)),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                          _buildPolinomioLatex(_coeficientes!),
                          textStyle: TextStyle(fontSize: 22, color: Colors.blue.shade900),
                        ),
                      ),
                    ),
                    if (_valorAvaliado != null) ...[
                      const SizedBox(height: 24),
                      const Text('Avaliação:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Card(
                        color: Colors.green.shade50,
                        child: ListTile(
                          leading: const Icon(Icons.functions, color: Colors.green),
                          title: Math.tex(
                            'P(${_formatFractionToLatex(_xAvaliado!)}) = ${_formatFractionToLatex(_valorAvaliado!)}',
                            textStyle:
                                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('≈ ${_valorAvaliado!.toDouble().toStringAsFixed(6)}'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text('Coeficientes:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                          columns: const [
                            DataColumn(
                                label: Text('i',
                                    style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Coeficiente (Fração)',
                                    style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Valor Aproximado',
                                    style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _coeficientes!.asMap().entries.map((e) {
                            return DataRow(cells: [
                              DataCell(Text('a${e.key}')),
                              DataCell(Math.tex(_formatFractionToLatex(e.value),
                                  textStyle: const TextStyle(fontSize: 16))),
                              DataCell(Text(e.value.toDouble().toStringAsFixed(6))),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
