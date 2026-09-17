import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signOut();

    if (!context.mounted || success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.error ?? 'Unable to sign out.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Appearance'),
          Card(
            child: SwitchListTile.adaptive(
              title: const Text('Dark mode'),
              subtitle: Text(theme.isDark ? 'Dark theme is active' : 'Light theme is active'),
              value: theme.isDark,
              onChanged: auth.loading ? null : theme.setDark,
              secondary: Icon(
                theme.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle('Account'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(auth.user?.email ?? 'Signed-in user'),
              subtitle: const Text('Firebase Email/Password account'),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: auth.loading ? null : () => _signOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
