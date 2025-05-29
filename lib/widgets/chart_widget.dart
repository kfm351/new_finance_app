import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:personal_finance_helper/models/transaction.dart';
import 'package:personal_finance_helper/services/database.dart';

class ChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: DatabaseHelper().getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Нет данных для графика'));
        }

        final transactions = snapshot.data!;

        // Группируем данные для графика
        final incomeData = _prepareChartData(transactions, 'income');
        final expenseData = _prepareChartData(transactions, 'expense');

        return Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  'Финансовая статистика',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries>[
                      // Изменено на CartesianSeries
                      ColumnSeries<ChartData, String>(
                        dataSource: incomeData,
                        xValueMapper: (ChartData data, _) => data.category,
                        yValueMapper: (ChartData data, _) => data.amount,
                        name: 'Доходы',
                        color: Colors.green,
                      ),
                      ColumnSeries<ChartData, String>(
                        dataSource: expenseData,
                        xValueMapper: (ChartData data, _) => data.category,
                        yValueMapper: (ChartData data, _) => data.amount,
                        name: 'Расходы',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ChartData> _prepareChartData(
      List<Transaction> transactions, String type) {
    final filtered = transactions.where((t) => t.type == type).toList();
    final Map<String, double> categorySums = {};

    for (var t in filtered) {
      categorySums.update(
        t.category,
        (value) => value + t.amount,
        ifAbsent: () => t.amount,
      );
    }

    return categorySums.entries.map((e) => ChartData(e.key, e.value)).toList();
  }
}

// Добавьте этот класс в тот же файл или в models/chart_data.dart
class ChartData {
  final String category;
  final double amount;

  ChartData(this.category, this.amount);
}
