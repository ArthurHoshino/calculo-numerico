import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:function_tree/function_tree.dart';
import '../../core/componentes/componentes.dart';

class PontoEntrada {
  final TextEditingController x = TextEditingController();
  final TextEditingController y = TextEditingController();

  void dispose() {
    x.dispose();
    y.dispose();
  }
}

class FormaSimpsonV2View extends StatefulWidget {
  final bool fillDefaultValues;
  const FormaSimpsonV2View({super.key, this.fillDefaultValues = true});

  @override
  State<FormaSimpsonV2View> createState() => _FormaSimpsonV2ViewState();
}

class _FormaSimpsonV2ViewState extends State<FormaSimpsonV2View> {
  final _formKey = GlobalKey<FormState>();

  bool _isModoFuncao = true;

  // Controladores para o modo de função
  late final _functionController = TextEditingController(text: widget.fillDefaultValues ? '1/x' : '');
  late final _limiteAController = TextEditingController(text: widget.fillDefaultValues ? '1' : '');
  late final _limiteBController = TextEditingController(text: widget.fillDefaultValues ? '3' : '');
  late final _nController = TextEditingController(text: widget.fillDefaultValues ? '6' : ''); // Default n multiple of 3
  
  // Controladores para o modo de pontos
  final List<PontoEntrada> _pontos = [PontoEntrada(), PontoEntrada(), PontoEntrada(), PontoEntrada()];

  bool _calculating = false;
  
  // Resultados comuns
  double? _resultadoIntegral;
  int? _n; // Quantidade de intervalos

  // Resultados modo função
  String? _funcaoStr;
  double? _limiteA;
  double? _limiteB;
  double? _h;

  // Resultados modo pontos
  List<Map<String, double>>? _pontosCalculados;

  @override
  void dispose() {
    _functionController.dispose();
    _limiteAController.dispose();
    _limiteBController.dispose();
    _nController.dispose();
    for (var p in _pontos) {
      p.dispose();
    }
    super.dispose();
  }

  void _adicionarPonto() {
    setState(() {
      _pontos.add(PontoEntrada());
    });
  }

  void _removerPonto(int index) {
    if (_pontos.length > 4) {
      setState(() {
        _pontos[index].dispose();
        _pontos.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('É necessário pelo menos 4 pontos para a regra 3/8 de Simpson.')));
    }
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _calculating = true;
      _funcaoStr = null;
      _resultadoIntegral = null;
      _pontosCalculados = null;
    });

    try {
      if (_isModoFuncao) {
        _calcularModoFuncao();
      } else {
        _calcularModoPontos();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}')));
    } finally {
      setState(() => _calculating = false);
    }
  }

  void _calcularModoFuncao() {
    final funcExpression = _functionController.text;
    final f = funcExpression.toSingleVariableFunction('x');

    double a = double.parse(_limiteAController.text.replaceAll(',', '.'));
    double b = double.parse(_limiteBController.text.replaceAll(',', '.'));
    int n = int.parse(_nController.text);

    if (n <= 0) throw Exception("O número de subintervalos (n) deve ser maior que zero.");
    if (n % 3 != 0) throw Exception("Para a regra 3/8 de Simpson, o número de subintervalos (n) deve ser múltiplo de 3.");

    // h = (b - a) / n
    double h = (b - a) / n;

    List<Map<String, double>> parsedPoints = [];

    // Adiciona o primeiro ponto a
    double fa = f(a).toDouble();
    parsedPoints.add({'x': a, 'y': fa});

    double somaMultiplos3 = 0;
    double somaOutros = 0;

    for (int i = 1; i < n; i++) {
      double xi = a + (h * i);
      double yi = f(xi).toDouble();
      
      if (i % 3 == 0) {
        somaMultiplos3 += yi;
      } else {
        somaOutros += yi;
      }
      
      parsedPoints.add({'x': xi, 'y': yi});
    }

    double fb = f(b).toDouble();
    parsedPoints.add({'x': b, 'y': fb});

    // Fórmula 3/8 de Simpson: I = (3h/8) * [f(a) + 3*Soma(outros) + 2*Soma(multiplos3) + f(b)]
    double somaTotal = fa + (3 * somaOutros) + (2 * somaMultiplos3) + fb;
    double integral = (3 * h / 8) * somaTotal;

    setState(() {
      _funcaoStr = funcExpression;
      _limiteA = a;
      _limiteB = b;
      _n = n;
      _h = h;
      _resultadoIntegral = integral;
      _pontosCalculados = parsedPoints;
    });
  }

  void _calcularModoPontos() {
    if (_pontos.length < 4) throw Exception("São necessários pelo menos 4 pontos para a regra 3/8 de Simpson.");
    if ((_pontos.length - 1) % 3 != 0) throw Exception("O número de subintervalos (pontos - 1) deve ser múltiplo de 3.");

    final funcExpression = _functionController.text;
    final f = funcExpression.toSingleVariableFunction('x');

    List<Map<String, double>> parsedPoints = [];
    for (var p in _pontos) {
      double x = double.parse(p.x.text.replaceAll(',', '.'));
      double y = f(x).toDouble();
      p.y.text = y.toStringAsFixed(6);
      parsedPoints.add({'x': x, 'y': y});
    }

    // Ordenar os pontos pelo eixo X
    parsedPoints.sort((a, b) => a['x']!.compareTo(b['x']!));

    // Verificar se os pontos estão igualmente espaçados (com pequena tolerância para float)
    double h = parsedPoints[1]['x']! - parsedPoints[0]['x']!;
    for (int i = 1; i < parsedPoints.length - 1; i++) {
      double currentH = parsedPoints[i + 1]['x']! - parsedPoints[i]['x']!;
      if ((currentH - h).abs() > 1e-5) {
        throw Exception("Os pontos devem ser igualmente espaçados para a regra 3/8 de Simpson.");
      }
    }

    int n = parsedPoints.length - 1;
    double somaMultiplos3 = 0;
    double somaOutros = 0;

    for (int i = 1; i < n; i++) {
      double yi = parsedPoints[i]['y']!;
      if (i % 3 == 0) {
        somaMultiplos3 += yi;
      } else {
        somaOutros += yi;
      }
    }

    double somaTotal = parsedPoints[0]['y']! + (3 * somaOutros) + (2 * somaMultiplos3) + parsedPoints[n]['y']!;
    double integral = (3 * h / 8) * somaTotal;

    setState(() {
      _funcaoStr = funcExpression;
      _pontosCalculados = parsedPoints;
      _n = n;
      _h = h; // Para modo pontos, h é a distância entre x_i e x_{i+1}
      _resultadoIntegral = integral;
    });
  }

  void _limpar() {
    setState(() {
      _functionController.clear();
      _limiteAController.clear();
      _limiteBController.clear();
      _nController.clear();
      for (var p in _pontos) {
        p.x.clear();
        p.y.clear();
      }
      _funcaoStr = null;
      _resultadoIntegral = null;
      _pontosCalculados = null;
    });
  }

  void _showInfo() {
    InfoDialog.show(
      context,
      titulo: 'Integração: Regra 3/8 de Simpson',
      conteudo: [
        const Text(
          'A Regra 3/8 de Simpson aproxima a integral definida usando polinômios de terceiro grau (cúbicos) em conjuntos de três subintervalos.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Como escrever as funções matemáticas:', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('• Operações básicas: Utilize +, -, * (vezes), / (divisão).'),
        const Text('• Frações: Utilize / e envolva em parênteses. Ex: (x+1)/(x-1), 1/2.'),
        const Text('• Potências e Expoentes: Utilize ^. Ex: x^2, 2^x, e^(2*x).'),
        const Text('• Raízes: Utilize sqrt(x) para raiz quadrada, ou potência fracionária para outras raízes. Ex: x^(1/3).'),
        const Text('• Constantes: Utilize e (Número de Euler) e pi (π).'),
        const Text('• Trigonométricas: Utilize sin(x), cos(x), tan(x).'),
        const SizedBox(height: 16),
        const Text('Modo Função:', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('• Insira a função a ser integrada em termos de x.'),
        const Text('• Defina o limite inferior (a) e o limite superior (b).'),
        const Text('• Escolha o número de subintervalos (n), que deve ser obrigatoriamente um MÚLTIPLO DE 3.'),
        const SizedBox(height: 16),
        const Text('Modo Pontos (Discretos):', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('• Adicione as coordenadas (x, y) de cada ponto conhecido.'),
        const Text('• É necessário um número de pontos que permita um n (pontos - 1) múltiplo de 3 (ex: 4, 7, 10 pontos).'),
        const Text('• Os valores de x devem ser obrigatoriamente espaçados de forma igual (constante h).'),
      ],
    );
  }

  String _formatarParaLatex(String expression) {
    try {
      final f = expression.toSingleVariableFunction('x');
      String tex = f.tex;
      
      // Corrigindo bugs da propriedade .tex da biblioteca function_tree:
      tex = tex.replaceAll('\x0C', '');
      tex = tex.replaceAll('rac{', r'\frac{');
      tex = tex.replaceAll(' cdot ', r' \cdot ');
      tex = tex.replaceAll('\x08', '');
      tex = tex.replaceAll(' mod ', r' \bmod ');
      tex = tex.replaceAll(' sin', r' \sin');
      tex = tex.replaceAll(' cos', r' \cos');
      tex = tex.replaceAll(' tan', r' \tan');
      
      // Remover .0 de inteiros (ex: 2.0 -> 2)
      tex = tex.replaceAll(RegExp(r'\.0(?!\d)'), '');
      
      return tex;
    } catch (_) {
      return expression; // Fallback se a função estiver incompleta
    }
  }

  Widget _buildModoFuncaoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Função f(x)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _functionController,
          decoration: const InputDecoration(
            labelText: 'f(x) (ex: x^2 + sqrt(x))',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
        ),
        const Divider(height: 32),
        const Text('Parâmetros da Integração', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _limiteAController,
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                decoration: const InputDecoration(labelText: 'Limite a (Início)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _limiteBController,
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                decoration: const InputDecoration(labelText: 'Limite b (Fim)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número de subintervalos (n múltiplo de 3)', 
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.bar_chart)
          ),
          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
        ),
      ],
    );
  }

  Widget _buildModoPontosForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Função f(x)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _functionController,
          decoration: const InputDecoration(
            labelText: 'f(x) (ex: x^2 + sqrt(x))',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tabela de Pontos (x, y)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _adicionarPonto, 
              icon: const Icon(Icons.add), 
              label: const Text('ADICIONAR')
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._pontos.asMap().entries.map((entry) {
          int idx = entry.key;
          PontoEntrada p = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  child: Text('${idx + 1}', style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: p.x,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    decoration: const InputDecoration(labelText: 'x', border: OutlineInputBorder(), isDense: true),
                    validator: (v) => v!.isEmpty ? '?' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: p.y,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    decoration: const InputDecoration(labelText: 'y (auto)', border: OutlineInputBorder(), isDense: true),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  onPressed: () => _removerPonto(idx),
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  tooltip: 'Remover',
                )
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Regra 3/8 de Simpson'),
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
            // Switch mode
            Center(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Por Função'),
                    icon: Icon(Icons.functions),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Por Pontos'),
                    icon: Icon(Icons.scatter_plot),
                  ),
                ],
                selected: {_isModoFuncao},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isModoFuncao = newSelection.first;
                    // Limpar resultados se alterar o modo
                    _resultadoIntegral = null;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isModoFuncao ? _buildModoFuncaoForm() : _buildModoPontosForm(),
                      const SizedBox(height: 24),
                      Row(children: [
                        Expanded(child: OutlinedButton(onPressed: _limpar, child: const Text('LIMPAR'))),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: _calculating ? null : _calcular,
                            child: _calculating ? const CircularProgressIndicator(color: Colors.white) : const Text('CALCULAR')
                          )
                        ),
                      ])
                    ],
                  )
                ),
              ),
            ),
            if (_resultadoIntegral != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isModoFuncao && _funcaoStr != null) ...[
                      const Text('Função Integrada:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            'f(x) = ${_formatarParaLatex(_funcaoStr!)}',
                            textStyle: TextStyle(fontSize: 22, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (!_isModoFuncao && _pontosCalculados != null) ...[
                      const Text('Pontos Ordenados Utilizados:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _pontosCalculados!.map((p) => Chip(
                          label: Text('(${p['x']!.toStringAsFixed(2)}, ${p['y']!.toStringAsFixed(2)})'),
                          backgroundColor: Colors.blue.shade50,
                        )).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text('Resultado da Integral:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _isModoFuncao 
                                ? Math.tex(
                                    '\\int_{${_limiteA!}}^{${_limiteB!}} f(x) dx \\approx ${_resultadoIntegral!.toStringAsFixed(6)}',
                                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  )
                                : Math.tex(
                                    '\\text{Área Total} \\approx ${_resultadoIntegral!.toStringAsFixed(6)}',
                                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                            ),
                            const Divider(),
                            Text(
                              'Quantidade de Intervalos (n): ${_n!}',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            if (_h != null)
                              Text(
                                'Passo (h): ${_h!.toStringAsFixed(6)}',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_pontosCalculados != null) ...[
                      const SizedBox(height: 24),
                      const Text('Tabela de Pontos Gerados:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                            columns: const [
                              DataColumn(label: Text('i', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('x', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('y = f(x)', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _pontosCalculados!.asMap().entries.map((entry) {
                              int i = entry.key;
                              Map<String, double> p = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text(i.toString())),
                                  DataCell(Text(p['x']!.toStringAsFixed(6))),
                                  DataCell(Text(p['y']!.toStringAsFixed(6))),
                                ]
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
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