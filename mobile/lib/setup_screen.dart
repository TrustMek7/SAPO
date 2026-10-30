import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller.dart';
import 'game.dart';
import 'board/board_screen.dart';
import 'ui/sapo_widgets.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});
  @override
  ConsumerState<SetupScreen> createState() => _SetupState();
}

class _SetupState extends ConsumerState<SetupScreen> {
  final name = TextEditingController();
  final scroll = ScrollController();
  final names = <String>[], icons = <String>[];
  late AppController controller;
  String avatar = avatars.first;
  String get profile =>
      ['Tranqui', 'Equilibrado', 'Sin vergüenza'][intensity - 1];
  int step = 0, intensity = 2, size = 50;
  Set<int> enabled = playableCategories.toSet();
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    controller = ref.read(appProvider.notifier);
    final draft = controller.setupDraft;
    if (draft.isNotEmpty) {
      names.addAll(List<String>.from(draft['names']));
      icons.addAll(List<String>.from(draft['icons']));
      intensity = draft['intensity'];
      size = draft['size'];
      enabled = List<int>.from(draft['enabled']).toSet();
      avatar = avatars[names.length % avatars.length];
    }
  }

  void remember() => controller.setupDraft = {
    'names': List.of(names),
    'icons': List.of(icons),
    'intensity': intensity,
    'size': size,
    'profile': profile,
    'enabled': enabled.toList()..sort(),
  };
  Future<void> pickAvatar() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elige tu ficha'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            children: [
              for (final a in avatars)
                ChoiceChip(
                  label: Text(a, style: const TextStyle(fontSize: 26)),
                  selected: avatar == a,
                  onSelected: (_) => Navigator.pop(ctx, a),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (mounted && selected != null) change(() => avatar = selected);
  }

  @override
  void dispose() {
    name.dispose();
    scroll.dispose();
    super.dispose();
  }

  void change(VoidCallback update) {
    setState(() {
      update();
      error = null;
    });
    remember();
  }

  bool add() {
    final value = name.text.trim();
    if (value.isEmpty ||
        names.any((n) => n.toLowerCase() == value.toLowerCase()) ||
        names.length >= 12) {
      setState(
        () => error = value.isEmpty
            ? 'Escribe un nombre y pulsa Agregar.'
            : names.length >= 12
            ? 'El máximo es 12 jugadores.'
            : 'Ese nombre ya está en la lista.',
      );
      return false;
    }
    change(() {
      names.add(value);
      icons.add(avatar);
      name.clear();
      avatar = avatars[names.length % avatars.length];
    });
    return true;
  }

  bool validatePlayers() {
    if (name.text.trim().isNotEmpty && !add()) return false;
    if (names.length < 2) {
      setState(() => error = 'Agrega al menos 2 jugadores para continuar.');
      return false;
    }
    return true;
  }

  void go(int destination) {
    if (saving) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (destination > 0 && !validatePlayers()) {
      setState(() => step = 0);
      return;
    }
    if (destination > 1 && enabled.isEmpty) {
      setState(() {
        step = 1;
        error = 'Activa al menos una categoría para continuar.';
      });
      return;
    }
    change(() => step = destination);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  void back() {
    if (step > 0) {
      go(step - 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> edit(int index) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _PlayerEditor(
        name: names[index],
        icon: icons[index],
        others: [
          for (var i = 0; i < names.length; i++)
            if (i != index) names[i],
        ],
      ),
    );
    if (!mounted || result == null) return;
    change(() {
      names[index] = result['name']!;
      icons[index] = result['icon']!;
    });
  }

  Future<void> start() async {
    if (saving || !validatePlayers()) return;
    if (enabled.isEmpty) {
      go(1);
      setState(() => error = 'Activa al menos una categoría para continuar.');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await controller.start(
        Game(
          names,
          DateTime.now().millisecondsSinceEpoch,
          intensity: intensity,
          size: size,
          profile: profile,
          enabled: enabled.toList()..sort(),
          icons: List.of(icons),
        ),
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const BoardScreen()),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = 'No se pudo guardar la partida. Intenta comenzar otra vez.';
        });
      }
    }
  }

  Widget section(String title, List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
  List<Widget> players() => [
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF236A60), Color(0xFF143D43)],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 5), blurRadius: 2),
        ],
      ),
      child: Text(
        '¿Quiénes se atreven?',
        style: const TextStyle(
          fontFamily: titleFont,
          fontSize: 26,

          color: Colors.white,
        ),
      ),
    ),
    const SizedBox(height: 12),
    const Text('2–12 adultos. Escribe un nombre, pulsa + y repite.'),
    const SizedBox(height: 16),
    TextField(
      key: const Key('playerName'),
      controller: name,
      maxLength: 24,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => add(),
      decoration: InputDecoration(
        labelText: names.isEmpty ? 'Primer jugador' : 'Siguiente jugador',
        hintText: names.isEmpty ? 'Ej. Ana' : 'Escribe otro nombre',
        helperText: 'Pulsa + o Listo para agregar.',
        prefixIcon: IconButton(
          key: const Key('nextAvatar'),
          tooltip: 'Elegir ficha',
          onPressed: pickAvatar,
          icon: Text(avatar, style: const TextStyle(fontSize: 26)),
        ),
        suffixIcon: IconButton.filled(
          key: const Key('addPlayerInline'),
          tooltip: 'Agregar nombre',
          onPressed: add,
          style: IconButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: ink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.add, size: 28, color: ink),
        ),
      ),
    ),
    Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(
          '${names.length} de 12 jugadores',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          key: const Key('addPlayer'),
          onPressed: add,
          icon: const Icon(Icons.person_add_alt_1),
          label: Text(names.isEmpty ? 'Agregar jugador' : 'Agregar otro'),
        ),
      ],
    ),
    const SizedBox(height: 12),
    if (names.isEmpty)
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('Tu lista está vacía. Agrega el primer nombre arriba.'),
      ),
    for (var i = 0; i < names.length; i++)
      Card(
        color: context.sapo.surface,
        child: ListTile(
          key: Key('player$i'),
          leading: IconButton(
            tooltip: 'Cambiar icono',
            onPressed: () => edit(i),
            icon: Text(icons[i], style: const TextStyle(fontSize: 26)),
          ),
          title: Text(
            '${i + 1}. ${names[i]}',
            style: TextStyle(
              color: context.sapo.text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            'Toca para editar',
            style: TextStyle(color: context.sapo.muted),
          ),
          onTap: () => edit(i),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Subir',
                onPressed: i == 0
                    ? null
                    : () => change(() {
                        final n = names.removeAt(i), a = icons.removeAt(i);
                        names.insert(i - 1, n);
                        icons.insert(i - 1, a);
                      }),
                icon: Icon(
                  Icons.arrow_upward,
                  color: i == 0 ? context.sapo.line : context.sapo.accentText,
                ),
              ),
              IconButton(
                tooltip: 'Eliminar',
                onPressed: () => change(() {
                  names.removeAt(i);
                  icons.removeAt(i);
                }),
                icon: Icon(
                  Icons.delete_outline,
                  color: context.sapo.accentText,
                ),
              ),
            ],
          ),
        ),
      ),
  ];
  List<Widget> options() => [
    section('Intensidad', [
      Wrap(
        key: const Key('intensity'),
        spacing: 8,
        runSpacing: 6,
        children: [
          for (var i = 1; i <= 3; i++)
            ChoiceChip(
              key: Key('intensity$i'),
              label: Text(['Tranqui', 'Picante', 'Sin vergüenza'][i - 1]),
              selected: intensity == i,
              onSelected: (_) => change(() => intensity = i),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        [
          'Ligero, pero adulto: besos, atracción, ex y confesiones con vergüenza.',
          'Relaciones, deseo y situaciones íntimas más comprometedoras.',
          'Preguntas íntimas y sexuales directas; retos sensuales sin contacto impuesto.',
        ][intensity - 1],
      ),
    ]),
    section('Tamaño del tablero', [
      Wrap(
        key: const Key('boardSize'),
        spacing: 8,
        children: [
          for (final n in [30, 50, 75, 100])
            ChoiceChip(
              key: Key('size$n'),
              label: Text('$n casillas'),
              selected: size == n,
              onSelected: (_) => change(() => size = n),
            ),
        ],
      ),
    ]),
    section('Categorías de la partida', [
      Wrap(
        spacing: 8,
        children: [
          TextButton(
            onPressed: () => change(() => enabled = playableCategories.toSet()),
            child: const Text('Todas'),
          ),
          TextButton(
            onPressed: () => change(() => enabled = {}),
            child: const Text('Ninguna'),
          ),
        ],
      ),
      for (final c in playableCategories)
        SwitchListTile.adaptive(
          key: Key('category$c'),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: context.sapo.category(c),
          title: Text(categories[c]),
          subtitle: Text(
            {
              1: 'Coqueteo, relaciones, secretos y preguntas sexuales según intensidad.',
              2: 'Consignas que indican quién toma.',
              3: 'Actuación, duelos y desafíos.',
              4: 'Dinámicas para todo el grupo.',
              5: 'Cambios reales sobre el tablero.',
            }[c]!,
          ),
          value: enabled.contains(c),
          onChanged: (value) => change(() {
            if (value) {
              enabled.add(c);
            } else {
              enabled.remove(c);
            }
          }),
        ),
    ]),
  ];
  List<Widget> review() {
    final preview = Game(
      names,
      0,
      intensity: intensity,
      size: size,
      profile: profile,
      enabled: enabled.toList()..sort(),
      icons: icons,
    );
    return [
      const Text(
        'Todo listo',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      const Text(
        'Revisa la partida. Puedes volver para cambiar cualquier opción.',
      ),
      section('Jugadores y orden', [
        for (var i = 0; i < names.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${i + 1}. ${icons[i]} ${names[i]}'),
          ),
      ]),
      section('Tu partida', [
        Text('$size casillas'),
        Text(
          'Intensidad: ${['Tranqui', 'Picante', 'Sin vergüenza'][intensity - 1]}',
        ),
        const SizedBox(height: 12),
        for (final c in playableCategories.where(enabled.contains))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '${categories[c]} · ${preview.board.where((cell) => cell == c).length} casillas',
              style: TextStyle(color: colors[c]),
            ),
          ),
      ]),
      const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Un celular, turnos en orden y guardado automático. Participar es voluntario; la aplicación no obliga a consumir alcohol.',
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: step == 0 && !saving,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && !saving && step > 0) go(step - 1);
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Nueva partida'),
        leading: IconButton(
          tooltip: 'Atrás',
          onPressed: saving ? null : back,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: TextButton(
                      key: Key('setupStep$i'),
                      onPressed: saving ? null : () => go(i),
                      child: Text(
                        '${i + 1}. ${['Jugadores', 'Partida', 'Revisar'][i]}',
                        style: TextStyle(
                          fontWeight: step == i
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: step == i
                              ? Theme.of(context).colorScheme.primary
                              : context.sapo.muted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          LinearProgressIndicator(value: (step + 1) / 3),
          Expanded(
            child: ListView(
              key: const Key('setupScroll'),
              controller: scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              children: step == 0
                  ? players()
                  : step == 1
                  ? options()
                  : review(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      error!,
                      key: const Key('setupError'),
                      style: TextStyle(color: context.sapo.category(7)),
                    ),
                  ),
                Row(
                  children: [
                    if (step > 0) ...[
                      OutlinedButton(
                        onPressed: saving ? null : back,
                        child: const Text('Atrás'),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: FilledButton(
                        key: Key(step == 2 ? 'startGame' : 'setupNext'),
                        onPressed: saving
                            ? null
                            : step == 2
                            ? start
                            : () => go(step + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            saving
                                ? 'Guardando…'
                                : [
                                    'Elegir partida',
                                    'Revisar partida',
                                    'Comenzar partida',
                                  ][step],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _PlayerEditor extends StatefulWidget {
  const _PlayerEditor({
    required this.name,
    required this.icon,
    required this.others,
  });
  final String name, icon;
  final List<String> others;
  @override
  State<_PlayerEditor> createState() => _PlayerEditorState();
}

class _PlayerEditorState extends State<_PlayerEditor> {
  late final edit = TextEditingController(text: widget.name);
  late String icon = widget.icon;
  String? error;
  @override
  void dispose() {
    edit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Editar jugador'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('editPlayerName'),
            controller: edit,
            maxLength: 24,
            decoration: InputDecoration(labelText: 'Nombre', errorText: error),
          ),
          Wrap(
            spacing: 4,
            children: [
              for (final a in avatars)
                ChoiceChip(
                  label: Text(a),
                  selected: icon == a,
                  onSelected: (_) => setState(() => icon = a),
                ),
            ],
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          final value = edit.text.trim();
          if (value.isEmpty ||
              widget.others.any(
                (n) => n.toLowerCase() == value.toLowerCase(),
              )) {
            setState(() => error = 'Usa un nombre diferente y no vacío.');
            return;
          }
          Navigator.pop(context, {'name': value, 'icon': icon});
        },
        child: const Text('Guardar'),
      ),
    ],
  );
}
