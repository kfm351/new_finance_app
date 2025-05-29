import 'package:flutter/material.dart';
import 'package:personal_finance_helper/models/transaction.dart';
import 'package:personal_finance_helper/services/database.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  late Future<List<Transaction>> _transactions;

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      _transactions = DatabaseHelper().getTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: FutureBuilder<List<Transaction>>(
        future: _transactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('Нет данных о транзакциях'));
          }

          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (ctx, index) {
              final transaction = transactions[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(transaction.type == 'income' ? '+' : '-'),
                  ),
                  title: Text(transaction.category),
                  subtitle:
                      Text(DateFormat('dd.MM.yyyy').format(transaction.date)),
                  trailing: Text(
                    '${transaction.amount.toStringAsFixed(2)} ₽',
                    style: TextStyle(
                      color: transaction.type == 'income'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
