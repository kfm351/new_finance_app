import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:personal_finance_helper/models/transaction.dart';
import 'package:personal_finance_helper/services/database.dart';
import 'package:provider/provider.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late final ValueNotifier<List<Transaction>> _selectedTransactions;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedTransactions = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedTransactions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: Provider.of<DatabaseHelper>(context).getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data ?? [];
        final dailyIncome = _calculateDailyIncome(transactions);

        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectedTransactions.value = transactions
                    .where((t) => isSameDay(t.date, selectedDay))
                    .toList();
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final income = dailyIncome[date] ?? 0;
                  return income > 0
                      ? Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.green[200],
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              income.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        )
                      : null;
                },
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<List<Transaction>>(
              valueListenable: _selectedTransactions,
              builder: (context, transactions, _) {
                return Column(
                  children: [
                    Text(
                      'Доход за ${_selectedDay?.toString() ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...transactions.map((t) => ListTile(
                          title: Text(t.category),
                          trailing: Text('+${t.amount.toStringAsFixed(2)} ₽'),
                          subtitle: Text(t.notes ?? ''),
                        )),
                    ElevatedButton(
                      onPressed: () => _addTransaction(context, _selectedDay!),
                      child: const Text('Добавить доход'),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Map<DateTime, double> _calculateDailyIncome(List<Transaction> transactions) {
    final Map<DateTime, double> result = {};
    for (final t in transactions.where((t) => t.type == 'income')) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      result.update(date, (value) => value + t.amount,
          ifAbsent: () => t.amount);
    }
    return result;
  }

  Future<void> _addTransaction(BuildContext context, DateTime date) async {
    // Реализуем диалог добавления транзакции
    final amountController = TextEditingController();
    final categoryController = TextEditingController(text: 'Уроки');
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить доход'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Сумма'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Категория'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Заметки'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final transaction = Transaction(
                type: 'income',
                amount: double.parse(amountController.text),
                category: categoryController.text,
                date: date,
                notes: notesController.text.isNotEmpty
                    ? notesController.text
                    : null,
              );
              await Provider.of<DatabaseHelper>(context, listen: false)
                  .insertTransaction(transaction);
              Navigator.pop(context);
              setState(() {}); // Обновляем UI
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
