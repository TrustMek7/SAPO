import 'ui/home_content.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller.dart';
import 'catalog.dart';
import 'game.dart';
import 'minigame.dart';
import 'ui/sapo_widgets.dart';
export 'ui/sapo_widgets.dart' show action, colors, avatars;
export 'board/board_screen.dart' show BoardScreen;
import 'board/board_screen.dart';
import 'setup_screen.dart';
export 'setup_screen.dart' show SetupScreen;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeScreen> {
  bool ready = false;
  bool ageGateShown = false;
  String? error;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        await ref.read(appProvider.notifier).initialize();
        if (mounted) {
          setState(() => ready = true);
          WidgetsBinding.instance.addPostFrameCallback((_) => showAdultGate());
        }
      } catch (e) {
        if (mounted) setState(() => error = '$e');
      }
    });
  }

  Future<void> showAdultGate() async {
    if (!mounted || !ready || ageGateShown) return;
    final controller = ref.read(appProvider.notifier);
    if (controller.settings['adultConfirmed'] == true) return;
    ageGateShown = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('SAPO es +18'),
          content: const Text(
            'Confirma que todas las personas que jugarán tienen 18 años o más. '
            'Los retos con otra persona requieren que acepte; su negativa no se penaliza. '
            'Participar y tomar son decisiones voluntarias.',
          ),
          actions: [
            FilledButton(
              key: const Key('confirmAdult'),
              onPressed: () async {
                await controller.setting('adultConfirmed', true);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Confirmo que todos somos +18'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appProvider);
    final c = ref.read(appProvider.notifier);
    return HomeContent(
      ready: ready,
      error: error,
      onNew: ready ? () => open(context, const SetupScreen()) : null,
      onContinue: c.game == null
          ? null
          : () => open(context, const BoardScreen()),
      onSettings: ready ? () => open(context, const SettingsScreen()) : null,
      onToggleTheme: ready
          ? () => c.setting(
              'theme',
              Theme.of(context).brightness == Brightness.dark
                  ? 'light'
                  : 'dark',
            )
          : null,
      animate: c.settings['animation'] == true,
    );
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<SettingsScreen> {
  final content = TextEditingController();
  int category = 1, intensity = 1;
  String? editing;
  @override
  void dispose() {
    content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appProvider);
    final c = ref.read(appProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              key: const Key('reviewMiniGames'),
              leading: const Icon(Icons.sports_esports_outlined),
              title: const Text('Probar minijuegos'),
              subtitle: const Text(
                'Abre cada dinamica en modo de prueba y vuelve para dar feedback.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => open(
                context,
                MiniGameReviewScreen(
                  challenges: [...c.catalog, ...c.custom]
                      .where(
                        (item) => item['category'] == 3 && item['kind'] == null,
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const Text('Tema', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            key: const Key('themeMode'),
            segments: const [
              ButtonSegment(
                value: 'system',
                icon: Icon(Icons.brightness_auto_outlined),
                label: Text('Sistema'),
              ),
              ButtonSegment(
                value: 'light',
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Claro'),
              ),
              ButtonSegment(
                value: 'dark',
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Oscuro'),
              ),
            ],
            selected: {
              themeModeFrom(c.settings['theme']) == ThemeMode.light
                  ? 'light'
                  : themeModeFrom(c.settings['theme']) == ThemeMode.dark
                  ? 'dark'
                  : 'system',
            },
            onSelectionChanged: (v) => c.setting('theme', v.first),
          ),
          const SizedBox(height: 8),
          for (final e in {
            'sound': 'Sonidos',
            'vibration': 'Vibración',
            'animation': 'Animaciones',
          }.entries)
            SwitchListTile(
              title: Text(e.value),
              value: c.settings[e.key] == true,
              onChanged: (v) => c.setting(e.key, v),
            ),
          ListTile(
            title: const Text('Estadísticas locales'),
            subtitle: Text(
              '${c.played} partidas iniciadas · ${c.victories} victorias',
            ),
          ),
          ExpansionTile(
            title: Text('Historial · ${c.history.length} contenidos'),
            children: [
              for (final id in c.history)
                ListTile(
                  dense: true,
                  title: Text(
                    [...c.catalog, ...c.custom]
                            .where((e) => e['id'] == id)
                            .map((e) => e['text'])
                            .firstOrNull ??
                        id,
                  ),
                ),
            ],
          ),
          action('Reiniciar historial', () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('¿Borrar el historial entre partidas?'),
                content: const Text(
                  'No se borrará el historial de la partida actual.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Borrar'),
                  ),
                ],
              ),
            );
            if (ok == true) await c.clearHistory();
          }),
          const Divider(),
          const Text(
            'Preguntas y retos personalizados',
            style: TextStyle(fontSize: 22),
          ),
          TextField(
            controller: content,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Tu contenido'),
          ),
          DropdownButton<int>(
            value: category,
            items: const [
              DropdownMenuItem(value: 1, child: Text('Verdad o Shot')),
              DropdownMenuItem(value: 3, child: Text('Reto')),
            ],
            onChanged: (v) => setState(() => category = v!),
          ),
          DropdownButton<int>(
            value: intensity,
            items: [1, 2, 3]
                .map(
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(['Tranqui', 'Picante', 'Sin vergüenza'][i - 1]),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => intensity = v!),
          ),
          action(
            editing == null ? 'Guardar contenido' : 'Guardar cambios',
            () async {
              final text = content.text.trim();
              if (text.isEmpty) return;
              if ([...c.catalog, ...c.custom].any(
                (e) =>
                    e['id'] != editing &&
                    normalizeContent(e['text']) == normalizeContent(text),
              )) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Este contenido ya existe.')),
                );
                return;
              }
              final id =
                  editing ?? 'custom_${DateTime.now().microsecondsSinceEpoch}';
              c.custom.removeWhere((e) => e['id'] == id);
              c.custom.add({
                'id': id,
                'concept': conceptForCustom(text, [
                  ...c.catalog,
                  ...c.custom,
                ], id),
                'category': category,
                'intensity': intensity,
                'theme': 'personalizado',
                'status': 'active',
                'text': text,
              });
              await c.saveCustom();
              content.clear();
              if (mounted) setState(() => editing = null);
            },
          ),
          for (final item in c.custom)
            ListTile(
              title: Text(item['text']),
              subtitle: Text(
                '${categories[item['category']]} · nivel ${item['intensity']}',
              ),
              onTap: () {
                content.text = item['text'];
                setState(() {
                  category = item['category'];
                  intensity = item['intensity'];
                  editing = item['id'];
                });
              },
              trailing: IconButton(
                tooltip: 'Eliminar contenido',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  c.custom.remove(item);
                  await c.saveCustom();
                },
              ),
            ),
        ],
      ),
    );
  }
}
