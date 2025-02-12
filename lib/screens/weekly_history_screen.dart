import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import 'daily_history_screen.dart';


// Screen to show weekly expenses for a given month
class WeeklyHistoryScreen extends StatelessWidget {
  final int year;
  final int month;
  const WeeklyHistoryScreen({super.key, required this.year, required this.month});

  Future<List<Map<String, dynamic>>> _fetchWeeklyExpenses() async {
    final db = await DatabaseHelper().database;
    return await db.rawQuery('''
      SELECT strftime('%Y-%W', date) as period,
             MIN(date) as start_date,
             MAX(date) as end_date,
             SUM(amount) as total
      FROM transactions
      WHERE type = 'expense' AND strftime('%Y-%m', date) = ?
      GROUP BY period
      ORDER BY period DESC
    ''', ['$year-${month.toString().padLeft(2, '0')}']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Weekly Expenses - $month/$year'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchWeeklyExpenses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text('No expenses recorded.'));
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              final startDate = DateTime.parse(data['start_date']);
              final endDate = DateTime.parse(data['end_date']);
              final total = data['total'] as double;
              
              return Card(
                color: Colors.grey[900],
                child: ListTile(
                title: Text('${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}',style: TextStyle(color: Colors.white70)),
                trailing: Text('₱${total.toStringAsFixed(2)}', style: TextStyle(color: Colors.greenAccent)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyHistoryScreen(startDate: startDate, endDate: endDate),
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