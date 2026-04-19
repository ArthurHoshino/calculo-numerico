import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String titulo;
  final List<Widget> conteudo;

  const InfoDialog({
    super.key,
    required this.titulo,
    required this.conteudo,
  });

  static void show(BuildContext context, {required String titulo, required List<Widget> conteudo}) {
    showDialog(
      context: context,
      builder: (context) => InfoDialog(titulo: titulo, conteudo: conteudo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), // Diminui o respiro lateral padrão
      title: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(titulo)),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8, // Define a largura como 80% da tela
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: conteudo,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ENTENDI'),
        ),
      ],
    );
  }
}
