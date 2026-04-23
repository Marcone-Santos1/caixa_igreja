import 'package:flutter/material.dart';

Future<bool> confirmDeleteEventDialog(
  BuildContext context, {
  required String eventTitle,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir evento?'),
      content: Text(
        'Isto remove permanentemente o evento "$eventTitle", todas as vendas, '
        'produtos e fichas associados. Não dá para desfazer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
            foregroundColor: Theme.of(ctx).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return ok == true;
}
