import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import 'weekly_history_screen.dart';
import 'daily_history_screen.dart';


// Screen to show monthly expenses for a given year
class MonthlyHistoryScreen extends StatelessWidget {
  final int year;
  const MonthlyHistoryScreen({super.key, required this.year});

  Future<List<Map<String, dynamic>>> _fetchMonthlyExpenses() async {
    final db = await DatabaseHelper().database;
    return await db.rawQuery('''
      SELECT strftime('%Y-%m', date) as period,
             SUM(amount) as total
      FROM transactions
      WHERE type = 'expense' AND strftime('%Y', date) = ?
      GROUP BY period
      ORDER BY period DESC
    ''', [year.toString()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Expenses in $year'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMonthlyExpenses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text('No expenses recorded.'));
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              final month = DateFormat('MMMM yyyy').format(DateTime.parse('${data['period']}-01'));
              final total = data['total'] as double;
              
              return Card(
                color: Colors.grey[900],
                child: ListTile(
                title: Text(month, style: TextStyle(color: Colors.white70)),
                trailing: Text('₱${total.toStringAsFixed(2)}', style: TextStyle(color: Colors.greenAccent)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeeklyHistoryScreen(year: year, month: int.parse(data['period'].split('-')[1])),
                    ),
                  );
                },
              )
              );
            },
          );
        },
      ),
    );
  }
}