import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller.dart';
import 'storage.dart';
import 'screens.dart';
import 'ui/sapo_widgets.dart';

Future<void> launch() async {
  WidgetsFlutterBinding.ensureInitialized();
  final r = await LocalRepository.open();
  await r.prepare();
  runApp(
    ProviderScope(
      overrides: [repositoryProvider.overrideWithValue(r)],
      child: const SapoApp(),
    ),
  );
}

class SapoApp extends ConsumerWidget {
  const SapoApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appProvider);
    final settings = ref.read(appProvider.notifier).settings;
    return MaterialApp(
      title: brandName,
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          SafeArea(top: false, child: child ?? const SizedBox.shrink()),
      theme: sapoTheme(Brightness.light),
      darkTheme: sapoTheme(Brightness.dark),
      themeMode: themeModeFrom(settings['theme']),
      home: const HomeScreen(),
    );
  }
}
