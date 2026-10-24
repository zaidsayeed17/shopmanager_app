import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_shell.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/customers/screens/customers_screen.dart';
import '../../features/customers/screens/customer_form_screen.dart';
import '../../features/customers/screens/customer_detail_screen.dart';
import '../../features/billing/screens/billing_screen.dart';
import '../../features/billing/screens/create_bill_screen.dart';
import '../../features/billing/screens/bill_detail_screen.dart';
import '../../features/billing/screens/quick_sale_screen.dart';
import '../../features/billing/screens/quick_sale_history_screen.dart';
import '../../features/stock/screens/stock_screen.dart';
import '../../features/stock/screens/item_form_screen.dart';
import '../../features/stock/screens/item_detail_screen.dart';
import '../../features/stock/screens/purchase_form_screen.dart';
import '../../features/stock/screens/adjust_stock_screen.dart';
import '../../features/workers/screens/workers_screen.dart';
import '../../features/workers/screens/worker_form_screen.dart';
import '../../features/workers/screens/worker_detail_placeholder_screen.dart';
import '../../features/workers/screens/issue_material_screen.dart';
import '../../features/workers/screens/record_production_screen.dart';
import '../../features/workers/screens/work_entry_screen.dart';
import '../../features/workers/screens/cutting_entry_screen.dart';
import '../../features/readystock/screens/ready_stock_screen.dart';
import '../../features/readystock/screens/ready_stock_detail_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/reports/screens/sales_report_screen.dart';
import '../../features/reports/screens/customer_outstanding_report_screen.dart';
import '../../features/reports/screens/stock_report_screen.dart';
import '../../features/reports/screens/stock_movement_report_screen.dart';
import '../../features/reports/screens/low_stock_report_screen.dart';
import '../../features/reports/screens/worker_material_report_screen.dart';
import '../../features/reports/screens/worker_production_report_screen.dart';
import '../../features/reports/screens/payment_report_screen.dart';
import '../../features/reports/screens/report_placeholder_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/selling_products/screens/selling_products_screen.dart';
import '../../features/selling_products/screens/selling_product_form_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            location: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomersScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const CustomerFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => CustomerFormScreen(
                  customerId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => CustomerDetailScreen(
                  customerId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/billing',
            builder: (context, state) => const BillingScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const CreateBillScreen(),
              ),
              GoRoute(
                path: 'new/:customerId',
                builder: (context, state) => CreateBillScreen(
                  initialCustomerId: state.pathParameters['customerId'],
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => BillDetailScreen(
                  billId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/stock',
            builder: (context, state) => const StockScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const ItemFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => ItemFormScreen(
                  itemId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => ItemDetailScreen(
                  itemId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'purchase',
                    builder: (context, state) => PurchaseFormScreen(
                      itemId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'adjust',
                    builder: (context, state) => AdjustStockScreen(
                      itemId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/workers',
            builder: (context, state) => const WorkersScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const WorkerFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => WorkerFormScreen(
                  workerId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => WorkerDetailPlaceholderScreen(
                  workerId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'issue',
                    builder: (context, state) => IssueMaterialScreen(
                      workerId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'production',
                    builder: (context, state) => RecordProductionScreen(
                      workerId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'work-entry/add',
                    builder: (context, state) => WorkEntryScreen(
                      workerId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'cutting/add',
                    builder: (context, state) => CuttingEntryScreen(
                      workerId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/ready-stock',
            builder: (context, state) => const ReadyStockScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const ItemFormScreen(
                  initialType: 'ready_stock',
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => ReadyStockDetailScreen(
                  itemId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
            routes: [
              GoRoute(
                path: 'sales',
                builder: (context, state) => SalesReportScreen(
                  initialTab: state.uri.queryParameters['tab'],
                ),
              ),
              GoRoute(
                path: 'customer-outstanding',
                builder: (context, state) => const CustomerOutstandingReportScreen(),
              ),
              GoRoute(
                path: 'stock',
                builder: (context, state) => const StockReportScreen(),
              ),
              GoRoute(
                path: 'stock-movement',
                builder: (context, state) => const StockMovementReportScreen(),
              ),
              GoRoute(
                path: 'low-stock',
                builder: (context, state) => const LowStockReportScreen(),
              ),
              GoRoute(
                path: 'worker-material',
                builder: (context, state) => const WorkerMaterialReportScreen(),
              ),
              GoRoute(
                path: 'worker-production',
                builder: (context, state) => const WorkerProductionReportScreen(),
              ),
              GoRoute(
                path: 'payments',
                builder: (context, state) => const PaymentReportScreen(),
              ),
              GoRoute(
                path: 'placeholder/:reportName',
                builder: (context, state) => ReportPlaceholderScreen(
                  reportName: Uri.decodeComponent(state.pathParameters['reportName'] ?? 'Report'),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/quick-sale/new',
            builder: (context, state) => const QuickSaleScreen(),
          ),
          GoRoute(
            path: '/quick-sale/history',
            builder: (context, state) => const QuickSaleHistoryScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const SellingProductsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const SellingProductFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => SellingProductFormScreen(
                  productId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
