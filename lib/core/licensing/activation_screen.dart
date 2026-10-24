import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import 'license_service.dart';

class ActivationScreen extends ConsumerStatefulWidget {
  final LicenseState state;

  const ActivationScreen({
    super.key,
    required this.state,
  });

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final TextEditingController _tokenController = TextEditingController();
  String? _requestCode;
  String? _requestCodeError;
  bool _isLoadingCode = true;
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    _loadRequestCode();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadRequestCode() async {
    setState(() {
      _isLoadingCode = true;
      _requestCodeError = null;
    });

    try {
      final identity = ref.read(deviceIdentityProvider);
      final code = await identity.getRequestCode();
      if (mounted) {
        setState(() {
          _requestCode = code;
          _isLoadingCode = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _requestCodeError = e.toString();
          _isLoadingCode = false;
        });
      }
    }
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      setState(() {
        _tokenController.text = text;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pasted from clipboard')),
        );
      }
    }
  }

  Future<void> _handlePickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['smlic', 'txt'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final text = await file.readAsString();
        if (mounted) {
          setState(() {
            _tokenController.text = text.trim();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Loaded ${result.files.single.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to read file: $e'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    }
  }

  Future<void> _handleActivate() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or paste your license token')),
      );
      return;
    }

    setState(() {
      _isActivating = true;
    });

    final success = await ref.read(licenseServiceProvider.notifier).activate(token);

    if (mounted) {
      setState(() {
        _isActivating = false;
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(ref.read(licenseServiceProvider))),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    }
  }

  String _getErrorMessage(LicenseState state) {
    return switch (state) {
      LicenseUnlicensed() => 'No license found. Please enter a valid license token.',
      LicenseInvalid(:final reason) =>
        'Not a ShopManager license or damaged or incomplete: $reason (copy it again)',
      LicenseWrongDevice() => 'This license was not issued for this phone. Each phone requires its own license.',
      LicenseVerifyError(:final message) => 'Could not verify license: $message. Please tap Retry.',
      LicenseDeviceUnsupported() =>
        'Device unsupported: Android 6.0 (API 23) or higher is required for hardware security.',
      LicenseNotConfigured() =>
        'Licensing not configured: Signed by an unrecognized key (an app update is needed).',
      _ => 'Activation failed. Please check your token.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxmaxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Device License Activation',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // State banner message
                  _buildStatusBanner(state),
                  const SizedBox(height: 20),

                  // Request Code Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.borderLight),
                    ),
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.phone_android, size: 20, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'THIS PHONE\'S REQUEST CODE',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_isLoadingCode)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_requestCodeError != null)
                            Text(
                              'Error obtaining request code:\n$_requestCodeError',
                              style: GoogleFonts.inter(
                                color: AppColors.critical,
                                fontSize: 13,
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderMedium),
                              ),
                              child: SelectableText(
                                _requestCode ?? 'N/A',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _requestCode == null
                                      ? null
                                      : () {
                                          Clipboard.setData(ClipboardData(text: _requestCode!));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Request Code copied!')),
                                          );
                                        },
                                  icon: const Icon(Icons.copy, size: 16),
                                  label: const Text('Copy Code'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    side: const BorderSide(color: AppColors.borderMedium),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _requestCode == null
                                      ? null
                                      : () {
                                          Share.share(
                                            'ShopManager activation request\n'
                                            'Request Code: $_requestCode\n'
                                            'App Version: 1.0.0+1',
                                            subject: 'ShopManager Activation Request',
                                          );
                                        },
                                  icon: const Icon(Icons.share, size: 16),
                                  label: const Text('Share Code'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Send this request code to your software vendor to receive your activation license.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // License Entry Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.borderLight),
                    ),
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.key, size: 20, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'ENTER LICENSE TOKEN',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _tokenController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Paste license token here (.smlic text)...',
                              hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.borderMedium),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.borderMedium),
                              ),
                            ),
                            style: GoogleFonts.jetBrainsMono(fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: _handlePaste,
                                icon: const Icon(Icons.paste, size: 16),
                                label: const Text('Paste from Clipboard'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _handlePickFile,
                                icon: const Icon(Icons.folder_open, size: 16),
                                label: const Text('Choose License File'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isActivating ? null : _handleActivate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isActivating
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Activate ShopManager',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Support line
                  Center(
                    child: Text(
                      AppConstants.supportContact,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(LicenseState state) {
    final (bgColor, borderColor, textColor, icon, message) = switch (state) {
      LicenseChecking() => (
          AppColors.infoBg,
          AppColors.info,
          AppColors.info,
          Icons.sync,
          'Checking license status...',
        ),
      LicenseUnlicensed() => (
          AppColors.warningBg,
          AppColors.warning,
          AppColors.warning,
          Icons.lock_outline,
          'This installation is not licensed. Send your Request Code to your vendor to receive an activation license.',
        ),
      LicenseInvalid(:final reason) => (
          AppColors.criticalBg,
          AppColors.critical,
          AppColors.critical,
          Icons.error_outline,
          'Invalid license: $reason (Please copy the full license token and try again).',
        ),
      LicenseWrongDevice() => (
          AppColors.criticalBg,
          AppColors.critical,
          AppColors.critical,
          Icons.phonelink_erase,
          'This license was not issued for this phone. Each phone requires its own license.',
        ),
      LicenseVerifyError(:final message) => (
          AppColors.warningBg,
          AppColors.warning,
          AppColors.warning,
          Icons.refresh,
          'Could not verify license ($message). Please tap Retry.',
        ),
      LicenseDeviceUnsupported() => (
          AppColors.criticalBg,
          AppColors.critical,
          AppColors.critical,
          Icons.block,
          'Device unsupported: Android 6.0 (API 23) or higher is required for hardware security.',
        ),
      LicenseNotConfigured() => (
          AppColors.criticalBg,
          AppColors.critical,
          AppColors.critical,
          Icons.build,
          'Licensing not configured: Signed by an unrecognized key (an app update is needed).',
        ),
      LicenseLicensed() => (
          AppColors.successBg,
          AppColors.success,
          AppColors.success,
          Icons.check_circle_outline,
          'License verified and active.',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          if (state is LicenseVerifyError)
            InkWell(
              onTap: () => ref.read(licenseServiceProvider.notifier).checkLicense(),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BoxmaxConstraints extends BoxConstraints {
  const BoxmaxConstraints({required super.maxWidth});
}
