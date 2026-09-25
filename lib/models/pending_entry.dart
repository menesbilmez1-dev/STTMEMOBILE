import 'package:hive/hive.dart';

part 'pending_entry.g.dart';

@HiveType(typeId: 0)
class PendingEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  String type;

  @HiveField(3)
  String value;

  @HiveField(4)
  DateTime timestamp;

  PendingEntry({
    required this.id,
    required this.category,
    required this.type,
    required this.value,
    required this.timestamp,
  });
}