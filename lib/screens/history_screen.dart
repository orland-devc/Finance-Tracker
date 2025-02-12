import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import 'monthly_history_screen.dart';
import 'weekly_history_screen.dart';
import 'daily_history_screen.dart';
import 'transactions_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String _selectedPeriod = 'Daily';
  late DateTime _startDate;
  late DateTime _endDate;

  // Define gradients matching the transaction card
  final gradient = const LinearGradient(
    colors: [Color(0xFF009688), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  @override
  void initState() {
    super.initState();
    _updateDateRange();
  }

  void _updateDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Daily':
        _startDate = now.subtract(const Duration(days: 30));
        _endDate = now;
        break;
      case 'Weekly':
        _startDate = now.subtract(const Duration(days: 90));
        _endDate = now;
        break;
      case 'Monthly':
        _startDate = DateTime(now.year - 1, now.month, 1);
        _endDate = now;
        break;
      case 'Yearly':
        _startDate = DateTime(now.year - 5, 1, 1);
        _endDate = now;
        break;
    }
  }

  String _formatDateRange(DateTime start, DateTime end, String period) {
    final now = DateTime.now();
    
    switch (period) {
      case 'Daily':
        if (start.year == now.year &&
            start.month == now.month &&
            start.day == now.day) {
          return 'Today';
        } else if (start.year == now.year &&
            start.month == now.month &&
            start.day == now.day - 1) {
          return 'Yesterday';
        }
        return '${DateFormat('MMM d').format(start)}';
        
      case 'Weekly':
        String endText;
        if (end.year == now.year &&
            end.month == now.month &&
            end.day == now.day) {
          endText = 'Today';
        } else {
          endText = DateFormat('d').format(end);
        }
        
        return '${DateFormat('MMM d').format(start)} - $endText';
        
      case 'Monthly':
        if (start.year == now.year && start.month == now.month) {
          return 'This month (${DateFormat('MMM').format(start)})';
        }
        return DateFormat('MMM yyyy').format(start);
        
      case 'Yearly':
        if (start.year == now.year) {
          return 'This year (${start.year})';
        }
        return start.year.toString();
        
      default:
        return '';
    }
  }

  Future<List<Map<String, dynamic>>> _getGroupedExpenses() async {
    final db = await _databaseHelper.database;
    String groupBy;
    String dateFormat;

    switch (_selectedPeriod) {
      case 'Daily':
        groupBy = 'date(date)';
        dateFormat = '%Y-%m-%d';
        break;
      case 'Weekly':
        groupBy = "strftime('%Y-%W', date)";
        dateFormat = '%Y-%W';
        break;
      case 'Monthly':
        groupBy = "strftime('%Y-%m', date)";
        dateFormat = '%Y-%m';
        break;
      case 'Yearly':
        groupBy = "strftime('%Y', date)";
        dateFormat = '%Y';
        break;
      default:
        return [];
    }

    return await db.rawQuery('''
      SELECT 
        $groupBy as period,
        MIN(date) as start_date,
        MAX(date) as end_date,
        SUM(amount) as total
      FROM transactions
      WHERE type = 'expense'
        AND date BETWEEN ? AND ?
      GROUP BY $groupBy
      ORDER BY period DESC
    ''', [_startDate.toIso8601String(), _endDate.toIso8601String()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: const Text(
            'Expense History',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Set back icon color to white
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Daily', 
                        label: Text(
                          'Daily',
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: null, // Remove default icon
                      ),
                      ButtonSegment(
                        value: 'Weekly',
                        label: Text(
                          'Weekly',
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: null,
                      ),
                      ButtonSegment(
                        value: 'Monthly',
                        label: Text(
                          'Monthly',
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: null,
                      ),
                      ButtonSegment(
                        value: 'Yearly',
                        label: Text(
                          'Yearly',
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: null,
                      ),
                    ],
                    selected: {_selectedPeriod},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _selectedPeriod = selection.first;
                        _updateDateRange();
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (states) {
                          if (states.contains(MaterialState.selected)) {
                            return const Color(0xFF009688);
                          }
                          return Colors.grey[800];
                        },
                      ),
                      // Remove the default check icon
                      iconSize: MaterialStateProperty.all(0),
                      // Ensure text is white in both selected and unselected states
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      // Optional: adjust padding since we removed the icon
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    showSelectedIcon: false, // This will hide the check icon
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getGroupedExpenses(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No expenses for selected period',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index];
                      final startDate = DateTime.parse(data['start_date']);
                      final endDate = DateTime.parse(data['end_date']);
                      final total = data['total'] as double;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: const Color(0xFF009688).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        color: Colors.grey[900],
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: gradient,
                            ),
                            child: const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          title: ShaderMask(
                            shaderCallback: (bounds) => gradient.createShader(bounds),
                            child: Text(
                              _formatDateRange(startDate, endDate, _selectedPeriod),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          trailing: ShaderMask(
                            shaderCallback: (bounds) => gradient.createShader(bounds),
                            child: Text(
                              '₱${NumberFormat('#,##0.00').format(total)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onTap: () {
                            if (_selectedPeriod == 'Yearly') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MonthlyHistoryScreen(year: startDate.year),
                                ),
                              );
                            } else if (_selectedPeriod == 'Monthly') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WeeklyHistoryScreen(year: startDate.year, month: startDate.month),
                                ),
                              );
                            } else if (_selectedPeriod == 'Weekly') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DailyHistoryScreen(startDate: startDate, endDate: endDate),
                                ),
                              );
                            } else if (_selectedPeriod == 'Daily') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionsScreen(date: startDate),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF009688)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}