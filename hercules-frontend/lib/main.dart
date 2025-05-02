import 'package:flutter/material.dart';
import 'package:hercules/styles/app_colors.dart';
import 'package:hercules/config/app_routes.dart';
import 'package:provider/provider.dart';
import 'profile_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileProvider()), // Provide ProfileProvider
      ],
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          brightness: Brightness.light,
        ),
        initialRoute: AppRoutes.login,
        routes: AppRoutes.pages,  // Use AppRoutes for route management
      ),
    );
  }
}
