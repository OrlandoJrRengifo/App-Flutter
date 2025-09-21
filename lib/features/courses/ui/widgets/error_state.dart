import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error, size: 48, color: Colors.red),
        const SizedBox(height: 8),
        const Text("Ocurrió un error"),
        ElevatedButton(onPressed: onRetry, child: const Text("Reintentar")),
      ]),
    );
  }
}
