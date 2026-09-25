import 'package:hive/hive.dart';

part 'app_config.g.dart';

@HiveType(typeId: 1)
class AppConfig extends HiveObject {
  @HiveField(0)
  List<CategoryConfig> categories;

  AppConfig({required this.categories});
}

@HiveType(typeId: 2)
class CategoryConfig extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<String> types;

  CategoryConfig({required this.name, required this.types});
}
