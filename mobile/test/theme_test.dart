import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/app.dart';
import 'package:sapo/controller.dart';
import 'package:sapo/storage.dart';
import 'package:sapo/ui/sapo_logo.dart';
import 'package:sapo/ui/sapo_widgets.dart';

void main() {
  test('Temas claro y oscuro llevan su paleta S.A.P.O.', () {
    final light = sapoTheme(Brightness.light), dark = sapoTheme();
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.extension<SapoPalette>(), same(SapoPalette.light));
    expect(dark.extension<SapoPalette>(), same(SapoPalette.dark));
    for (final palette in [SapoPalette.light, SapoPalette.dark]) {
      expect(palette.categories.length, greaterThanOrEqualTo(8));
      expect(palette.text, isNot(palette.bg));
    }
    expect(themeModeFrom('light'), ThemeMode.light);
    expect(themeModeFrom('dark'), ThemeMode.dark);
    expect(themeModeFrom(null), ThemeMode.system);
  });

  testWidgets('El botón de tema alterna claro/oscuro y se guarda', (
    tester,
  ) async {
    final db = LocalRepository(NativeDatabase.memory());
    await db.prepare();
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final c = container.read(appProvider.notifier);
    await tester.runAsync(() async {
      await c.initialize();
      await c.setting('adultConfirmed', true);
      await c.setting('theme', 'light');
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const SapoApp()),
    );
    await tester.pumpAndSettle();
    Brightness brightness() =>
        Theme.of(tester.element(find.text(brandName))).brightness;
    expect(brightness(), Brightness.light);
    expect(find.byType(SapoLogo), findsOneWidget);

    await tester.tap(find.byKey(const Key('toggleTheme')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.dark);
    expect(c.settings['theme'], 'dark');
    final saved = await tester.runAsync(() => db.readValue('settings'));
    expect(saved, contains('"theme":"dark"'));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('El logo alterna los tres sapos al tocarlo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: sapoTheme(Brightness.light),
        home: const Scaffold(body: Center(child: SapoLogo(animate: false))),
      ),
    );
    for (final label in [...SapoLogo.labels, SapoLogo.labels.first]) {
      expect(find.bySemanticsLabel('Logo de S.A.P.O.: $label'), findsOneWidget);
      await tester.tap(find.byType(SapoLogo));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
