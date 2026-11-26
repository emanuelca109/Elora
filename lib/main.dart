import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';
import 'data/database_helper.dart';
import 'providers/controllers/auth_controller.dart';
import 'providers/controllers/product_controller.dart';
import 'providers/controllers/cart_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop FFI initialization for Windows / Linux
  DatabaseHelper.initializePlatform();

  // Pre-initialize SQLite Database and seed tables
  await DatabaseHelper.instance.database;

  runApp(const EloraApp());
}

class EloraApp extends StatelessWidget {
  const EloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()..loadProducts()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'ELORA - Perfumería de Lujo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.catalog,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
