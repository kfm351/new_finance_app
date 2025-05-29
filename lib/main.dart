import 'package:flutter/material.dart';
import 'package:personal_finance_helper/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:personal_finance_helper/screens/auth_screen.dart';
import 'package:personal_finance_helper/screens/home_screen.dart';
import 'package:personal_finance_helper/screens/add_transaction.dart';
import 'package:personal_finance_helper/screens/stats_screen.dart';
import 'package:personal_finance_helper/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MyApp(), // Убрал const здесь
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Оставил const для самого виджета

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Финансовый Помощник',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (ctx) {
          return Consumer<AuthService>(
            builder: (ctx, auth, _) {
              return auth.isAuthenticated
                  ? HomeScreen()
                  : AuthScreen(); // Убрал const
            },
          );
        },
        '/home': (ctx) => HomeScreen(), // Убрал const
        '/add': (ctx) => AddTransactionScreen(), // Убрал const
        '/stats': (ctx) => StatsScreen(), // Убрал const
      },
    );
  }
}
