import 'package:flutter/material.dart';
import 'package:personal_finance_helper/models/transaction.dart';
import 'package:personal_finance_helper/models/category.dart';
import 'package:personal_finance_helper/services/database.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'income';
  String _category = '';
  DateTime _date = DateTime.now();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _categories = Category.defaultCategories();
    _category = _categories.firstWhere((c) => c.type == 'income').name;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = Transaction(
      type: _type,
      amount: double.parse(_amountController.text),
      category: _category,
      date: _date,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      await DatabaseHelper().insertTransaction(transaction);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Добавить операцию')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: ['income', 'expense'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == 'income' ? 'Доход' : 'Расход'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                    _category =
                        _categories.firstWhere((c) => c.type == _type).name;
                  });
                },
                decoration: InputDecoration(labelText: 'Тип операции'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items:
                    _categories.where((c) => c.type == _type).map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Text('${category.icon} ${category.name}'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: InputDecoration(labelText: 'Категория'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Сумма',
                  prefixText: '₽ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите сумму';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Дата'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd.MM.yyyy').format(_date)),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration:
                    InputDecoration(labelText: 'Заметки (необязательно)'),
                maxLines: 2,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Сохранить'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
