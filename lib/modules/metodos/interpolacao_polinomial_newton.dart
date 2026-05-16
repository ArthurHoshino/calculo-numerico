import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../core/componentes/componentes.dart';

class InterpolacaoPolinomialNewtonView extends StatefulWidget {
  const InterpolacaoPolinomialNewtonView({super.key});

  @override
  State<InterpolacaoPolinomialNewtonView> createState() => _InterpolacaoPolinomialNewtonViewState();
}

class _InterpolacaoPolinomialNewtonViewState extends State<InterpolacaoPolinomialNewtonView> {
  final _formKey = GlobalKey<FormState>();

  final List<({TextEditingController x, TextEditingController y})> _pontoControllers = [
    (x: TextEditingController(text: '-1'), y: TextEditingController(text: '4')),
    (x: TextEditingController(text: '0'), y: TextEditingController(text: '1')),
    (x: TextEditingController(text: '2'), y: TextEditingController(text: '-1')),
  ];

  final _pontoAvaliacaoController = TextEditingController();

  bool _calculating = false;
  List<Fraction>? _coeficientesNewton; // c0, c1, ...
  List<Fraction>? _coeficientesPadrao; // a0, a1, ...
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

  List<Fraction> _multiplicarPolinomios(List<Fraction> p1, List<Fraction> p2) {
    List<Fraction> result = List.filled(p1.length + p2.length - 1, Fraction(0));
    for (int i = 0; i < p1.length; i++) {
      for (int j = 0; j < p2.length; j++) {
        result[i + j] = (result[i + j] + (p1[i] * p2[j])).reduce();
      }
    }
    return result;
  }

  List<Fraction> _calcularDiferencasDivididas(List<Fraction> x, List<Fraction> y) {
    int n = x.length;
    List<List<Fraction>> f = List.generate(n, (i) => List.filled(n, Fraction(0)));

    for (int i = 0; i < n; i++) {
      f[i][0] = y[i];
    }

    for (int j = 1; j < n; j++) {
      for (int i = 0; i < n - j; i++) {
        f[i][j] = ((f[i + 1][j - 1] - f[i][j - 1]) / (x[i + j] - x[i])).reduce();
      }
    }

    List<Fraction> coeficientesNewton = [];
    for (int i = 0; i < n; i++) {
      coeficientesNewton.add(f[0][i]);
    }
    return coeficientesNewton;
  }

  List<Fraction> _calcularCoeficientesFormaPadrao(List<Fraction> x, List<Fraction> coeficientesNewton) {
    int n = coeficientesNewton.length;
    List<Fraction> polyResult = List.filled(n, Fraction(0));
    List<Fraction> termPoly = [Fraction(1)];

    for (int i = 0; i < n; i++) {
      for (int k = 0; k < termPoly.length; k++) {
        polyResult[k] = (polyResult[k] + (termPoly[k] * coeficientesNewton[i])).reduce();
      }
      
      if (i < n - 1) {
        termPoly = _multiplicarPolinomios(termPoly, [(x[i] * Fraction(-1)).reduce(), Fraction(1)]);
      }
    }
    return polyResult;
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _calculating = true;
      _coeficientesNewton = null;
      _coeficientesPadrao = null;
      _valorAvaliado = null;
    });

    try {
      List<Fraction> px = [], py = [];
      for (var ctrl in _pontoControllers) {
        px.add(Fraction.fromString(ctrl.x.text.replaceAll(',', '.')));
        py.add(Fraction.fromString(ctrl.y.text.replaceAll(',', '.')));
      }

      List<Fraction> coefsNewton = _calcularDiferencasDivididas(px, py);
      List<Fraction> coefsPadrao = _calcularCoeficientesFormaPadrao(px, coefsNewton);

      Fraction? valorAvaliado, xAvaliado;
      if (_pontoAvaliacaoController.text.isNotEmpty) {
        xAvaliado = Fraction.fromString(_pontoAvaliacaoController.text.replaceAll(',', '.'));
        valorAvaliado = Fraction(0);
        for (int i = 0; i < coefsPadrao.length; i++) {
          valorAvaliado = (valorAvaliado! + (coefsPadrao[i] * _fractionPow(xAvaliado, i))).reduce();
        }
      }

      setState(() {
        _coeficientesNewton = coefsNewton;
        _coeficientesPadrao = coefsPadrao;
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
      _pontoAvaliacaoController.clear();
      _coeficientesNewton = null;
      _coeficientesPadrao = null;
      _valorAvaliado = null;
    });
  }

  void _showInfo() {
    InfoDialog.show(
      context,
      titulo: 'Interpolação Forma de Newton',
      conteudo: [
        const Text(
          'O método de Newton encontra o polinômio interpolador usando diferenças divididas.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Como usar:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('• Insira os valores de x e y para cada ponto conhecido.'),
        const Text('• Adicione ou remova pontos conforme necessário (mínimo de 2).'),
        const Text('• Defina um valor de "x" para avaliar o polinômio P(x).'),
        const SizedBox(height: 16),
        const Text('Detalhes Técnicos:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('• P(x) = f[x0] + f[x0, x1](x-x0) + f[x0, x1, x2](x-x0)(x-x1) + ...'),
        const Text('• Utiliza o operador de Diferenças Divididas para calcular os coeficientes.'),
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
          title: const Text('Forma de Newton'),
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
                          controller: _pontoAvaliacaoController,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          decoration: const InputDecoration(
                              labelText: 'Valor de x para avaliar',
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
            if (_coeficientesPadrao != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Polinômio Encontrado (Forma Padrão):',
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
                          _buildPolinomioLatex(_coeficientesPadrao!),
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
                    const Text('Diferenças Divididas (Coeficientes de Newton):',
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
                                label: Text('Ordem k',
                                    style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('f[x0, ..., xk]',
                                    style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Valor Aproximado',
                                    style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _coeficientesNewton!.asMap().entries.map((e) {
                            return DataRow(cells: [
                              DataCell(Text('${e.key}')),
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
