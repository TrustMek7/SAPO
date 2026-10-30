import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/app.dart';
import 'package:sapo/controller.dart';
import 'package:sapo/storage.dart';
import 'package:sapo/ui/sapo_widgets.dart';

void main() {
  for (final viewport in [
    (const Size(360, 640), 1.0),
    (const Size(384, 832), 1.6),
    (const Size(640, 360), 1.0),
  ]) {
    testWidgets(
      'Marca y Nueva partida accesibles en ${viewport.$1}, texto ${viewport.$2}',
      (tester) async {
        tester.view.physicalSize = viewport.$1;
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
        tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
        tester.platformDispatcher.textScaleFactorTestValue = viewport.$2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final db = LocalRepository(NativeDatabase.memory());
        await db.prepare();
        final container = ProviderContainer(
          overrides: [repositoryProvider.overrideWithValue(db)],
        );
        addTearDown(() async {
          container.dispose();
          await db.close();
        });
        await tester.runAsync(
          () => container.read(appProvider.notifier).initialize(),
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const SapoApp(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirmAdult')));
        await tester.pumpAndSettle();
        expect(find.text(brandName), findsOneWidget);
        expect(find.byKey(const Key('whatDoesSapoMean')), findsOneWidget);
        expect(find.text(brandMotto), findsOneWidget);
        expect(find.byKey(const Key('newGame')).hitTestable(), findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('whatDoesSapoMean')));
        await tester.tap(find.byKey(const Key('whatDoesSapoMean')));
        await tester.pumpAndSettle();
        expect(find.text('\u00BFSapo, qu\u00E9 chch eres?'), findsOneWidget);
        expect(find.textContaining('En Perú, un sapo siempre está atento'), findsOneWidget);
        await tester.tap(find.text('\u00A1Ya, entend\u00ED!'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('newGame')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('setupNext')).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
