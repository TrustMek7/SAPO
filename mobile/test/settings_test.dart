import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/controller.dart';
import 'package:sapo/game.dart';
import 'package:sapo/screens.dart';
import 'package:sapo/storage.dart';

void main() {
  testWidgets(
    'Personalizado creado en UI persiste al reiniciar y puede editarse/eliminarse',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final dir = Directory('build/test_storage')..createSync(recursive: true);
      final file = File(
        '${dir.path}/custom_ui_${DateTime.now().microsecondsSinceEpoch}.sqlite',
      );
      var db = LocalRepository(NativeDatabase(file));
      await tester.runAsync(() => db.prepare());
      var container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(db)],
      );
      await tester.runAsync(
        () => container.read(appProvider.notifier).initialize(),
      );
      Future<void> show() async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<void> tap(String text) async {
        await tester.ensureVisible(find.text(text));
        await tester.tap(find.text(text));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pumpAndSettle();
      }

      await show();
      await tester.enterText(
        find.byType(TextField),
        'Inventa una canción sobre una nube de colores.',
      );
      await tap('Guardar contenido');
      expect(container.read(appProvider.notifier).custom.length, 1);
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();
      expect(container.read(appProvider.notifier).settings['sound'], false);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.runAsync(() => db.close());
      db = LocalRepository(NativeDatabase(file));
      await tester.runAsync(() => db.prepare());
      container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(db)],
      );
      await tester.runAsync(
        () => container.read(appProvider.notifier).initialize(),
      );
      expect(
        container.read(appProvider.notifier).custom.single['text'],
        'Inventa una canción sobre una nube de colores.',
      );
      expect(container.read(appProvider.notifier).settings['sound'], false);
      await show();
      await tap('Inventa una canción sobre una nube de colores.');
      await tester.enterText(
        find.byType(TextField),
        'Inventa una canción sobre un gato astronauta.',
      );
      await tap('Guardar cambios');
      expect(
        container.read(appProvider.notifier).custom.single['text'],
        'Inventa una canción sobre un gato astronauta.',
      );
      await tester.ensureVisible(find.byTooltip('Eliminar contenido'));
      await tester.tap(find.byTooltip('Eliminar contenido'));
      await tester.pumpAndSettle();
      expect(container.read(appProvider.notifier).custom, isEmpty);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.runAsync(() async {
        await db.close();
        await file.delete();
      });
    },
  );
  testWidgets(
    'Reiniciar historial exige confirmación y conserva historia de partida',
    (tester) async {
      final db = LocalRepository(NativeDatabase.memory());
      await db.prepare();
      final container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(db)],
      );
      final c = container.read(appProvider.notifier);
      c.game = Game(['Ana', 'Luis'], 1)..used = ['c1_1'];
      await c.save();
      c.history = await db.history();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: const SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reiniciar historial'));
      await tester.pumpAndSettle();
      expect(await db.history(), ['c1_1']);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(await db.history(), ['c1_1']);
      await tester.tap(find.text('Reiniciar historial'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();
      expect(await db.history(), isEmpty);
      expect(c.game!.used, ['c1_1']);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    },
  );
}
