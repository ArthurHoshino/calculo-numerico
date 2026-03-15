import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import '../../core/componentes/componentes.dart';

class TriangulacaoGaussView extends StatefulWidget {
  const TriangulacaoGaussView({super.key});

  @override
  State<TriangulacaoGaussView> createState() => _TriangulacaoGaussViewState();
}

class _TriangulacaoGaussViewState extends State<TriangulacaoGaussView> {
  final _formKey = GlobalKey<FormState>();
  
  // Lista dinâmica de controllers para as equações/linhas da matriz
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _calculating = false;
  List<Fraction>? _solucao;
  List<List<Fraction>>? _matrizTriangular;

  void _addInput() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeInput(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    }
  }

  void _calcular() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _calculating = true;
      _solucao = null;
      _matrizTriangular = null;
    });

    try {
      List<List<Fraction>> matriz = [];

      for (var controller in _controllers) {
        String texto = controller.text.trim().replaceAll(RegExp(r'\s+'), ' ');
        if (texto.isEmpty) continue;
        
        List<Fraction> linha = texto.split(' ').map((e) => Fraction.fromString(e)).toList();
        matriz.add(linha);
      }

      int n = matriz.length;
      if (n == 0) throw Exception('Insira ao menos uma linha.');

      // Validação: cada linha deve ter n coeficientes + 1 termo independente
      for (var linha in matriz) {
        if (linha.length != n + 1) {
          throw Exception('Cada linha deve ter exatamente ${n + 1} valores (coeficientes e termo independente).');
        }
      }

      // 1. Triangulação de Gauss com Pivoteamento Parcial
      for (int i = 0; i < n; i++) {
        // Encontrar o maior pivô na coluna i (pivoteamento parcial)
        int linhaMaxima = i;
        Fraction valorMaximo = matriz[i][i];
        for (int k = i + 1; k < n; k++) {
          Fraction valorAtual = matriz[k][i];
          if (valorAtual.compareTo(valorMaximo) > 0) {
            valorMaximo = valorAtual;
            linhaMaxima = k;
          }
        }

        // Trocar linhas i e linhaMaxima
        List<Fraction> temp = matriz[i];
        matriz[i] = matriz[linhaMaxima];
        matriz[linhaMaxima] = temp;

        // Se o pivô for zero, o sistema pode não ter solução única
        if (matriz[i][i].toDouble() == 0) {
          throw Exception('Pivô nulo encontrado na coluna ${i + 1}. O sistema pode não ter uma solução única.');
        }

        // Zerar os elementos abaixo do pivô
        for (int j = i + 1; j < n; j++) {
          Fraction multiplicador = (matriz[j][i] / matriz[i][i]).reduce();
          
          for (int k = i; k <= n; k++) {
            matriz[j][k] = (matriz[j][k] - (multiplicador * matriz[i][k])).reduce();
          }
        }
      }

      // 2. Substituição Regressiva
      List<Fraction> x = List.filled(n, Fraction(0));
      for (int i = n - 1; i >= 0; i--) {
        Fraction soma = Fraction(0);
        for (int j = i + 1; j < n; j++) {
          soma = (soma + (matriz[i][j] * x[j])).reduce();
        }
        x[i] = ((matriz[i][n] - soma) / matriz[i][i]).reduce();
      }

      setState(() {
        _solucao = x;
        _matrizTriangular = matriz;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() => _calculating = false);
    }
  }

  void _limparFormulario() {
    setState(() {
      for (var controller in _controllers) {
        controller.clear();
      }
      _solucao = null;
      _matrizTriangular = null;
      _calculating = false;
    });
  }

  void _showInfo() {
    InfoDialog.show(
      context,
      titulo: 'Triangulação de Gauss',
      conteudo: [
        const Text(
          'Este método transforma um sistema linear em um sistema triangular superior equivalente.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Como usar:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('• Insira cada linha do sistema (coeficientes e termo independente).'),
        const Text('• Exemplo para 2x - 3y + 0z = 8/3: "2 -3 0 8/3"'),
        const Text('• Clique no botão "+" para adicionar mais equações.'),
        const SizedBox(height: 16),
        const Text(
          'O algoritmo utiliza pivoteamento parcial (seleciona o maior valor da coluna para o topo) para maior estabilidade numérica.',
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Triangulação de Gauss'),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Insira as linhas da matriz (Ex: 2 3 8)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      
                      // Gerador dinâmico de campos
                      ..._controllers.asMap().entries.map((entry) {
                        int idx = entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: entry.value,
                                  decoration: InputDecoration(
                                    labelText: 'Equação ${idx + 1}',
                                    border: const OutlineInputBorder(),
                                    hintText: 'Valores separados por espaço',
                                    prefixIcon: const Icon(Icons.linear_scale),
                                  ),
                                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                                ),
                              ),
                              if (_controllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeInput(idx),
                                ),
                            ],
                          ),
                        );
                      }),

                      // Botão para adicionar mais campos
                      Center(
                        child: TextButton.icon(
                          onPressed: _addInput,
                          icon: const Icon(Icons.add),
                          label: const Text('ADICIONAR EQUAÇÃO'),
                        ),
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
                              onPressed: _calculating ? null : _calcular,
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
            if (_solucao != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
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
                            entry.value.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text('≈ ${entry.value.toDouble().toStringAsFixed(6)}'),
                        ),
                      );
                    }),
                    
                    if (_matrizTriangular != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Matriz Escalonada (Triangular Superior):',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Table(
                            defaultColumnWidth: const IntrinsicColumnWidth(),
                            children: _matrizTriangular!.map((linha) {
                              return TableRow(
                                children: linha.map((celula) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Text(
                                      celula.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontFamily: 'monospace'),
                                    ),
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (!_calculating) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text("Insira os coeficientes e calcule para ver o resultado.")),
              )
            ]
          ],
        ),
      ),
    );
  }
}
