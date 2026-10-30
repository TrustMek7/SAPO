import 'dart:math';

import 'package:flutter/material.dart';

import 'sapo_logo.dart';
import 'sapo_widgets.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
    required this.ready,
    required this.error,
    required this.onNew,
    required this.onContinue,
    required this.onSettings,
    this.onToggleTheme,
    this.animate = true,
  });
  final bool ready;
  final String? error;
  final VoidCallback? onNew, onContinue, onSettings, onToggleTheme;
  final bool animate;
  @override
  Widget build(BuildContext context) {
    final p = context.sapo,
        dark = Theme.of(context).brightness == Brightness.dark,
        logo = min(184.0, MediaQuery.sizeOf(context).shortestSide * .46);
    return Scaffold(
      body: PartyBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SapoLogo(
                              size: logo,
                              animate: ambientMotion(context, enabled: animate),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  brandName,
                                  style: TextStyle(
                                    fontFamily: titleFont,
                                    fontSize: 64,
                                    height: 1.05,
                                    letterSpacing: 1,
                                    color: p.text,
                                    shadows: [
                                      Shadow(
                                        color: p.titleShadow,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              key: const Key('whatDoesSapoMean'),
                              onPressed: () => showDialog<void>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('\u00BFSapo, qu\u00E9 chch eres?'),
                                  content: const Text(
                                    'En Per\u00FA, un sapo siempre est\u00E1 atento al '
                                    'chisme. En S.A.P.O. tambi\u00E9n salen verdades, '
                                    'historias y confesiones que prenden la reuni\u00F3n. \u{1F440}',
                                  ),
                                  actions: [
                                    FilledButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      child: const Text('\u00A1Ya, entend\u00ED!'),
                                    ),
                                  ],
                                ),
                              ),
                              icon: const Icon(Icons.help_outline, size: 18),
                              label: const Text('\u00BFQu\u00E9 significa?'),
                              style: TextButton.styleFrom(
                                foregroundColor: p.accentText,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              brandMotto,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                color: p.motto,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: p.accentText,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'SOLO ADULTOS +18',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                  color: p.accentText,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'La participación es voluntaria.\nTomar nunca es obligatorio.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: p.muted),
                            ),
                            if (error != null)
                              Text('No se pudo abrir el guardado: $error'),
                            if (!ready && error == null)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        action(
                          'Nueva partida',
                          onNew,
                          key: const Key('newGame'),
                        ),
                        if (onContinue != null)
                          action('Continuar partida', onContinue),
                        action('Ajustes y contenido', onSettings),
                      ],
                    ),
                  ),
                ],
              ),
              if (onToggleTheme != null)
                Positioned(
                  top: 8,
                  right: 12,
                  child: IconButton.outlined(
                    key: const Key('toggleTheme'),
                    tooltip: dark ? 'Usar tema claro' : 'Usar tema oscuro',
                    onPressed: onToggleTheme,
                    style: IconButton.styleFrom(
                      backgroundColor: p.surface,
                      foregroundColor: p.text,
                      side: BorderSide(color: p.line),
                      minimumSize: const Size(44, 44),
                    ),
                    icon: Icon(
                      dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
