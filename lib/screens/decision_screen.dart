import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/pause/pause_book.dart';
import '../providers/pause_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/pause_chrome.dart';
import 'add_item_screen.dart';

String _items(int count) => count == 1 ? '1 item' : '$count items';

class DecisionScreen extends StatelessWidget {
  final String itemId;

  const DecisionScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final pauses = context.watch<PauseProvider>();
    PauseItem? item;
    for (final candidate in pauses.items) {
      if (candidate.id == itemId) item = candidate;
    }
    if (item == null) {
      return const FtrScaffold(body: Center(child: Text('This item is gone.')));
    }
    final current = item;
    final waited = DateTime.now().difference(current.createdAt).inDays;
    return FtrScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(
                  child: Text('Time to look again',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6E4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF3E8F4A), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      waited <= 0
                          ? 'DUE NOW'
                          : waited == 1
                              ? 'WAITED 1 DAY'
                              : 'WAITED $waited DAYS',
                      style: const TextStyle(
                          color: Color(0xFF3E8F4A),
                          fontWeight: FontWeight.w800,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Do you still want\nthis?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: AppColors.ink)),
            const SizedBox(height: 16),
            Center(child: ProductArt(tone: current.tone, size: 140)),
            const SizedBox(height: 10),
            Text(current.name,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text(PauseEngine.dong(current.price),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E0F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (current.reason.isNotEmpty) ...[
                    const Text('WHY YOU WANTED IT',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.4)),
                    const SizedBox(height: 4),
                    Text('“${current.reason}”',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, height: 1.35)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFE6E0F0)),
                    ),
                  ],
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Similar items you own',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                      Text(
                          current.ownsSimilar
                              ? _items(current.similarCount)
                              : 'None',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Pick what fits right now.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            PauseButton(
              label: "Don't need it",
              icon: Icons.delete_outline,
              color: const Color(0xFF7DBB73),
              onPressed: () => _finish(context, PauseStatus.released),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _later(context, current.id),
              icon: const Icon(Icons.schedule),
              label: const Text('Later'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: Color(0xFFE6E0F0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _finish(context, PauseStatus.still),
              icon: const Icon(Icons.task_alt),
              label: const Text('Still want it'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: Color(0xFFE6E0F0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text('This only saves the decision. Nothing is ordered.',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish(BuildContext context, PauseStatus status) async {
    await context.read<PauseProvider>().decide(itemId, status);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _later(BuildContext context, String id) async {
    final wait = await askWait(context);
    if (wait == null || !context.mounted) return;
    await context.read<PauseProvider>().postpone(id, wait);
    if (context.mounted) Navigator.pop(context);
  }
}
