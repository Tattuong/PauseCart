import 'package:flutter_test/flutter_test.dart';
import 'package:pausecart/core/pause/demo_seed.dart';
import 'package:pausecart/core/pause/pause_book.dart';

void main() {
  final now = DateTime(2026, 10, 7, 12);

  PauseItem item(PauseBook book, String id) =>
      book.items.firstWhere((e) => e.id == id);

  test('demo shelf matches the mockup clocks', () {
    final book = DemoSeed.book(now);
    expect(PauseEngine.isDue(item(book, 'pack'), now), isTrue);
    expect(PauseEngine.clock(item(book, 'pack'), now), 'Waited 7 days');
    expect(PauseEngine.clock(item(book, 'headphones'), now), '18 hours left');
    expect(PauseEngine.clock(item(book, 'lamp'), now), '2 days left');
    expect(PauseEngine.dong(item(book, 'pack').price), '690,000 VND');
    expect(PauseEngine.dong(item(book, 'headphones').price), '1,290,000 VND');
    final shelf = PauseEngine.shelf(book, now, 0);
    expect(shelf.first.id, 'pack');
    expect(PauseEngine.letGoTotal(book), 0);
  });

  test('book round trip keeps the decision', () {
    final item = DemoSeed.book(now)
        .items
        .firstWhere((e) => e.id == 'headphones')
        .copyWith(
          status: PauseStatus.released,
          decidedAt: now,
        );
    final again = PauseBook.decode(PauseBook(items: [item]).encode());
    expect(again.items.single.status, PauseStatus.released);
    expect(PauseEngine.letGoTotal(again), 1290000);
  });

  test('shared text yields only the url', () {
    expect(
      PauseEngine.extractUrl('xem https://shop.example/bag).'),
      'https://shop.example/bag',
    );
  });
}
