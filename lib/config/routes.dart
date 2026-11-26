import 'package:flutter/material.dart';
import '../screens/client/catalog_screen.dart';
import '../screens/client/cart_screen.dart';
import '../screens/client/checkout_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/admin/admin_catalog_screen.dart';
import '../screens/admin/product_form_screen.dart';
import '../screens/admin/admin_orders_screen.dart';
import '../screens/admin/admin_sales_screen.dart';
import '../screens/client/product_detail_screen.dart';
import '../models/product_model.dart';

class AppRoutes {
  static const String initial = '/';
  static const String catalog = '/catalog';
  static const String productDetail = '/product_detail';
  static const String login = '/login';
  static const String register = '/register';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String adminCatalog = '/admin_catalog';
  static const String productForm = '/product_form';
  static const String adminOrders = '/admin_orders';
  static const String adminSales = '/admin_sales';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
      case catalog:
        return MaterialPageRoute(builder: (_) => const CatalogScreen());
      case productDetail:
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        );
      case login:
        final returnTo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => LoginScreen(returnToRoute: returnTo),
        );
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case adminCatalog:
        return MaterialPageRoute(builder: (_) => const AdminCatalogScreen());
      case productForm:
        final product = settings.arguments as ProductModel?;
        return MaterialPageRoute(
          builder: (_) => ProductFormScreen(productToEdit: product),
        );
      case adminOrders:
        return MaterialPageRoute(builder: (_) => const AdminOrdersScreen());
      case adminSales:
        return MaterialPageRoute(builder: (_) => const AdminSalesScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
