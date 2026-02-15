import 'package:flutter/material.dart';

class MetodoCard extends StatelessWidget {
  final BuildContext context;
  final String titulo;
  final IconData icone;
  final VoidCallback? onTap;
  final bool isActive;

  const MetodoCard({
    super.key,
    required this.context,
    required this.titulo,
    required this.icone,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isActive ? onTap : null,
        child: Opacity(
          opacity: isActive ? 1.0 : 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                titulo,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (!isActive)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('(Em breve)', style: TextStyle(fontSize: 10)),
                )
            ],
          ),
        ),
      ),
    );
  }
}
