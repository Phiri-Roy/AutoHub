import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);

    return IconButton(
      icon: Icon(themeNotifier.themeIcon),
      onPressed: () => themeNotifier.toggleTheme(),
      tooltip: 'Toggle theme (${themeNotifier.themeName})',
    );
  }
}

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentTheme = ref.watch(themeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Theme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...ThemeMode.values.map((theme) {
              return RadioListTile<ThemeMode>(
                title: Text(_getThemeName(theme)),
                subtitle: Text(_getThemeDescription(theme)),
                value: theme,
                groupValue: currentTheme,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeNotifier.setTheme(value);
                  }
                },
                secondary: Icon(_getThemeIcon(theme)),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String _getThemeDescription(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system setting';
    }
  }

  IconData _getThemeIcon(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
