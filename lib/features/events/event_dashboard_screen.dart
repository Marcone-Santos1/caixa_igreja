import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../app/ui_kit.dart';
import '../../domain/payment_method.dart';
import '../../providers/event_dashboard_provider.dart';
import '../../providers/event_detail_provider.dart';
import '../../utils/money_format.dart';

enum DashboardTab { geral, produtos, outros }

class EventDashboardScreen extends ConsumerStatefulWidget {
  const EventDashboardScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventDashboardScreen> createState() => _EventDashboardScreenState();
}

class _EventDashboardScreenState extends ConsumerState<EventDashboardScreen> {
  DashboardTab _selectedTab = DashboardTab.geral;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _onlyCombos = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final dashboardAsync = ref.watch(eventDashboardProvider(widget.eventId));
    final scheme = Theme.of(context).colorScheme;

    final eventTitle = eventAsync.maybeWhen(
      data: (e) => e?.title ?? 'Dashboard',
      orElse: () => 'Dashboard',
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              eventTitle,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Erro ao carregar dashboard: $err',
              style: TextStyle(color: scheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (data) {
          if (data.totalSalesCount == 0) {
            return const CaixaEmptyHint(
              icon: Icons.analytics_outlined,
              message: 'Nenhuma venda registrada neste evento para gerar dados.',
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SegmentedButton<DashboardTab>(
                  selected: {_selectedTab},
                  onSelectionChanged: (set) {
                    setState(() {
                      _selectedTab = set.first;
                    });
                  },
                  segments: const [
                    ButtonSegment(
                      value: DashboardTab.geral,
                      icon: Icon(Icons.dashboard_outlined),
                      label: Text('Geral'),
                    ),
                    ButtonSegment(
                      value: DashboardTab.produtos,
                      icon: Icon(Icons.inventory_2_outlined),
                      label: Text('Produtos'),
                    ),
                    ButtonSegment(
                      value: DashboardTab.outros,
                      icon: Icon(Icons.toll_outlined),
                      label: Text('Fichas/Trocos'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedTab.index,
                  children: [
                    _buildGeralTab(context, data),
                    _buildProdutosTab(context, data),
                    _buildOutrosTab(context, data),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGeralTab(BuildContext context, EventDashboardData data) {
    final scheme = Theme.of(context).colorScheme;

    final maxHourlyCents = data.hourlyStats.isEmpty
        ? 0
        : data.hourlyStats.map((s) => s.totalCents).reduce(max);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Pending Change Alert Card
        if (data.totalPendingChangeCents > 0) ...[
          Card(
            color: Colors.orange.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.orange.shade700, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 28),
              title: Text(
                'Troco Pendente: ${formatCents(data.totalPendingChangeCents)}',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                'Há ${data.pendingChangeSales.length} cliente(s) aguardando troco',
                style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                const Divider(),
                ...data.pendingChangeSales.map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '• ${p.customerName} (Venda #${p.saleId})',
                          style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                        ),
                        Text(
                          formatCents(p.changeCents),
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Summary Cards Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: [
            Card(
              color: scheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monetization_on_outlined, color: scheme.onPrimaryContainer, size: 20),
                        const SizedBox(width: 6),
                        Text('Faturamento', style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Text(
                      formatCents(data.totalRevenueCents),
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: scheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined, color: scheme.onSecondaryContainer, size: 20),
                        const SizedBox(width: 6),
                        Text('Vendas Totais', style: TextStyle(color: scheme.onSecondaryContainer, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Text(
                      '${data.totalSalesCount}',
                      style: TextStyle(
                        color: scheme.onSecondaryContainer,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          color: scheme.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.confirmation_num_outlined, color: scheme.onTertiaryContainer, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ticket Médio Geral', style: TextStyle(color: scheme.onTertiaryContainer, fontSize: 12)),
                    Text(
                      formatCents(data.averageTicketCents),
                      style: TextStyle(
                        color: scheme.onTertiaryContainer,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Payment Breakdown Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formas de Pagamento',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...PaymentMethod.all.map((method) {
                  final cents = data.revenueByPaymentMethod[method] ?? 0;
                  final count = data.salesCountByPaymentMethod[method] ?? 0;
                  final avg = data.averageTicketByPaymentMethod[method] ?? 0;
                  final pct = data.totalRevenueCents > 0
                      ? cents / data.totalRevenueCents
                      : 0.0;
                  if (cents == 0) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(PaymentMethod.label(method), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '${formatCents(cents)} (${(pct * 100).toStringAsFixed(1)}%)',
                              style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$count vendas', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11)),
                            Text('Ticket médio: ${formatCents(avg)}', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: scheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Sales Velocity Card (Peak Hours)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fluxo de Vendas por Hora',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (data.hourlyStats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Sem dados de horário disponíveis.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                else
                  ...data.hourlyStats.map((stat) {
                    final pct = maxHourlyCents > 0
                        ? stat.totalCents / maxHourlyCents
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text(
                              stat.hourLabel,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 12,
                                backgroundColor: scheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(scheme.secondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 90,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatCents(stat.totalCents), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text('${stat.salesCount} vendas', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProdutosTab(BuildContext context, EventDashboardData data) {
    final scheme = Theme.of(context).colorScheme;

    final sourceList = _onlyCombos ? data.comboStats : data.productStats;
    final filteredStats = sourceList.where((p) {
      return p.name.toLowerCase().contains(_searchQuery);
    }).toList();

    final maxQtySold = data.productStats.isEmpty
        ? 0
        : data.productStats.map((s) => s.qtySold).reduce(max);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Filtrar por nome...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Todos os Produtos'),
                selected: !_onlyCombos,
                onSelected: (val) {
                  if (val) {
                    setState(() => _onlyCombos = false);
                  }
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Apenas Combos 📦'),
                selected: _onlyCombos,
                onSelected: (val) {
                  if (val) {
                    setState(() => _onlyCombos = true);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredStats.isEmpty
              ? const Center(
                  child: Text('Nenhum produto corresponde à busca.', style: TextStyle(color: Colors.grey)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredStats.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final p = filteredStats[i];
                    final pct = maxQtySold > 0 ? p.qtySold / maxQtySold : 0.0;

                    Widget stockBadge = const SizedBox.shrink();
                    if (p.trackStock) {
                      if (p.remainingStock <= 0) {
                        stockBadge = Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Esgotado', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      } else if (p.remainingStock <= 5) {
                        stockBadge = Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Restam ${p.remainingStock}', style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      } else {
                        stockBadge = Text(
                          'Estoque: ${p.remainingStock}',
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10),
                        );
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            p.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: p.active ? null : scheme.onSurface.withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                        if (p.isCombo) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('COMBO', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Faturado: ${formatCents(p.totalCents)}',
                                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
                                        ),
                                        const SizedBox(width: 8),
                                        if (p.trackStock) stockBadge,
                                        if (!p.active) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('Inativo', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${p.qtySold} saídas',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: scheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                p.qtySold > 0 ? scheme.primary : scheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOutrosTab(BuildContext context, EventDashboardData data) {
    final scheme = Theme.of(context).colorScheme;

    final maxFichaSold = data.fichaStats.isEmpty
        ? 0
        : data.fichaStats.map((s) => s.qtySold).reduce(max);

    final maxChangeDotQty = data.changeDotStats.isEmpty
        ? 0
        : data.changeDotStats.map((s) => s.qtyGiven).reduce(max);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Fichas/Dots sales section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendas de Fichas (Dots)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (data.fichaStats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nenhuma ficha cadastrada neste evento.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.fichaStats.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 16),
                    itemBuilder: (ctx, i) {
                      final f = data.fichaStats[i];
                      final pct = maxFichaSold > 0 ? f.qtySold / maxFichaSold : 0.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(
                                    'Faturado: ${formatCents(f.totalCents)} · Estoque: ${f.remainingStock}',
                                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
                                  ),
                                ],
                              ),
                              Text('${f.qtySold} saídas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: scheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                f.qtySold > 0 ? scheme.secondary : scheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Fichas given as Change section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fichas Entregues como Troco 🪙',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (data.changeDotStats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nenhuma ficha foi entregue como troco.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.changeDotStats.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 16),
                    itemBuilder: (ctx, i) {
                      final c = data.changeDotStats[i];
                      final pct = maxChangeDotQty > 0 ? c.qtyGiven / maxChangeDotQty : 0.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(
                                    'Total em troco: ${formatCents(c.totalCents)}',
                                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
                                  ),
                                ],
                              ),
                              Text('${c.qtyGiven} fichas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: scheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                c.qtyGiven > 0 ? scheme.tertiary : scheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Valores Avulsos section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valores Avulsos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (data.freeValueStats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nenhum valor avulso registrado.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.freeValueStats.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 12),
                    itemBuilder: (ctx, i) {
                      final f = data.freeValueStats[i];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              f.label,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(formatCents(f.totalCents), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${f.qtySold} registros', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
