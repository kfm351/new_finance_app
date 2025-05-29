import 'package:flutter/material.dart';
import 'package:personal_finance_helper/models/transaction.dart';
import 'package:personal_finance_helper/widgets/chart_widget.dart';
import 'package:personal_finance_helper/services/database.dart';

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Статистика')),
      body: FutureBuilder<List<Transaction>>(
        future: DatabaseHelper().getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('Нет данных для отображения'));
          }

          final transactions = snapshot.data!;
          final totalIncome = transactions
              .where((t) => t.type == 'income')
              .fold(0.0, (sum, t) => sum + t.amount);
          final totalExpense = transactions
              .where((t) => t.type == 'expense')
              .fold(0.0, (sum, t) => sum + t.amount);
          final balance = totalIncome - totalExpense;

          return SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Общая статистика',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard('Доходы', totalIncome, Colors.green),
                            _buildStatCard('Расходы', totalExpense, Colors.red),
                            _buildStatCard('Баланс', balance,
                                balance >= 0 ? Colors.blue : Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ChartWidget(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} ₽',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
