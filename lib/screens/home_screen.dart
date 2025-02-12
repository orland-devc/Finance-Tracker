import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';
import 'statistics_screen.dart';
import 'history_screen.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<Transaction>> _todayTransactions;
  late Future<double> _todayExpenses;
  late Future<double> _todayIncome;
  late Future<double> _totalBalance;
  
  final ScrollController _scrollController = ScrollController();
  double _animationValue = 0.0;
  final double _scrollThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final animationValue = (offset / _scrollThreshold).clamp(0.0, 1.0);
    if (animationValue != _animationValue) {
      setState(() {
        _animationValue = animationValue;
      });
    }
  }

  void _refreshData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    setState(() {
      _todayTransactions = _databaseHelper.getTransactionsByPeriod(today, tomorrow);
      _todayExpenses = _databaseHelper.getTodayTotal('expense');
      _todayIncome = _databaseHelper.getTodayTotal('income');
      _totalBalance = _databaseHelper.getTotalBalance();
    });
  }

  Widget _buildBalanceCard(double height, double fontSize, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FutureBuilder<double>(
            future: _totalBalance,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  '₱${snapshot.data!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    Future<double> future,
    Color color,
    IconData icon,
    double height,
    double fontSize,
    double padding,
  ) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<double>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  '₱${snapshot.data!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }
              return const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBalanceCard(double height, double fontSize, double padding) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 160,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Balance',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FutureBuilder<double>(
            future: _totalBalance,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  '₱${snapshot.data!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSummaryCard(
    String title,
    Future<double> future,
    Color color,
    IconData icon,
    double height,
    double fontSize,
    double padding,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 140,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FutureBuilder<double>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  '₱${snapshot.data!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 150 - (60 * _animationValue);
    final double cardPadding = 20 - (2 * _animationValue);
    // final EdgeInsets cardPadding = EdgeInsets.fromLTRB(
    //   20 - (2 * _animationValue), // left
    //   6 - (2 * _animationValue),  // top
    //   20 - (2 * _animationValue), // right
    //   6 - (2 * _animationValue),  // bottom
    // );
    final double fontSize = 24 - (8 * _animationValue);
    final double cardSpacing = 12 - (8 * _animationValue);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            toolbarHeight: _animationValue > 0 ? 100 : 60,
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Today\'s Overview',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(_animationValue > 0.5 ? 80 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _animationValue > 0.5 ? 80 : 0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: [
                      SizedBox(width: cardPadding),
                      _buildAnimatedBalanceCard(cardHeight, fontSize, cardPadding),
                      SizedBox(width: cardSpacing),
                      _buildAnimatedSummaryCard(
                        'Income',
                        _todayIncome,
                        const Color(0xFF2196F3),
                        Icons.arrow_upward,
                        cardHeight,
                        fontSize,
                        cardPadding,
                      ),
                      SizedBox(width: cardSpacing),
                      _buildAnimatedSummaryCard(
                        'Expenses',
                        _todayExpenses,
                        const Color(0xFF009688),
                        Icons.arrow_downward,
                        cardHeight,
                        fontSize,
                        cardPadding,
                      ),
                      SizedBox(width: cardPadding),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: _animationValue > 0.5 ? 0 : 300,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24 * (1 - _animationValue),
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildBalanceCard(cardHeight, fontSize, cardPadding),
                      SizedBox(height: cardSpacing),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Income',
                              _todayIncome,
                              const Color(0xFF2196F3),
                              Icons.arrow_upward,
                              cardHeight,
                              fontSize,
                              cardPadding,
                            ),
                          ),
                          SizedBox(width: cardSpacing),
                          Expanded(
                            child: _buildSummaryCard(
                              'Expenses',
                              _todayExpenses,
                              const Color(0xFF009688),
                              Icons.arrow_downward,
                              cardHeight,
                              fontSize,
                              cardPadding,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryScreen()),
                    ),
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF00BCD4)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: FutureBuilder<List<Transaction>>(
              future: _todayTransactions,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions today',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final transaction = snapshot.data![index];
                      return TransactionCard(
                        transaction: transaction,
                        onDelete: () async {
                          _refreshData();
                        },
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF81C784)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(type: 'income'),
                ),
              );
              _refreshData();
            },
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            heroTag: 'income',
            elevation: 4,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(type: 'expense'),
                ),
              );
              _refreshData();
            },
            backgroundColor: const Color(0xFF00BCD4),
            foregroundColor: Colors.white,
            heroTag: 'expense',
            elevation: 4,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}