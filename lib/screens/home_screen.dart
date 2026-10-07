import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/pause/pause_book.dart';
import '../core/services/share_inbox.dart';
import '../providers/pause_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/ad_banner_slot.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/coin_balance_chip.dart';
import '../widgets/pause_chrome.dart';
import 'add_item_screen.dart';
import 'decision_screen.dart';
import 'home/settings_screen.dart';

String _items(int count) => count == 1 ? '1 item' : '$count items';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _tab = 0;
  var _filter = 0;
  var _shareArmed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shareArmed) return;
    _shareArmed = true;
    final pauses = context.read<PauseProvider>();
    pauses.onSharedLink = (link) {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AddItemScreen(initialLink: link),
      ));
    };
    ShareInbox.listen(pauses.acceptShared);
  }

  @override
  Widget build(BuildContext context) {
    return FtrScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _tab == 0
                  ? _Shelf(
                      filter: _filter,
                      onFilter: (value) => setState(() => _filter = value),
                    )
                  : const _Decided(),
            ),
            const AdBannerSlot(),
            _Bar(
                index: _tab, onSelect: (index) => setState(() => _tab = index)),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;

  const _Bar({required this.index, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          _item(0, Icons.shopping_bag_outlined, Icons.shopping_bag, 'Shelf'),
          _item(1, Icons.check_circle_outline, Icons.check_circle, 'Decided'),
        ],
      ),
    );
  }

  Widget _item(int i, IconData icon, IconData selected, String label) {
    final on = index == i;
    final color = on ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(i),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(on ? selected : icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shelf extends StatelessWidget {
  final int filter;
  final ValueChanged<int> onFilter;

  const _Shelf({required this.filter, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    final pauses = context.watch<PauseProvider>();
    final now = DateTime.now();
    final waiting = PauseEngine.waiting(pauses.book);
    final due = PauseEngine.due(pauses.book, now);
    final items = PauseEngine.shelf(pauses.book, now, filter);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEAFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('PauseCart',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const Spacer(),
            const CoinBalanceChip(variant: CoinChipVariant.header),
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const Text('Save the want.\nDecide later.',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: AppColors.ink)),
        const SizedBox(height: 14),
        Row(
          children: [
            _Stat(
                icon: Icons.hourglass_bottom,
                tint: const Color(0xFFEFEAFF),
                iconColor: AppColors.primary,
                label: '${_items(waiting.length - due.length)}\nwaiting'),
            const SizedBox(width: 10),
            _Stat(
                icon: Icons.event_available,
                tint: const Color(0xFFE7F6E4),
                iconColor: const Color(0xFF3E8F4A),
                label: '${_items(due.length)}\ndue'),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _FilterChip(
                label: 'All', selected: filter == 0, onTap: () => onFilter(0)),
            const SizedBox(width: 8),
            _FilterChip(
                label: 'Waiting',
                selected: filter == 1,
                onTap: () => onFilter(1)),
            const SizedBox(width: 8),
            _FilterChip(
                label: 'Due', selected: filter == 2, onTap: () => onFilter(2)),
          ],
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          const Text('The shelf is empty. Save something you want, then wait.',
              style: TextStyle(color: AppColors.textSecondary)),
        for (final item in items) ...[
          _ItemCard(item: item, now: now),
          const SizedBox(height: 12),
        ],
        PauseButton(
          label: 'Add something you want',
          onPressed: () => _add(context),
        ),
      ],
    );
  }

  Future<void> _add(BuildContext context) async {
    final pauses = context.read<PauseProvider>();
    final shop = context.read<ShopProvider>();
    if (!pauses.canAdd(shop.hasPro)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Open PauseCart Pro to keep more items on the shelf.')));
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddItemScreen()),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String label;

  const _Stat({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 8),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: selected ? AppColors.primary : const Color(0xFFE6E0F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              )),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final PauseItem item;
  final DateTime now;

  const _ItemCard({required this.item, required this.now});

  @override
  Widget build(BuildContext context) {
    final due = PauseEngine.isDue(item, now);
    return ShelfCard(
      tint: due ? const Color(0xFFF4FBF3) : const Color(0xFFF6F3FF),
      onTap: due
          ? () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DecisionScreen(itemId: item.id),
              ))
          : () async {
              final wait = await askWait(context);
              if (wait == null || !context.mounted) return;
              await context.read<PauseProvider>().postpone(item.id, wait);
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductArt(tone: item.tone),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                        if (due)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F6E4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('DUE',
                                style: TextStyle(
                                    color: Color(0xFF3E8F4A),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10)),
                          ),
                      ],
                    ),
                    Text(PauseEngine.dong(item.price),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 14,
                            color: due
                                ? const Color(0xFF3E8F4A)
                                : AppColors.primary),
                        const SizedBox(width: 4),
                        Text(PauseEngine.clock(item, now),
                            style: TextStyle(
                              color: due
                                  ? const Color(0xFF3E8F4A)
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!due) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: PauseEngine.progress(item, now),
                minHeight: 6,
                backgroundColor: const Color(0xFFE4DCF8),
                color: AppColors.primary,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text('Review this want',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}

class _Decided extends StatelessWidget {
  const _Decided();

  @override
  Widget build(BuildContext context) {
    final pauses = context.watch<PauseProvider>();
    final still = PauseEngine.decided(pauses.book, PauseStatus.still);
    final released = PauseEngine.decided(pauses.book, PauseStatus.released);
    final total = PauseEngine.letGoTotal(pauses.book);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text('Decided',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Items you let go, or still want. This is not money saved.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.35)),
        const SizedBox(height: 16),
        if (still.isEmpty && released.isEmpty)
          const Text('Nothing decided yet. Due items stay on the shelf.',
              style: TextStyle(color: AppColors.textSecondary)),
        if (still.isNotEmpty) ...[
          const Text('Still want',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          for (final item in still) ...[
            _DecisionRow(item: item, note: 'Still want'),
            const SizedBox(height: 10),
          ],
        ],
        if (released.isNotEmpty) ...[
          const Text('Let go',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          for (final item in released) ...[
            _DecisionRow(item: item, note: 'Let go'),
            const SizedBox(height: 10),
          ],
          Text(
            'Let-go total: ${PauseEngine.dong(total)}. This is not money saved.',
            style:
                const TextStyle(color: AppColors.textSecondary, height: 1.35),
          ),
        ],
      ],
    );
  }
}

class _DecisionRow extends StatelessWidget {
  final PauseItem item;
  final String note;

  const _DecisionRow({required this.item, required this.note});

  @override
  Widget build(BuildContext context) {
    return ShelfCard(
      child: Row(
        children: [
          ProductArt(tone: item.tone, size: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(PauseEngine.dong(item.price),
                    style: const TextStyle(color: AppColors.textSecondary)),
                Text(note,
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
