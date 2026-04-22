import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_theme.dart';
import '../../app/ui_kit.dart';
import '../../domain/payment_method.dart';
import '../../domain/stock_constants.dart';
import '../../providers/event_detail_provider.dart';
import '../../providers/event_finance_provider.dart';
import '../../providers/event_low_stock_provider.dart';
import '../../utils/money_format.dart';
import 'event_form_screen.dart';

final _dateFmt = DateFormat.yMMMEd('pt_BR');

class EventHubScreen extends ConsumerWidget {
  const EventHubScreen({super.key, required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(eventDetailProvider(eventId));
    void goBackToEvents() {
      context.go('/events');
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goBackToEvents();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: goBackToEvents,
          ),
          title: const Text('Evento'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => EventFormScreen(eventId: eventId),
                  ),
                );
                if (context.mounted) {
                  ref.invalidate(eventDetailProvider(eventId));
                }
              },
            ),
          ],
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Erro: $e',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          data: (e) {
            if (e == null) {
              return const CaixaEmptyHint(
                icon: Icons.event_busy_outlined,
                message: 'Evento não encontrado',
              );
            }
            final day = DateTime.fromMillisecondsSinceEpoch(e.dateEpochMs);
            final scheme = Theme.of(context).colorScheme;
            return ListView(
              padding: kCaixaScreenPadding.copyWith(top: 16, bottom: 28),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.4,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _dateFmt.format(day),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        if (e.notes.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            e.notes,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.45,
                                  color: scheme.onSurface,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _LowStockBanner(eventId: eventId),
                const SizedBox(height: 14),
                _FinanceSummaryCard(eventId: eventId),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () => context.push('/event/$eventId/produtos'),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Produtos do evento'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => context.push('/event/$eventId/sale'),
                  icon: const Icon(Icons.add_shopping_cart_outlined),
                  label: const Text('Nova venda'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push('/event/$eventId/fichas'),
                  icon: const Icon(Icons.toll_outlined),
                  label: const Text('Gerenciar fichas'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push('/event/$eventId/vendas'),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Registro de vendas'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LowStockBanner extends ConsumerWidget {
  const _LowStockBanner({required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(eventLowStockCountsProvider(eventId));
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
      data: (c) {
        if (!c.hasAny) return const SizedBox.shrink();
        return Material(
          color: scheme.errorContainer.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: scheme.error, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stock baixo (≤ $kLowStockThreshold)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    if (c.lowProductCount > 0)
                      '${c.lowProductCount} produto(s) com stock baixo',
                    if (c.lowDotCount > 0)
                      '${c.lowDotCount} ficha(s) com stock baixo',
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onErrorContainer,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (c.lowProductCount > 0)
                      TextButton(
                        onPressed: () => context.push('/event/$eventId/produtos'),
                        child: const Text('Ver produtos'),
                      ),
                    if (c.lowDotCount > 0)
                      TextButton(
                        onPressed: () => context.push('/event/$eventId/fichas'),
                        child: const Text('Ver fichas'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FinanceSummaryCard extends ConsumerWidget {
  const _FinanceSummaryCard({required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(eventFinanceSummaryProvider(eventId));
    return async.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Erro ao carregar resumo: $e',
            style: TextStyle(color: scheme.error),
          ),
        ),
      ),
      data: (s) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo financeiro',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                if (s.saleCount == 0)
                  Text(
                    'Ainda não há vendas neste evento.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total vendido',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        formatCents(s.totalCents),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${s.saleCount} venda(s)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  if (s.cashChangeGivenCents > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Troco em dinheiro (soma)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          formatCents(s.cashChangeGivenCents),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                  if (s.byMethod.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Por método de pagamento',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    for (final b in s.byMethod)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                PaymentMethod.label(b.method),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '${b.saleCount}× · ${formatCents(b.totalCents)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
