import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_theme.dart';
import 'screens/main_navigation.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/supplier_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    dotenv.testLoad(fileInput: ''); // inicializa vacío para evitar NotInitializedError
  }
  runApp(const StockFlowApp());
}

class StockFlowApp extends StatelessWidget {
  const StockFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: Color(0xFFFAF0EC),
                body: Center(child: CircularProgressIndicator(color: Color(0xFFB55A42))),
              ),
            );
          }

          return MaterialApp(
            title: 'Stock Flow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.tema,
            home: auth.isAuthenticated
                ? const MainNavigation()
                : const LoginScreen(),
            routes: {
              '/register': (_) => const RegisterScreen(),
            },
          );
        },
      ),
    );
  }
}