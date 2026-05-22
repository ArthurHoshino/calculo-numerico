import 'package:flutter/material.dart';
import '../../core/componentes/componentes.dart';

class PassoGaussSeidel {
  final int k;
  final List<double> valores;
  final double erro;

  PassoGaussSeidel({
    required this.k,
    required this.valores,
    required this.erro,
  });
}

class GaussSeidelView extends StatefulWidget {
  final bool fillDefaultValues;
  const GaussSeidelView({super.key, this.fillDefaultValues = true});

  @override
  State<GaussSeidelView> createState() => _GaussSeidelViewState();
}

class _GaussSeidelViewState extends State<GaussSeidelView> {
  final _formKey = GlobalKey<FormState>();
  
  late final List<TextEditingController> _equacaoControllers = widget.fillDefaultValues ? [
    TextEditingController(text: '20 1 1 2 33'),
    TextEditingController(text: '1 10 2 4 38.4'),
    TextEditingController(text: '1 2 10 1 43.5'),
    TextEditingController(text: '2 4 1 20 45.6'),
  ] : [TextEditingController(), TextEditingController()];
  
  late final _toleranciaController = TextEditingController(text: widget.fillDefaultValues ? "0.001" : "");
  late final _casasDecimaisController = TextEditingController(text: widget.fillDefaultValues ? "5" : "");
  late final _maxIteracoesController = TextEditingController(text: widget.fillDefaultValues ? "100" : "");

  bool _calculating = false;
  List<PassoGaussSeidel> _passos = [];
  List<double>? _solucao;
  int _qtdVariaveis = 0;

  void _addInput() {
    setState(() {
      _equacaoControllers.add(TextEditingController());
    });
  }

  void _removeInput(int index) {
    if (_equacaoControllers.length > 1) {
      setState(() {
        _equacaoControllers[index].dispose();
        _equacaoControllers.removeAt(index);
      });
    }
  }

  bool _criterioDeConvergenciaDeLinha(List<List<double>> indices) {
    int n = indices.length;
    for (int i = 0; i < n; i++) {
      double soma = 0;
      for (int j = 0; j < n; j++) {
        if (i != j) {
          soma += indices[i][j].abs();
        }
      }
      if (indices[i][i].abs() == 0 || soma / indices[i][i].abs() >= 1) return false;
    }
    return true;
  }

  bool _criterioDeConvergenciaDeColuna(List<List<double>> indices) {
    int n = indices.length;
    for (int j = 0; j < n; j++) {
      double soma = 0;
      for (int i = 0; i < n; i++) {
        if (i != j) {
          soma += indices[i][j].abs();
        }
      }
      if (indices[j][j].abs() == 0 || soma / indices[j][j].abs() >= 1) return false;
    }
    return true;
  }

  bool _criterioDeConvergenciaDeSassenfeld(List<List<double>> indices) {
    int n = indices.length;
    List<double> betas = List.filled(n, 0.0);

    for (int i = 0; i < n; i++) {
      double soma = 0;
      // Termos com betas já calculados (j < i)
      for (int j = 0; j < i; j++) {
        soma += indices[i][j].abs() * betas[j];
      }
      // Termos ainda não calculados (j > i)
      for (int j = i + 1; j < n; j++) {
        soma += indices[i][j].abs();
      }
      
      if (indices[i][i].abs() == 0) return false;
      
      betas[i] = soma / indices[i][i].abs();
    }

    double maxBeta = betas.reduce((curr, next) => curr > next ? curr : next);
    return maxBeta < 1;
  }

  void _calcular() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _calculating = true;
      _passos = [];
      _solucao = null;
    });

    try {
      final n = _equacaoControllers.length;
      _qtdVariaveis = n;
      List<List<double>> matrizIndices = List.generate(n, (_) => List.filled(n, 0.0));
      List<double> matrizValores = List.filled(n, 0.0);

      for (int i = 0; i < n; i++) {
        String texto = _equacaoControllers[i].text.trim().replaceAll(RegExp(r'\s+'), ' ');
        List<String> partes = texto.split(' ');
        
        if (partes.length != n + 1) {
          throw Exception('A linha ${i + 1} deve ter ${n + 1} valores (coeficientes e termo independente).');
        }

        for (int j = 0; j < n; j++) {
          matrizIndices[i][j] = double.parse(partes[j].replaceAll(',', '.'));
        }
        matrizValores[i] = double.parse(partes[n].replaceAll(',', '.'));
      }

      bool convergeLinha = _criterioDeConvergenciaDeLinha(matrizIndices);
      bool convergeColuna = _criterioDeConvergenciaDeColuna(matrizIndices);
      bool convergeSassenfeld = _criterioDeConvergenciaDeSassenfeld(matrizIndices);

      if (!convergeLinha && !convergeColuna && !convergeSassenfeld) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aviso: O sistema não atende aos critérios de convergência (Linha, Coluna ou Sassenfeld). O método pode divergir.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      final tolerancia = double.parse(_toleranciaController.text.replaceAll(',', '.'));
      final maxIter = int.parse(_maxIteracoesController.text);
      
      List<double> x = List.filled(n, 0.0); // Chute inicial zeros
      List<PassoGaussSeidel> passosLocais = [];
      
      double erro = double.infinity;
      int k = 0;

      while (erro > tolerancia && k < maxIter) {
        List<double> xAntigo = List.from(x);
        
        for (int i = 0; i < n; i++) {
          double soma = 0;
          for (int j = 0; j < n; j++) {
            if (i != j) {
              soma += matrizIndices[i][j] * x[j];
            }
          }
          
          if (matrizIndices[i][i] == 0) {
            throw Exception('O elemento da diagonal principal a[${i+1}][${i+1}] é zero. Reordene as equações.');
          }
          
          x[i] = (matrizValores[i] - soma) / matrizIndices[i][i];
        }

        // Cálculo do erro (norma infinita da diferença absoluta)
        double maxDiff = 0;
        for (int i = 0; i < n; i++) {
          double diff = (x[i] - xAntigo[i]).abs();
          if (diff > maxDiff) maxDiff = diff;
        }
        
        erro = maxDiff; 

        k++;
        passosLocais.add(PassoGaussSeidel(
          k: k,
          valores: List.from(x),
          erro: erro,
        ));
      }

      setState(() {
        _passos = passosLocais;
        _solucao = x;
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _calculating = false);
    }
  }

  void _limpar() {
    setState(() {
      for (var c in _equacaoControllers) {
        c.clear();
      }
      _passos = [];
      _solucao = null;
    });
  }

  void _showInfo() {
    InfoDialog.show(
      context,
      titulo: 'Método de Gauss-Seidel',
      conteudo: [
        const Text('Método iterativo para resolver sistemas lineares Ax = b.'),
        const SizedBox(height: 8),
        const Text('Critério de Convergência:', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('O método converge se a matriz atender ao Critério de Linha (Diagonal Dominante), Coluna ou Sassenfeld.'),
        const SizedBox(height: 8),
        const Text('Como usar:', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('1. Adicione o número de equações desejado.'),
        const Text('2. Em cada linha, digite os coeficientes seguidos pelo termo independente, separados por espaço.'),
        const Text('Ex: Para 10x1 + 2x2 = 12, digite "10 2 12".'),
      ],
    );
  }

  @override
  void dispose() {
    for (var c in _equacaoControllers) {
      c.dispose();
    }
    _toleranciaController.dispose();
    _casasDecimaisController.dispose();
    _maxIteracoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int precisao = int.tryParse(_casasDecimaisController.text) ?? 5;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gauss-Seidel'),
          actions: [
            IconButton(onPressed: _showInfo, icon: const Icon(Icons.info_outline)),
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
                    children: [
                      ..._equacaoControllers.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: entry.value,
                                  decoration: InputDecoration(
                                    labelText: 'Equação ${entry.key + 1}',
                                    hintText: 'Ex: 10 2 1 13',
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                                ),
                              ),
                              if (_equacaoControllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeInput(entry.key),
                                )
                            ],
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: _addInput,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Equação'),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _toleranciaController,
                              decoration: const InputDecoration(labelText: 'Tolerância', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _casasDecimaisController,
                              decoration: const InputDecoration(labelText: 'Casas Decimais', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _maxIteracoesController,
                        decoration: const InputDecoration(labelText: 'Máx. Iterações', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(onPressed: _limpar, child: const Text('LIMPAR')),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: _calculating ? null : _calcular,
                              child: _calculating ? const CircularProgressIndicator() : const Text('CALCULAR'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            if (_solucao != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solução do Sistema:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._solucao!.asMap().entries.map((entry) {
                      return Card(
                        color: Colors.blue.shade50,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text('x${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          title: Text(
                            entry.value.toStringAsFixed(precisao),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text('Valor encontrado na iteração ${_passos.last.k}'),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    const Text(
                      'Tabela de Iterações:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
                          columns: [
                            const DataColumn(label: Text('k', style: TextStyle(fontWeight: FontWeight.bold))),
                            ...List.generate(_qtdVariaveis, (i) => DataColumn(label: Text('x${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)))),
                            const DataColumn(label: Text('Erro', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _passos.map((p) => DataRow(
                            cells: [
                              DataCell(Text(p.k.toString())),
                              ...p.valores.map((v) => DataCell(Text(v.toStringAsFixed(precisao)))),
                              DataCell(Text(p.erro.toStringAsFixed(precisao))),
                            ],
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
