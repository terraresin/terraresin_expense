import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_design_system/design_system.dart';

import 'providers/auth/auth_providers.dart';
import 'screens/auth/login_screen.dart';
import 'responsive/desktop.dart';
import 'responsive/mobile.dart';
import 'responsive/tablet.dart';

class TerraResinApp extends StatelessWidget {
  const TerraResinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerraResin ERP',
      debugShowCheckedModeBanner: false,
      theme: TerraResinTheme.light,
      darkTheme: TerraResinTheme.dark,
      themeMode: ThemeMode.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(currentUserProvider);

    return authState.when(
      loading: () => const _AuthLoadingScreen(),
      error: (error, stackTrace) => const LoginScreen(),
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        return const ResponsiveHome();
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 1200) {
      return const DesktopLayout();
    }

    if (width >= 600) {
      return const TabletLayout();
    }

    return const MobileLayout();
  }
}
