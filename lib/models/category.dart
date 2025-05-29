class Category {
  final int? id;
  final String name;
  final String type; // 'income' или 'expense'
  final String icon;

  Category({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
    );
  }

  static List<Category> defaultCategories() {
    return [
      Category(name: 'Уроки', type: 'income', icon: '📚'),
      Category(name: 'Ремонт', type: 'income', icon: '🔧'),
      Category(name: 'Продукты', type: 'expense', icon: '🛒'),
      Category(name: 'Транспорт', type: 'expense', icon: '🚗'),
      Category(name: 'Аренда', type: 'expense', icon: '🏠'),
    ];
  }
}
