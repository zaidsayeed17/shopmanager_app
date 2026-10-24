import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class ItemDetailPlaceholderScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailPlaceholderScreen({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numericId = int.tryParse(itemId) ?? 0;
    final itemAsync = ref.watch(itemByIdProvider(numericId));

    return itemAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/stock'),
          ),
        ),
        body: Center(child: Text('Error: $err')),
      ),
      data: (item) {
        final title = item?.name ?? 'Item #$itemId';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/stock');
                }
              },
            ),
            actions: [
              if (item != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Item',
                  onPressed: () => context.go('/stock/edit/${item.id}'),
                ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceDim,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: AppTypography.headlineLg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (item != null) ...[
                    Text(
                      '${item.isRawMaterial ? 'Raw Material' : 'Finished Product'} • ${item.category ?? 'Uncategorized'}',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current Stock: ${item.currentQty.toStringAsFixed(item.currentQty.truncateToDouble() == item.currentQty ? 0 : 2)} ${item.unit}',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Stock history coming in the next step',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
