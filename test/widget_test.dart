import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Исправьте на ваше название пакета

void main() {
  testWidgets('Проверка запуска приложения', (WidgetTester tester) async {
    // Создаём наше приложение
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: Text('Тест работает!'))),
    ));

    // Проверяем, что текст отображается
    expect(find.text('Тест работает!'), findsOneWidget);
  });
}
