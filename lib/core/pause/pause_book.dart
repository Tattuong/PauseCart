import 'dart:convert';

enum PauseStatus { waiting, still, released }

class PauseItem {
  final String id;
  final String name;
  final int price;
  final String link;
  final String reason;
  final bool ownsSimilar;
  final int similarCount;
  final DateTime createdAt;
  final DateTime dueAt;
  final bool remind;
  final PauseStatus status;
  final DateTime? decidedAt;
  final int tone;

  const PauseItem({
    required this.id,
    required this.name,
    required this.price,
    required this.link,
    required this.reason,
    required this.ownsSimilar,
    required this.similarCount,
    required this.createdAt,
    required this.dueAt,
    required this.remind,
    required this.status,
    required this.decidedAt,
    required this.tone,
  });

  PauseItem copyWith({
    String? name,
    int? price,
    String? link,
    String? reason,
    bool? ownsSimilar,
    int? similarCount,
    DateTime? createdAt,
    DateTime? dueAt,
    bool? remind,
    PauseStatus? status,
    DateTime? decidedAt,
    bool clearDecision = false,
    int? tone,
  }) =>
      PauseItem(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        link: link ?? this.link,
        reason: reason ?? this.reason,
        ownsSimilar: ownsSimilar ?? this.ownsSimilar,
        similarCount: similarCount ?? this.similarCount,
        createdAt: createdAt ?? this.createdAt,
        dueAt: dueAt ?? this.dueAt,
        remind: remind ?? this.remind,
        status: status ?? this.status,
        decidedAt: clearDecision ? null : (decidedAt ?? this.decidedAt),
        tone: tone ?? this.tone,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'link': link,
        'reason': reason,
        'ownsSimilar': ownsSimilar,
        'similarCount': similarCount,
        'createdAt': createdAt.toIso8601String(),
        'dueAt': dueAt.toIso8601String(),
        'remind': remind,
        'status': status.name,
        'decidedAt': decidedAt?.toIso8601String(),
        'tone': tone,
      };

  factory PauseItem.fromJson(Map<String, dynamic> json) => PauseItem(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        link: json['link'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        ownsSimilar: json['ownsSimilar'] as bool? ?? false,
        similarCount: (json['similarCount'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        dueAt:
            DateTime.tryParse(json['dueAt'] as String? ?? '') ?? DateTime.now(),
        remind: json['remind'] as bool? ?? true,
        status:
            PauseStatus.values.byName(json['status'] as String? ?? 'waiting'),
        decidedAt: json['decidedAt'] == null
            ? null
            : DateTime.tryParse(json['decidedAt'] as String),
        tone: (json['tone'] as num?)?.toInt() ?? 0,
      );
}

class PauseBook {
  final List<PauseItem> items;

  const PauseBook({required this.items});

  String encode() => jsonEncode({
        'items': items.map((item) => item.toJson()).toList(),
      });

  factory PauseBook.decode(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return PauseBook(
      items: [
        for (final item in json['items'] as List? ?? [])
          PauseItem.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
    );
  }
}

class PauseEngine {
  PauseEngine._();

  static const freeWaiting = 8;

  static bool isDue(PauseItem item, DateTime now) =>
      item.status == PauseStatus.waiting && !item.dueAt.isAfter(now);

  static List<PauseItem> waiting(PauseBook book) => [
        for (final item in book.items)
          if (item.status == PauseStatus.waiting) item,
      ];

  static List<PauseItem> due(PauseBook book, DateTime now) => [
        for (final item in waiting(book))
          if (isDue(item, now)) item,
      ];

  static List<PauseItem> pending(PauseBook book, DateTime now) => [
        for (final item in waiting(book))
          if (!isDue(item, now)) item,
      ];

  static List<PauseItem> shelf(PauseBook book, DateTime now, int filter) {
    final items = switch (filter) {
      1 => pending(book, now),
      2 => due(book, now),
      _ => waiting(book),
    };
    final copy = [...items]..sort((a, b) {
        final aDue = isDue(a, now);
        final bDue = isDue(b, now);
        if (aDue != bDue) return aDue ? -1 : 1;
        return a.dueAt.compareTo(b.dueAt);
      });
    return copy;
  }

  static List<PauseItem> decided(PauseBook book, PauseStatus status) {
    final items = [
      for (final item in book.items)
        if (item.status == status) item,
    ]..sort(
        (a, b) => (b.decidedAt ?? b.dueAt).compareTo(a.decidedAt ?? a.dueAt));
    return items;
  }

  static int letGoTotal(PauseBook book) {
    var sum = 0;
    for (final item in book.items) {
      if (item.status == PauseStatus.released) sum += item.price;
    }
    return sum;
  }

  static double progress(PauseItem item, DateTime now) {
    final total = item.dueAt.difference(item.createdAt).inSeconds;
    if (total <= 0) return 1;
    final elapsed = now.difference(item.createdAt).inSeconds;
    return (elapsed / total).clamp(0, 1).toDouble();
  }

  static String clock(PauseItem item, DateTime now) {
    if (isDue(item, now)) {
      final days = now.difference(item.createdAt).inDays;
      if (days <= 0) return 'Due now';
      return days == 1 ? 'Waited 1 day' : 'Waited $days days';
    }
    final left = item.dueAt.difference(now);
    if (left.inMinutes < 60) return 'Under 1 hour left';
    if (left.inHours < 48) {
      final hours = left.inHours;
      return hours == 1 ? '1 hour left' : '$hours hours left';
    }
    final days = left.inDays;
    return days == 1 ? '1 day left' : '$days days left';
  }

  static String dong(int value) {
    final digits = value.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return '$buf VND';
  }

  static int parsePrice(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  static String? extractUrl(String raw) {
    final match = RegExp(r'https?://\S+', caseSensitive: false).firstMatch(raw);
    if (match == null) return null;
    return match.group(0)!.replaceAll(RegExp(r'[),.;]+$'), '');
  }
}
