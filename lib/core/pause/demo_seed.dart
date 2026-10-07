import 'pause_book.dart';

class DemoSeed {
  DemoSeed._();

  static PauseBook book(DateTime now) {
    return PauseBook(items: [
      PauseItem(
        id: 'pack',
        name: 'Canvas backpack',
        price: 690000,
        link: '',
        reason: 'Want a smaller backpack for work.',
        ownsSimilar: true,
        similarCount: 1,
        createdAt: now.subtract(const Duration(days: 7)),
        dueAt: now.subtract(const Duration(minutes: 1)),
        remind: true,
        status: PauseStatus.waiting,
        decidedAt: null,
        tone: 0,
      ),
      PauseItem(
        id: 'headphones',
        name: 'Wireless headphones',
        price: 1290000,
        link: '',
        reason: 'Want to listen while walking, without a cable.',
        ownsSimilar: false,
        similarCount: 0,
        createdAt: now.subtract(const Duration(hours: 54)),
        dueAt: now.add(const Duration(hours: 18)),
        remind: true,
        status: PauseStatus.waiting,
        decidedAt: null,
        tone: 1,
      ),
      PauseItem(
        id: 'lamp',
        name: 'Desk lamp',
        price: 450000,
        link: '',
        reason: 'Want a brighter reading corner at night.',
        ownsSimilar: false,
        similarCount: 0,
        createdAt: now.subtract(const Duration(days: 5)),
        dueAt: now.add(const Duration(days: 2)),
        remind: true,
        status: PauseStatus.waiting,
        decidedAt: null,
        tone: 2,
      ),
    ]);
  }
}
