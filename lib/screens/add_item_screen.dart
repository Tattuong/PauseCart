import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/pause/pause_book.dart';
import '../providers/pause_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/pause_chrome.dart';

class AddItemScreen extends StatefulWidget {
  final String? initialLink;

  const AddItemScreen({super.key, this.initialLink});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _link = TextEditingController();
  final _reason = TextEditingController();
  var _owns = false;
  var _wait = const Duration(days: 3);
  var _custom = false;
  var _remind = true;

  @override
  void initState() {
    super.initState();
    _link.text = widget.initialLink ?? '';
    _name.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _link.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text('Add item',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const Text('Give it some time',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    height: 1.15)),
            const SizedBox(height: 6),
            const Text('Save it. You do not have to decide yet.',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 18),
            const _Label('Item name'),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: _field(hint: 'Running shoes'),
            ),
            const SizedBox(height: 14),
            const _Label('Expected price'),
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: _field(hint: '890.000', suffix: 'VND'),
            ),
            const SizedBox(height: 14),
            const _Label('Link · optional'),
            TextField(
              controller: _link,
              keyboardType: TextInputType.url,
              decoration: _field(
                hint: 'Paste a product link',
                prefix: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 14),
            const _Label('Why do you want it?'),
            TextField(
              controller: _reason,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: _field(hint: 'Want a pair for a daily walk.'),
            ),
            const SizedBox(height: 16),
            const _Label('Do you already own something similar?'),
            Row(
              children: [
                _Choice(
                    label: 'Yes',
                    icon: Icons.check,
                    selected: _owns,
                    onTap: () => setState(() => _owns = true)),
                const SizedBox(width: 10),
                _Choice(
                    label: 'Not yet',
                    selected: !_owns,
                    onTap: () => setState(() => _owns = false)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: _Label('How long?')),
                TextButton(
                  onPressed: _pickCustom,
                  child: const Text('Custom'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _WaitChip(
                    label: '24 hours',
                    selected: !_custom && _wait == const Duration(hours: 24),
                    onTap: () => setState(() {
                          _custom = false;
                          _wait = const Duration(hours: 24);
                        })),
                _WaitChip(
                    label: '3 days',
                    selected: !_custom && _wait == const Duration(days: 3),
                    onTap: () => setState(() {
                          _custom = false;
                          _wait = const Duration(days: 3);
                        })),
                _WaitChip(
                    label: '7 days',
                    selected: !_custom && _wait == const Duration(days: 7),
                    onTap: () => setState(() {
                          _custom = false;
                          _wait = const Duration(days: 7);
                        })),
                if (_custom)
                  _WaitChip(
                      label: _customLabel, selected: true, onTap: _pickCustom),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.notifications_none,
                  color: AppColors.primary),
              title: const Text('Remind me when it is due'),
              value: _remind,
              onChanged: (value) => setState(() => _remind = value),
            ),
            const SizedBox(height: 8),
            PauseButton(
              label: 'Put it on the shelf',
              icon: Icons.inventory_2_outlined,
              onPressed: _name.text.trim().isEmpty ? null : _save,
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text('You can always change the wait.',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  String get _customLabel {
    if (_wait.inHours < 48 && _wait.inDays == 0) {
      final hours = _wait.inHours;
      return hours == 1 ? '1 hour' : '$hours hours';
    }
    final days = _wait.inDays;
    return days == 1 ? '1 day' : '$days days';
  }

  Future<void> _pickCustom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked == null) return;
    final due = DateTime(picked.year, picked.month, picked.day, 9);
    final wait = due.difference(DateTime.now());
    if (wait.inHours < 1) return;
    setState(() {
      _custom = true;
      _wait = wait;
    });
  }

  Future<void> _save() async {
    final pauses = context.read<PauseProvider>();
    final shop = context.read<ShopProvider>();
    if (!pauses.canAdd(shop.hasPro)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Open PauseCart Pro to keep more items on the shelf.')));
      return;
    }
    await pauses.add(
      name: _name.text,
      price: PauseEngine.parsePrice(_price.text),
      link: _link.text,
      reason: _reason.text,
      ownsSimilar: _owns,
      wait: _wait,
      remind: _remind,
      hasPro: shop.hasPro,
    );
    if (mounted) Navigator.pop(context);
  }
}

InputDecoration _field({String? hint, Widget? prefix, String? suffix}) {
  const side = BorderSide(color: Color(0xFFE6E0F0));
  final radius = BorderRadius.circular(14);
  return InputDecoration(
    hintText: hint,
    prefixIcon: prefix,
    suffixText: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: radius, borderSide: side),
    enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: side),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _Choice({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primary : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: selected ? AppColors.primary : const Color(0xFFE6E0F0)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null && selected) ...[
                  const Icon(Icons.check, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.ink,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WaitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : const Color(0xFFF3EEFF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w700,
              )),
        ),
      ),
    );
  }
}

Future<Duration?> askWait(BuildContext context) {
  return showModalBottomSheet<Duration>(
    context: context,
    showDragHandle: true,
    builder: (context) => const _WaitSheet(),
  );
}

class _WaitSheet extends StatelessWidget {
  const _WaitSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Wait how long?',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 12),
            _row(context, '24 hours', const Duration(hours: 24)),
            _row(context, '3 days', const Duration(days: 3)),
            _row(context, '7 days', const Duration(days: 7)),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, Duration wait) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      onTap: () => Navigator.pop(context, wait),
    );
  }
}
