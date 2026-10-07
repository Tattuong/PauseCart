import 'package:flutter/widgets.dart';

import '../core/pause/pause_book.dart';
import '../core/services/pause_reminder.dart';
import '../core/services/storage_service.dart';

class PauseProvider extends ChangeNotifier {
  static const _bookKey = 'pc_pauses';
  static const _remindKey = 'pc_reminders';
  static const _demoIds = {'pack', 'headphones', 'lamp'};

  List<PauseItem> items = [];
  var reminders = true;
  var _seq = 0;
  void Function(String link)? onSharedLink;

  PauseBook get book => PauseBook(items: items);

  Future<void> init() async {
    reminders = await StorageService.instance.getBool(_remindKey) ?? true;
    final raw = await StorageService.instance.getString(_bookKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        items = PauseBook.decode(raw).items;
      } catch (_) {
        await StorageService.instance.remove(_bookKey);
      }
    }
    final before = items.length;
    items = [
      for (final item in items)
        if (!_demoIds.contains(item.id)) item
    ];
    if (items.length != before) await _save();
    notifyListeners();
    await PauseReminder.sync(book, enabled: reminders);
  }

  bool canAdd(bool hasPro) =>
      hasPro || PauseEngine.waiting(book).length < PauseEngine.freeWaiting;

  Future<PauseItem?> add({
    required String name,
    required int price,
    required String link,
    required String reason,
    required bool ownsSimilar,
    required Duration wait,
    required bool remind,
    required bool hasPro,
  }) async {
    if (!canAdd(hasPro)) return null;
    final now = DateTime.now();
    final item = PauseItem(
      id: 'item-${now.microsecondsSinceEpoch}-${_seq++}',
      name: name.trim(),
      price: price,
      link: link.trim(),
      reason: reason.trim(),
      ownsSimilar: ownsSimilar,
      similarCount: ownsSimilar ? 1 : 0,
      createdAt: now,
      dueAt: now.add(wait),
      remind: remind,
      status: PauseStatus.waiting,
      decidedAt: null,
      tone: items.length % 4,
    );
    items = [...items, item];
    await _commit();
    return item;
  }

  Future<void> postpone(String id, Duration wait) async {
    final now = DateTime.now();
    items = [
      for (final item in items)
        if (item.id == id)
          item.copyWith(
            createdAt: now,
            dueAt: now.add(wait),
            status: PauseStatus.waiting,
            clearDecision: true,
          )
        else
          item,
    ];
    await _commit();
  }

  Future<void> decide(String id, PauseStatus status) async {
    if (status == PauseStatus.waiting) return;
    items = [
      for (final item in items)
        if (item.id == id)
          item.copyWith(status: status, decidedAt: DateTime.now())
        else
          item,
    ];
    await _commit();
  }

  Future<void> setReminders(bool value) async {
    reminders = value;
    await StorageService.instance.saveBool(_remindKey, value);
    notifyListeners();
    await PauseReminder.sync(book, enabled: reminders);
  }

  void acceptShared(String raw) {
    final link = PauseEngine.extractUrl(raw);
    if (link == null) return;
    onSharedLink?.call(link);
  }

  Future<void> _commit() async {
    await _save();
    notifyListeners();
    await PauseReminder.sync(book, enabled: reminders);
  }

  Future<void> _save() async {
    await StorageService.instance.saveString(_bookKey, book.encode());
  }
}
