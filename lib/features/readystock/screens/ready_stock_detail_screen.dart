import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/item_model.dart';
import '../../../data/repositories/providers.dart';

class ReadyStockDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ReadyStockDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  ConsumerState<ReadyStockDetailScreen> createState() => _ReadyStockDetailScreenState();
}

class _ReadyStockDetailScreenState extends ConsumerState<ReadyStockDetailScreen> {
  int get numericItemId => int.tryParse(widget.itemId) ?? 0;

  void _showMovementModal(BuildContext context, ItemModel item, bool isStockIn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReadyStockMovementModal(item: item, isStockIn: isStockIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemByIdProvider(numericItemId));
    final txsAsync = ref.watch(stockTransactionsStreamProvider(numericItemId));

    return itemAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Ready Stock Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/ready-stock'),
          ),
        ),
        body: Center(child: Text('Error: $err')),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ready Stock Detail'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/ready-stock'),
              ),
            ),
            body: const Center(child: Text('Colour item not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${item.name} — Ready Stock'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/ready-stock');
                }
              },
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;
              final padding = isTablet ? 24.0 : 16.0;

              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 700 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Quantity Summary Card
                        _buildSummaryCard(item),
                        const SizedBox(height: 16),

                        // 2. Action Buttons (+ Stock In, - Stock Out, Adjust Stock)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showMovementModal(context, item, true),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('+ Stock In'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showMovementModal(context, item, false),
                                icon: const Icon(Icons.remove, size: 18),
                                label: const Text('- Stock Out'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.critical,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => context.go('/stock/${item.id}/adjust'),
                              icon: const Icon(Icons.tune, size: 18),
                              label: const Text('Adjust'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                side: const BorderSide(color: AppColors.borderLight),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 3. Transaction History Title
                        const Text(
                          'STOCK MOVEMENT HISTORY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 4. Transaction List
                        txsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error history: $err'),
                          data: (txs) {
                            if (txs.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.history, size: 36, color: AppColors.textMuted),
                                    SizedBox(height: 8),
                                    Text(
                                      'No Stock History Yet',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Use + Stock In or - Stock Out to record movements.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: txs.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final itemTx = txs[index];
                                final tx = itemTx.transaction;
                                final isPos = tx.quantity > 0;
                                final dateStr =
                                    '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}';
                                final qtyVal = tx.quantity.abs();
                                final formattedQty =
                                    '${isPos ? '+' : '-'}${qtyVal % 1 == 0 ? qtyVal.toInt() : qtyVal.toStringAsFixed(1)} ${item.unit}';

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: isPos
                                            ? AppColors.successBg
                                            : AppColors.criticalBg,
                                        child: Icon(
                                          itemTx.typeIcon,
                                          size: 18,
                                          color: isPos ? AppColors.success : AppColors.critical,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  itemTx.formattedTypeLabel,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  dateStr,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                tx.notes!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            formattedQty,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isPos ? AppColors.success : AppColors.critical,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Bal: ${itemTx.runningBalance % 1 == 0 ? itemTx.runningBalance.toInt() : itemTx.runningBalance.toStringAsFixed(1)} ${item.unit}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(ItemModel item) {
    final qtyStr =
        '${item.currentQty % 1 == 0 ? item.currentQty.toInt() : item.currentQty.toStringAsFixed(1)} ${item.unit}';
    final isOut = item.currentQty <= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOut ? AppColors.criticalBg : AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.08),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT AVAILABLE READY STOCK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isOut ? AppColors.critical : const Color(0xFF99EFE5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isOut ? AppColors.critical : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isOut ? 'OUT OF STOCK' : 'AVAILABLE',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            qtyStr,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isOut ? AppColors.critical : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Colour: ${item.name}',
            style: TextStyle(
              fontSize: 13,
              color: isOut ? AppColors.textSecondary : const Color(0xFFE0F2FE),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyStockMovementModal extends ConsumerStatefulWidget {
  final ItemModel item;
  final bool isStockIn;

  const _ReadyStockMovementModal({
    required this.item,
    required this.isStockIn,
  });

  @override
  ConsumerState<_ReadyStockMovementModal> createState() => _ReadyStockMovementModalState();
}

class _ReadyStockMovementModalState extends ConsumerState<_ReadyStockMovementModal> {
  final _qtyController = TextEditingController();
  final _remarkController = TextEditingController();
  DateTime _date = DateTime.now();

  bool _showErrors = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  double get _qty => double.tryParse(_qtyController.text.trim()) ?? 0.0;
  bool get _isQtyValid => _qty > 0;

  bool get _isExceedingStock {
    if (widget.isStockIn) return false;
    return _qty > widget.item.currentQty + 0.0001;
  }

  bool get _isFormValid => _isQtyValid && !_isExceedingStock;

  Future<void> _handleSave() async {
    setState(() {
      _showErrors = true;
    });

    if (!_isFormValid || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final stockRepo = ref.read(stockRepositoryProvider);
      await stockRepo.recordReadyStockMovement(
        itemId: widget.item.id,
        quantity: _qty,
        isStockIn: widget.isStockIn,
        date: _date,
        remark: _remarkController.text,
      );

      ref.invalidate(itemByIdProvider(widget.item.id));
      ref.invalidate(readyStockStreamProvider);
      ref.invalidate(stockTransactionsStreamProvider(widget.item.id));

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isStockIn
                ? 'Added ${_qty % 1 == 0 ? _qty.toInt() : _qty} ${widget.item.unit} to Ready Stock'
                : 'Dispatched ${_qty % 1 == 0 ? _qty.toInt() : _qty} ${widget.item.unit} from Ready Stock',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('ArgumentError: ', '')),
          backgroundColor: AppColors.critical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.isStockIn
        ? 'Stock In (${widget.item.name})'
        : 'Stock Out (${widget.item.name})';
    final availStr =
        '${widget.item.currentQty % 1 == 0 ? widget.item.currentQty.toInt() : widget.item.currentQty.toStringAsFixed(1)} ${widget.item.unit}';
    final dateStr =
        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titleText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Available Stock Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Available Stock: ',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    availStr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _date = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Movement Date *',
                  prefixIcon:
                      const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr, style: const TextStyle(fontSize: 14)),
                    const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Qty Field
            TextField(
              controller: _qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Quantity (${widget.item.unit}) *',
                hintText: 'e.g. 20',
                prefixIcon: Icon(
                  widget.isStockIn ? Icons.add_circle_outline : Icons.remove_circle_outline,
                  color: widget.isStockIn ? AppColors.success : AppColors.critical,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: (_showErrors && !_isQtyValid) || _isExceedingStock
                        ? AppColors.critical
                        : AppColors.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isExceedingStock ? AppColors.critical : AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            if (_showErrors && !_isQtyValid) ...[
              const SizedBox(height: 4),
              const Text(
                'Enter quantity > 0',
                style: TextStyle(fontSize: 11, color: AppColors.critical),
              ),
            ],
            if (_isExceedingStock) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.criticalBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Stock Out quantity cannot exceed available stock ($availStr).',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.critical,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Remark / Notes
            TextField(
              controller: _remarkController,
              decoration: InputDecoration(
                labelText: 'Remark / Notes (Optional)',
                hintText: widget.isStockIn ? 'e.g. Received from Cutting' : 'e.g. Dispatched to Party A',
                prefixIcon: const Icon(Icons.note_outlined, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isFormValid && !_isSaving) ? _handleSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isStockIn ? AppColors.success : AppColors.critical,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.isStockIn ? 'Record Stock In' : 'Record Stock Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
