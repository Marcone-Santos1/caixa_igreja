import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../providers/printer_provider.dart';

/// Tela para gerenciamento de conexão e teste de impressão térmica via Bluetooth.
class PrinterSetupScreen extends ConsumerStatefulWidget {
  const PrinterSetupScreen({super.key});

  @override
  ConsumerState<PrinterSetupScreen> createState() => _PrinterSetupScreenState();
}

class _PrinterSetupScreenState extends ConsumerState<PrinterSetupScreen> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isLoadingDevices = false;
  bool _isConnecting = false;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final printerService = ref.read(printerServiceProvider);
    final connected = await printerService.isConnected();
    if (mounted) {
      setState(() => _isConnected = connected);
    }
    await _fetchBondedDevices();
  }

  Future<void> _fetchBondedDevices() async {
    setState(() => _isLoadingDevices = true);
    try {
      final printerService = ref.read(printerServiceProvider);
      final devices = await printerService.getBondedDevices();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        if (_selectedDevice == null && devices.isNotEmpty) {
          _selectedDevice = devices.first;
        } else if (_selectedDevice != null &&
            !devices.any((d) => d.address == _selectedDevice!.address)) {
          _selectedDevice = devices.isNotEmpty ? devices.first : null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar dispositivos Bluetooth: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDevices = false);
      }
    }
  }

  Future<void> _toggleConnection() async {
    final printerService = ref.read(printerServiceProvider);
    if (_isConnected) {
      setState(() => _isConnecting = true);
      try {
        await printerService.disconnect();
        if (!mounted) return;
        setState(() => _isConnected = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impressora desconectada.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) setState(() => _isConnecting = false);
      }
    } else {
      if (_selectedDevice == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione uma impressora na lista antes de conectar.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      setState(() => _isConnecting = true);
      try {
        final success = await printerService.connect(_selectedDevice!);
        if (!mounted) return;
        setState(() => _isConnected = success);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Impressora "${_selectedDevice?.name ?? 'Bluetooth'}" conectada com sucesso!'
                  : 'Não foi possível conectar à impressora. Verifique se ela está ligada.',
            ),
            backgroundColor: success
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha na conexão: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        if (mounted) setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _printTestTicket() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conecte a impressora antes de imprimir o teste.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isPrinting = true);
    try {
      final printerService = ref.read(printerServiceProvider);
      await printerService.printTicket(
        orderNumber: '001',
        items: [
          {
            'name': 'Pastel de Carne',
            'qty': 2,
            'subtotal': 20.0,
          },
          {
            'name': 'Refrigerante Lata',
            'qty': 1,
            'subtotal': 6.0,
          },
        ],
        total: 26.0,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket de teste enviado para a impressora!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao imprimir ticket: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Future<void> _printTestVoucher() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conecte a impressora antes de imprimir o teste.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isPrinting = true);
    try {
      final printerService = ref.read(printerServiceProvider);
      final perUnit = ref.read(deliveryVouchersPerUnitProvider);
      await printerService.printDeliveryVouchers(
        orderNumber: '001',
        items: [
          {'name': 'Pastel de Carne', 'qty': 2},
          {'name': 'Refrigerante Lata', 'qty': 1},
        ],
        eventTitle: 'FESTA DA PADROEIRA',
        customerName: 'Cliente Teste',
        perUnit: perUnit,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ficha de teste enviada para a impressora!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao imprimir ficha: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressora Térmica'),
      ),
      body: ListView(
        padding: kCaixaScreenPadding.copyWith(bottom: 32),
        children: [
          // Card de Status da Conexão
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _isConnected
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    foregroundColor:
                        _isConnected ? scheme.primary : scheme.outline,
                    child: Icon(
                      _isConnected
                          ? Icons.print_rounded
                          : Icons.print_disabled_outlined,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isConnected ? 'Impressora Conectada' : 'Desconectada',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isConnected && _selectedDevice != null
                              ? '${_selectedDevice!.name ?? 'Dispositivo'} (${_selectedDevice!.address})'
                              : 'Nenhuma impressora ativa no momento',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isConnected
                          ? scheme.primary.withValues(alpha: 0.12)
                          : scheme.error.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isConnected ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: _isConnected ? scheme.primary : scheme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Card de Preferência: Imprimir a cada venda
          Card(
            child: SwitchListTile(
              secondary: Icon(
                Icons.receipt_long_rounded,
                color: scheme.primary,
              ),
              title: const Text('Imprimir cupom a cada venda'),
              subtitle: const Text(
                'Emite o comprovante geral na impressora automaticamente ao finalizar cada venda.',
              ),
              value: ref.watch(autoPrintEnabledProvider),
              onChanged: (val) {
                ref.read(autoPrintEnabledProvider.notifier).toggle(val);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Card de Preferência: Fichas de Retirada no Balcão
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.confirmation_number_outlined,
                    color: scheme.primary,
                  ),
                  title: const Text('Fichas de Balcão (Cozinha e Bar)'),
                  subtitle: const Text(
                    'Emite canhotos destacados para o cliente retirar os itens nos setores.',
                  ),
                  value: ref.watch(printDeliveryVouchersEnabledProvider),
                  onChanged: (val) {
                    ref.read(printDeliveryVouchersEnabledProvider.notifier).toggle(val);
                  },
                ),
                if (ref.watch(printDeliveryVouchersEnabledProvider)) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      ref.watch(deliveryVouchersPerUnitProvider)
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: ref.watch(deliveryVouchersPerUnitProvider)
                          ? scheme.primary
                          : scheme.outline,
                    ),
                    title: const Text('1 ficha para cada unidade'),
                    subtitle: const Text('Ex: 3 Pastéis emitem 3 fichas individuais de 1x'),
                    onTap: () {
                      ref.read(deliveryVouchersPerUnitProvider.notifier).toggle(true);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      !ref.watch(deliveryVouchersPerUnitProvider)
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: !ref.watch(deliveryVouchersPerUnitProvider)
                          ? scheme.primary
                          : scheme.outline,
                    ),
                    title: const Text('1 ficha agrupada por produto'),
                    subtitle: const Text('Ex: 3 Pastéis emitem 1 ficha com "3x Pastel"'),
                    onTap: () {
                      ref.read(deliveryVouchersPerUnitProvider.notifier).toggle(false);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dispositivos Pareados (Bluetooth)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Localize e selecione a mini impressora térmica de 58mm pareada no sistema.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (_devices.isEmpty && !_isLoadingDevices)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Nenhum dispositivo Bluetooth pareado foi encontrado. '
                        'Vá nas configurações de Bluetooth do Android, pareie a impressora e toque em "Buscar Impressoras".',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  else
                    DropdownButtonFormField<BluetoothDevice>(
                      initialValue: _selectedDevice,
                      decoration: const InputDecoration(
                        labelText: 'Selecione a Impressora',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bluetooth_searching),
                      ),
                      items: _devices.map((device) {
                        return DropdownMenuItem<BluetoothDevice>(
                          value: device,
                          child: Text(
                            '${device.name ?? 'Sem nome'} (${device.address})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _isConnected
                          ? null
                          : (device) {
                              setState(() => _selectedDevice = device);
                            },
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (_isLoadingDevices || _isConnecting)
                              ? null
                              : _fetchBondedDevices,
                          icon: _isLoadingDevices
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          label: const Text('Buscar Impressoras'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: (_isConnecting ||
                                  (_selectedDevice == null && !_isConnected))
                              ? null
                              : _toggleConnection,
                          style: _isConnected
                              ? FilledButton.styleFrom(
                                  backgroundColor: scheme.error,
                                  foregroundColor: scheme.onError,
                                )
                              : null,
                          icon: _isConnecting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _isConnected
                                      ? Icons.bluetooth_disabled
                                      : Icons.bluetooth_connected,
                                ),
                          label: Text(_isConnected ? 'Desconectar' : 'Conectar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Card de Teste de Impressão ESC/POS
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 20,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Teste de Impressão (58mm)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dispara um ticket de teste com layout de cantina (cabeçalho, data/hora, senha 001, itens mockados e remoção automática de acentuação).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: (!_isConnected || _isPrinting)
                        ? null
                        : _printTestTicket,
                    icon: _isPrinting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.receipt_outlined),
                    label: const Text('Imprimir Cupom Geral de Teste'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: (!_isConnected || _isPrinting)
                        ? null
                        : _printTestVoucher,
                    icon: const Icon(Icons.confirmation_number_outlined),
                    label: const Text('Imprimir Ficha de Balcão de Teste'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
