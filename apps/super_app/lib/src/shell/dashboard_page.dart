import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_contracts/module_contracts.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final modules = context.watch<List<AppModuleDescriptor>>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alex Super App'),
        actions: const [_DashboardThemeToggle()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.accentBlue.withValues(alpha: 0.22),
                    colors.accentRed.withValues(alpha: 0.18),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Каталог модулей',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: colors.textStrong,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Shell подключает модули явными импортами и отдаёт им тему и общие зависимости.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: colors.textSoft),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${modules.length} модуль${modules.length == 1 ? '' : 'я'} доступно сейчас',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            for (final module in modules) ...[
              _ModuleCard(module: module),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardThemeToggle extends StatelessWidget {
  const _DashboardThemeToggle();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppThemeController>();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: controller.cycleTheme,
        child: Text(
          controller.themePreference.icon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final AppModuleDescriptor module;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          await _openModule(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.cardAlt,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        module.icon,
                        color: colors.accentBlue,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: colors.textStrong,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          module.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.textSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: () async {
                    await _openModule(context);
                  },
                  child: const Text('Открыть'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openModule(BuildContext context) async {
    await context.push(module.entryLocation);
  }
}
