import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/features/dashboard/common_tabs/fwbreakseal/view/fwbreakseal_tab.dart';
import 'package:maleva/features/operations/forwarding/bloc/forwarding_bloc.dart';
import 'package:maleva/features/operations/forwarding/bloc/forwarding_event.dart';
import 'package:maleva/features/operations/forwarding/view/forwarding_tab.dart';

/// Seal and break seal from a dashboard tab, for a boarding person who also does
/// forwarding work (employee-extra-jobs-and-driver-mode). Opens the same screens
/// as the drawer's "Forwarding Update" and "Forwarding Exit Update".
class SealBreakSealTab extends StatelessWidget {
  const SealBreakSealTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _OpenCard(
          icon: Icons.lock_outline,
          title: 'Seal',
          subtitle: 'Forwarding Update: seal by, photos and K1/K2 details',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => sl<FWUpdateBloc>()..add(FWUpdateStarted()),
                child: const FWUpdatePage(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _OpenCard(
          icon: Icons.lock_open_outlined,
          title: 'Break Seal',
          subtitle: 'Forwarding Exit Update: break seal by',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FWUpdateBreakSeal()),
          ),
        ),
      ],
    );
  }
}

class _OpenCard extends StatelessWidget {
  const _OpenCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 30, color: const Color(0xFF1A2E5A)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
