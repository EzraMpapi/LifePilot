import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Tracks the user's light/dark/system preference. A plain
/// `StateProvider` is enough here — this is simple, single-value UI
/// state, not domain data that needs a repository behind it. Once
/// Settings (per the spec) is built out, this is the provider that
/// screen would read/write.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class LifePilotApp extends ConsumerWidget {
  const LifePilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'LifePilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
