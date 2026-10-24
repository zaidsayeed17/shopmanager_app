import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/licensing/activation_screen.dart';
import 'core/licensing/license_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/error_boundary.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('FlutterError caught: ${details.exceptionAsString()}\n${details.stack}');
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return GlobalErrorBoundaryWidget(details: details);
    };

    runApp(
      const ProviderScope(
        child: ShopManagerApp(),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('Uncaught async error: $error\n$stackTrace');
  });
}

class ShopManagerApp extends ConsumerWidget {
  const ShopManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final licenseState = ref.watch(licenseServiceProvider);

    return MaterialApp.router(
      title: 'ShopManager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return switch (licenseState) {
          LicenseChecking() => Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.store_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verifying license...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          LicenseLicensed(:final isBypass) => Stack(
              children: [
                ?child,
                if (isBypass)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        color: const Color(0xFFDC2626),
                        child: const Text(
                          'LICENSE BYPASS (debug)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          _ => ActivationScreen(state: licenseState),
        };
      },
    );
  }
}
