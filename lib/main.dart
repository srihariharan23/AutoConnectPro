import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const AutoConnectApp());
}

class AutoConnectApp extends StatelessWidget {
  const AutoConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoConnect Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}

