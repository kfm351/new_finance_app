import 'package:flutter/material.dart';
import 'package:personal_finance_helper/widgets/transaction_list.dart';
import 'package:personal_finance_helper/widgets/calendar_widget.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Финансовый Помощник'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/stats'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // <-- Обёрнуто в Expanded, как вы просили
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CalendarWidget(),
                  TransactionList(), // Ваш виджет списка транзакций
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/add'),
      ),
    );
  }
}
