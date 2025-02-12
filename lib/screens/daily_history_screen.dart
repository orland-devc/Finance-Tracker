import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import 'transactions_screen.dart';


// Screen to show daily expenses for a given week
class DailyHistoryScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  const DailyHistoryScreen({super.key, required this.startDate, required this.endDate});

  Future<List<Transaction>> _fetchTransactionsByDate() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
        title: Text('Transactions on ${DateFormat('MMM d, yyyy').format(startDate)}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
    ),
    body: FutureBuilder<List<Transaction>>(
        future: _fetchTransactionsByDate(),
        builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.data!.isEmpty) return const Center(child: Text('No transactions found.'));
            
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                    final transaction = snapshot.data![index];

                    return Card(
                        color: Colors.grey[900],
                        child: ListTile(
                            title: Text(transaction.description, style: TextStyle(color: Colors.white)),
                            subtitle: Text(DateFormat('MMM d, yyyy h:mm a').format(transaction.date), style: TextStyle(color: Colors.white70)),
                            trailing: Text('₱${transaction.amount.toStringAsFixed(2)}', style: TextStyle(color: Colors.greenAccent)),
                        ),
                    );
                },
            );
        },
    ),
);

  }
}
