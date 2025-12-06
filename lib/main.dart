import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/reports_provider.dart';
import 'providers/roles_provider.dart';
import 'providers/users_provider.dart';
import 'providers/reservations_provider.dart';
import 'providers/clients_provider.dart';
import 'providers/suppliers_provider.dart';
import 'providers/services_provider.dart';
import 'providers/fincas_provider.dart';
import 'providers/routes_provider.dart';
import 'providers/itineraries_provider.dart';
import 'providers/invoices_provider.dart';
import 'providers/payments_provider.dart';
import 'providers/reviews_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/roles_list_screen.dart';
import 'screens/role_form_screen.dart';
import 'screens/role_detail_screen.dart';
import 'screens/assign_permissions_screen.dart';
import 'screens/users_list_screen.dart';
import 'screens/user_detail_screen.dart';
import 'screens/user_form_screen.dart';
import 'screens/recover_password_screen.dart';
import 'screens/logout_screen.dart';
import 'widgets/auth_guard.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/services_list_screen.dart';
// service_form_screen.dart is obsolete for services; using ServiceDetailScreen
import 'screens/routes_screen.dart';
import 'screens/routes_manage_screen.dart';
import 'screens/route_form_screen.dart';
import 'screens/route_detail_screen.dart';
import 'screens/fincas_screen.dart';
import 'screens/payments_list_screen.dart';
import 'screens/payment_create_screen.dart';
import 'screens/payment_detail_screen.dart';
import 'screens/fincas_manage_screen.dart';
import 'screens/finca_form_screen.dart';
import 'screens/finca_detail_screen.dart';
import 'screens/fincas_map_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/itineraries_list_screen.dart';
import 'screens/itinerary_create_screen.dart';
import 'screens/itinerary_detail_screen.dart';
import 'screens/invoices_list_screen.dart';
import 'screens/invoice_create_screen.dart';
import 'screens/invoice_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/reviews_list_screen.dart';
import 'screens/review_create_screen.dart';
import 'screens/review_detail_screen.dart';
import 'screens/reservations_create_screen.dart';
import 'screens/reservations_edit_screen.dart';
import 'screens/reservations_cancel_screen.dart';
import 'screens/reservations_list_screen.dart';
import 'screens/reservation_detail_screen.dart';
import 'screens/clients_register_screen.dart';
import 'screens/clients_segmentation_screen.dart';
import 'screens/clients_campaigns_screen.dart';
import 'screens/clients_history_screen.dart';
import 'screens/clients_list_screen.dart';
import 'screens/client_detail_screen.dart';
import 'screens/dashboard_satisfaction_screen.dart';
import 'screens/dashboard_statistics_screen.dart';
import 'screens/dashboard_reports_screen.dart';
import 'screens/dashboard_indicators_screen.dart';
import 'screens/admin_dashboard_screen.dart';
// duplicate payment imports removed (already imported earlier)
import 'screens/admin_analytics_screen.dart';
import 'screens/reservations_flow_screen.dart';
import 'screens/advisor_dashboard_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/access_denied_screen.dart';
import 'screens/suppliers_list_screen.dart';
import 'screens/supplier_form_screen.dart';
import 'screens/supplier_detail_screen.dart';
import 'screens/sales_list_client_screen.dart';
import 'screens/sale_detail_screen.dart';
import 'screens/sale_form_screen.dart';
import 'screens/low_stock_screen.dart';
import 'screens/service_detail_screen.dart';
import 'screens/services_agenda_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(OccitoursApp());
}

class OccitoursApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // helper to build guarded routes succinctly
    WidgetBuilder guarded(List<String> roles, Widget child) =>
        (ctx) => AuthGuard(allowedRoles: roles, child: child);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => FincasProvider()),
        ChangeNotifierProvider(create: (_) => RoutesProvider()),
        ChangeNotifierProvider(create: (_) => ItinerariesProvider()),
        ChangeNotifierProvider(create: (_) => InvoicesProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => PaymentsProvider()),
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ClientsProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => RolesProvider()),
        ChangeNotifierProvider(create: (_) => ReservationsProvider()),
        ChangeNotifierProvider(create: (_) => SuppliersProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Occitours',
        theme: AppTheme.light,
        initialRoute: '/',
        routes: {
          '/': (ctx) => HomeScreen(),
          RoutesScreen.routeName: (ctx) => RoutesScreen(),
          FincasScreen.routeName: (ctx) => FincasScreen(),
          FincasManageScreen.routeName: (ctx) => FincasManageScreen(),
          FincasMapScreen.routeName: (ctx) => FincasMapScreen(),
          '/fincas/create': (ctx) => FincaFormScreen(),
          '/fincas/edit': (ctx) => FincaFormScreen(),
          FincaDetailScreen.routeName: (ctx) => FincaDetailScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          RegisterScreen.routeName: (ctx) => RegisterScreen(),
          ProductsScreen.routeName: (ctx) => ProductsScreen(),
          RolesListScreen.routeName: guarded(['admin'], RolesListScreen()),
          '/roles/create': guarded(['admin'], RoleFormScreen()),
          '/roles/edit': guarded(['admin'], RoleFormScreen()),
          RoleDetailScreen.routeName: guarded(['admin'], RoleDetailScreen()),
          AssignPermissionsScreen.routeName:
              guarded(['admin'], AssignPermissionsScreen()),
          UsersListScreen.routeName: guarded(['admin'], UsersListScreen()),
          UserDetailScreen.routeName: guarded(['admin'], UserDetailScreen()),
          UserFormScreen.routeName: guarded(['admin'], UserFormScreen()),
          // parte linsaith
          '/users/edit': guarded(['admin'], UserFormScreen()),
          RecoverPasswordScreen.routeName: (ctx) => RecoverPasswordScreen(),
          LogoutScreen.routeName: (ctx) => LogoutScreen(),
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          RoutesManageScreen.routeName: (ctx) => RoutesManageScreen(),
          '/rutas/create': (ctx) => RouteFormScreen(),
          '/rutas/edit': (ctx) => RouteFormScreen(),
          RouteDetailScreen.routeName: (ctx) => RouteDetailScreen(),
          ServicesListScreen.routeName: (ctx) => ServicesListScreen(),
          '/services/create': (ctx) => ServiceDetailScreen(),
          '/services/edit': (ctx) => ServiceDetailScreen(),
          ServiceDetailScreen.routeName: (ctx) => ServiceDetailScreen(),
          ServicesAgendaScreen.routeName: (ctx) => ServicesAgendaScreen(),
          ReservationsFlowScreen.routeName: (ctx) => ReservationsFlowScreen(),
          ReservationsListScreen.routeName:
              guarded(['admin', 'asesor', 'advisor'], ReservationsListScreen()),
          ReservationsCreateScreen.routeName:
              guarded(['admin'], ReservationsCreateScreen()),
          ReservationsEditScreen.routeName: (ctx) {
            // This screen needs custom logic: allow admins and clients (screen validates ownership)
            final auth = Provider.of<AuthProvider>(ctx, listen: false);
            final role = (auth.user?.role ?? '').toLowerCase();
            if (role == 'admin' || role == 'cliente' || role == 'client')
              return ReservationsEditScreen();
            return AccessDeniedScreen();
          },
          ReservationsCancelScreen.routeName:
              guarded(['admin'], ReservationsCancelScreen()),
          ReservationDetailScreen.routeName: guarded(
              ['admin', 'asesor', 'advisor', 'cliente', 'client'],
              ReservationDetailScreen()),
          AdvisorDashboardScreen.routeName:
              guarded(['asesor', 'advisor', 'admin'], AdvisorDashboardScreen()),
          ClientHomeScreen.routeName:
              guarded(['cliente', 'client'], ClientHomeScreen()),
          ClientsRegisterScreen.routeName: (ctx) => ClientsRegisterScreen(),
          ClientsListScreen.routeName: guarded(['admin'], ClientsListScreen()),
          ClientDetailScreen.routeName:
              guarded(['admin', 'cliente', 'client'], ClientDetailScreen()),
          ClientsSegmentationScreen.routeName: (ctx) =>
              ClientsSegmentationScreen(),
          ClientsCampaignsScreen.routeName: (ctx) => ClientsCampaignsScreen(),
          ClientsHistoryScreen.routeName: (ctx) => ClientsHistoryScreen(),
          DashboardSatisfactionScreen.routeName: (ctx) =>
              DashboardSatisfactionScreen(),
          DashboardStatisticsScreen.routeName: (ctx) =>
              DashboardStatisticsScreen(),
          DashboardReportsScreen.routeName: (ctx) => DashboardReportsScreen(),
          DashboardIndicatorsScreen.routeName: (ctx) =>
              DashboardIndicatorsScreen(),
          AdminDashboardScreen.routeName:
              guarded(['admin'], AdminDashboardScreen()),
          AdminAnalyticsScreen.routeName:
              guarded(['admin'], AdminAnalyticsScreen()),
          // parte linsaith
          PaymentsListScreen.routeName:
              guarded(['admin'], PaymentsListScreen()),
          '/payments/create': guarded(['admin'], PaymentCreateScreen()),
          PaymentDetailScreen.routeName:
              guarded(['admin'], PaymentDetailScreen()),
          ItinerariesListScreen.routeName:
              guarded(['admin'], ItinerariesListScreen()),
          '/itineraries/create': guarded(['admin'], ItineraryCreateScreen()),
          '/itineraries/detail':
              guarded(['admin'], ItineraryDetailScreen(itineraryId: '')),
          InvoicesListScreen.routeName:
              guarded(['admin'], InvoicesListScreen()),
          '/invoices/create': guarded(['admin'], InvoiceCreateScreen()),
          '/invoices/detail':
              guarded(['admin'], InvoiceDetailScreen(invoiceId: '')),
          SuppliersListScreen.routeName:
              guarded(['admin'], SuppliersListScreen()),
          '/suppliers/create': guarded(['admin'], SupplierFormScreen()),
          '/suppliers/edit': guarded(['admin'], SupplierFormScreen()),
          '/suppliers/detail': guarded(['admin'], SupplierDetailScreen()),
          SalesListClientScreen.routeName:
              guarded(['cliente', 'client'], SalesListClientScreen()),
          SaleDetailScreen.routeName: guarded(
              ['cliente', 'client', 'asesor', 'advisor', 'admin'],
              SaleDetailScreen()),
          SaleFormScreen.routeName:
              guarded(['asesor', 'advisor', 'admin'], SaleFormScreen()),
          LowStockScreen.routeName: guarded(['admin'], LowStockScreen()),
          CartScreen.routeName: (ctx) => CartScreen(),
          ProfileScreen.routeName: (ctx) => ProfileScreen(),
          ReportsScreen.routeName: (ctx) => ReportsScreen(),
          ReviewsListScreen.routeName: (ctx) => ReviewsListScreen(),
          '/reviews/create':
              guarded(['cliente', 'client'], ReviewCreateScreen()),
          '/reviews/detail': (ctx) => ReviewDetailScreen(reviewId: ''),
        },
      ),
    );
  }
}
