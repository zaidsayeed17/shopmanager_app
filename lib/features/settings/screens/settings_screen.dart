import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/licensing/license_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/repositories/providers.dart';
import '../../../services/excel_export_service.dart';

class _ExportItem {
  final String title;
  final String description;
  final String filename;
  final Future<File> Function(ExcelExportService service) exportFn;

  const _ExportItem({
    required this.title,
    required this.description,
    required this.filename,
    required this.exportFn,
  });
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExportingAll = false;
  String? _loadingTarget;
  bool _isCreatingBackup = false;
  bool _isRestoringBackup = false;
  bool _isResettingData = false;

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isProfileLoaded = false;
  bool _isSavingProfile = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveBusinessProfile() async {
    if (_isSavingProfile) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSavingProfile = true);

    try {
      final repo = ref.read(businessProfileRepositoryProvider);
      await repo.updateBusinessProfile(
        name: _nameController.text,
        mobile: _mobileController.text,
        address: _addressController.text,
      );

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Business profile saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (err) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(err is ArgumentError ? err.message : 'Failed to save business profile'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  static final List<_ExportItem> _exportItems = [
    _ExportItem(
      title: 'Customers',
      description: 'Customer directory, contact details & ledger balances',
      filename: 'Customers.xlsx',
      exportFn: (s) => s.exportCustomers(),
    ),
    _ExportItem(
      title: 'Items (Stock & Products)',
      description: 'Raw materials & finished products inventory',
      filename: 'Items.xlsx',
      exportFn: (s) => s.exportItems(),
    ),
    _ExportItem(
      title: 'Stock Transactions',
      description: 'Purchase history, stock adjustments & movements',
      filename: 'Stock_Transactions.xlsx',
      exportFn: (s) => s.exportStockTransactions(),
    ),
    _ExportItem(
      title: 'Workers',
      description: 'Worker directory & assigned work types',
      filename: 'Workers.xlsx',
      exportFn: (s) => s.exportWorkers(),
    ),
    _ExportItem(
      title: 'Worker Transactions',
      description: 'Material issuance logs to workers',
      filename: 'Worker_Transactions.xlsx',
      exportFn: (s) => s.exportWorkerTransactions(),
    ),
    _ExportItem(
      title: 'Production',
      description: 'Production batch records & material consumption (2 sheets)',
      filename: 'Production.xlsx',
      exportFn: (s) => s.exportProduction(),
    ),
    _ExportItem(
      title: 'Bills',
      description: 'Sales bills summary & payment status',
      filename: 'Bills.xlsx',
      exportFn: (s) => s.exportBills(),
    ),
    _ExportItem(
      title: 'Bill Items',
      description: 'Line items for all generated bills',
      filename: 'Bill_Items.xlsx',
      exportFn: (s) => s.exportBillItems(),
    ),
    _ExportItem(
      title: 'Payments',
      description: 'Payment records & payment methods',
      filename: 'Payments.xlsx',
      exportFn: (s) => s.exportPayments(),
    ),
    _ExportItem(
      title: 'Customer Ledger',
      description: 'Customer debit, credit & running balance logs',
      filename: 'Customer_Ledger.xlsx',
      exportFn: (s) => s.exportCustomerLedger(),
    ),
  ];

  Future<void> _handleSingleExport(_ExportItem item) async {
    if (_isExportingAll || _loadingTarget != null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loadingTarget = item.filename);

    try {
      final service = ref.read(excelExportServiceProvider);
      final file = await item.exportFn(service);
      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
        text: 'Exported ${item.title} (${item.filename})',
      );
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text("Couldn't generate export — try again"),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingTarget = null);
      }
    }
  }

  Future<void> _handleExportAll() async {
    if (_isExportingAll || _loadingTarget != null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isExportingAll = true);

    try {
      final service = ref.read(excelExportServiceProvider);
      final files = await service.exportAll();
      if (!mounted) return;

      final xFiles = files.map((f) => XFile(f.path)).toList();
      await Share.shareXFiles(
        xFiles,
        text: 'Exported All Business Data (10 Excel files)',
      );
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text("Couldn't generate export — try again"),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingAll = false);
      }
    }
  }

  Future<void> _handleCreateBackup() async {
    if (_isCreatingBackup || _isRestoringBackup) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isCreatingBackup = true);

    try {
      final backupService = ref.read(backupServiceProvider);
      final backupFile = await backupService.createBackup();
      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(backupFile.path)],
        text: 'ShopManager Backup',
      );

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Backup created'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to create backup'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingBackup = false);
      }
    }
  }

  Future<void> _handleRestoreBackup() async {
    if (_isCreatingBackup || _isRestoringBackup) return;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;
      final file = File(filePath);

      setState(() => _isRestoringBackup = true);

      final backupService = ref.read(backupServiceProvider);
      final validation = await backupService.validateBackupFile(file);

      setState(() => _isRestoringBackup = false);

      if (!validation.isValid) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(validation.errorMessage ?? 'Invalid backup file'),
              backgroundColor: AppColors.critical,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      // Show strong confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restore this backup?'),
          content: Text(
            'This will REPLACE all current data in the app with the contents of this backup'
            '${validation.timestampFormatted != null ? " (from ${validation.timestampFormatted})" : ""}. '
            'This cannot be undone. The app will close after restoring — you\'ll need to reopen it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.critical,
                foregroundColor: Colors.white,
              ),
              child: const Text('Restore & Close App'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _isRestoringBackup = true);

      await backupService.restoreFromBackup(file);

      // Force app exit cleanly
      await SystemNavigator.pop();
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Error restoring backup'),
            backgroundColor: AppColors.critical,
          ),
        );
        setState(() => _isRestoringBackup = false);
      }
    }
  }



  Future<void> _handleFactoryReset() async {
    if (_isResettingData) return;
    final messenger = ScaffoldMessenger.of(context);

    String typedText = '';

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isValid = typedText.trim() == 'RESET';

            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 24),
                  SizedBox(width: 8),
                  Text('Factory Reset All Data'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This action will PERMANENTLY DELETE all app data, including:\n'
                      '• Customers & ledger history\n'
                      '• Items & stock movement logs\n'
                      '• Workers, material issuances & production records\n'
                      '• Bills & payment records\n\n'
                      'Bill numbering will restart from INV-0001.\n'
                      'THIS CANNOT BE UNDONE.',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(ctx).pop(false);
                        await _handleCreateBackup();
                      },
                      icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                      label: const Text('Create Backup First'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'To confirm, type "RESET" in capital letters below:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Type RESET',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          typedText = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isValid ? () => Navigator.of(ctx).pop(true) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.critical,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.critical.withOpacity(0.3),
                    disabledForegroundColor: Colors.white70,
                  ),
                  child: const Text('PERMANENTLY RESET DATA'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isResettingData = true);

    try {
      final resetService = ref.read(factoryResetServiceProvider);
      await resetService.resetAllData();

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Factory reset completed successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      context.go('/dashboard');
    } catch (err) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to reset data: $err'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResettingData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnyLoading = _isExportingAll || _loadingTarget != null || _isCreatingBackup || _isRestoringBackup || _isResettingData;

    final profileAsync = ref.watch(businessProfileProvider);
    profileAsync.whenData((profile) {
      if (!_isProfileLoaded) {
        _nameController.text = profile.name;
        _mobileController.text = profile.mobile;
        _addressController.text = profile.address;
        _isProfileLoaded = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Profile Section Header
            Row(
              children: [
                const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Business Profile',
                  style: AppTypography.headlineLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Manage shop details displayed on app header, PDFs & invoices',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Shop Name *',
                      hintText: 'e.g. Acme Enterprises',
                      prefixIcon: Icon(Icons.store),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number (Optional)',
                      hintText: 'e.g. 9876543210',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Business Address (Optional)',
                      hintText: 'e.g. 123 Main St, Market Road',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isAnyLoading || _isSavingProfile ? null : _handleSaveBusinessProfile,
                      icon: _isSavingProfile
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: Text(_isSavingProfile ? 'Saving...' : 'Save Business Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Data Export Section Header
            Row(
              children: [
                const Icon(Icons.table_chart_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Data Export',
                  style: AppTypography.headlineLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Export your business data as Excel files',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // EXPORT ALL CARD (Primary Style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_zip_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Export All Data (.xlsx)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Generate & share all 10 Excel files in one action',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isAnyLoading ? null : _handleExportAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isExportingAll
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.ios_share, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Export All',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'INDIVIDUAL DATASETS',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            // Individual Export Rows
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exportItems.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, index) {
                  final item = _exportItems[index];
                  final isLoadingThis = _loadingTarget == item.filename;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: isAnyLoading ? null : () => _handleSingleExport(item),
                          icon: isLoadingThis
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(Icons.download_outlined, size: 16),
                          label: Text(isLoadingThis ? 'Exporting...' : 'Export'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            side: const BorderSide(color: AppColors.borderMedium),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // BACKUP & RESTORE SECTION
            Row(
              children: [
                const Icon(Icons.backup_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Backup & Restore',
                  style: AppTypography.headlineLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Save a full copy of your database or restore from a previous backup',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isAnyLoading ? null : _handleCreateBackup,
                          icon: _isCreatingBackup
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                )
                              : const Icon(Icons.cloud_upload_outlined, size: 18),
                          label: Text(_isCreatingBackup ? 'Creating...' : 'Create Backup'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isAnyLoading ? null : _handleRestoreBackup,
                          icon: _isRestoringBackup
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                )
                              : const Icon(Icons.restore_outlined, size: 18),
                          label: Text(_isRestoringBackup ? 'Validating...' : 'Restore from Backup'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.borderMedium),
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Back up regularly, especially before restoring or updating the app.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),



            // LICENSE SECTION
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'License',
                  style: AppTypography.headlineLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Device-bound software license status',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildLicenseCard(),

            // DANGER ZONE SECTION
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Danger Zone',
                  style: AppTypography.headlineLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.critical,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Irreversible data management operations',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.critical.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Full Factory Reset',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.critical,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Wipe all app data (customers, items, workers, bills, payments) and start fresh with INV-0001.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isAnyLoading ? null : _handleFactoryReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.critical,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isResettingData
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Reset All Data',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseCard() {
    final licenseState = ref.watch(licenseServiceProvider);
    final licenseInfo = switch (licenseState) {
      LicenseLicensed(:final info) => info,
      _ => null,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Active',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (licenseInfo != null)
                Text(
                  'v${licenseInfo.v}',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Licensed to: ${licenseInfo?.customer ?? "N/A"}${licenseInfo?.shop != null && licenseInfo!.shop!.isNotEmpty ? " (${licenseInfo.shop})" : ""}',
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'License ID: ${licenseInfo?.lid ?? "N/A"}',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: ref.read(deviceIdentityProvider).getRequestCode(),
            builder: (context, snapshot) {
              final code = snapshot.data ?? (snapshot.hasError ? 'Error loading code' : 'Loading...');
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Phone\'s Request Code',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          code,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (snapshot.hasData)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy Request Code',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: snapshot.data!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request Code copied!')),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
