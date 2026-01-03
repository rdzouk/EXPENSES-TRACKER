import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  final VoidCallback onRefresh;

  const StatisticsScreen({super.key, required this.onRefresh});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, double> categoryData = {};
  double totalExpenses = 0;
  final formatCurrency = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA ', decimalDigits: 0);

  // Predefined colors for the pie chart sections
  final List<Color> pieColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final transactions = await DatabaseHelper.instance.getAllTransactions(); // Matches previous DatabaseHelper naming
    
    final now = DateTime.now();
    final currentMonthTransactions = transactions.where((t) =>
        t.type == 'expense' &&
        t.date.year == now.year &&
        t.date.month == now.month
    ).toList();

    Map<String, double> data = {};
    double total = 0;

    for (var transaction in currentMonthTransactions) {
      data[transaction.category] = (data[transaction.category] ?? 0) + transaction.amount;
      total += transaction.amount;
    }

    if (mounted) {
      setState(() {
        categoryData = data;
        totalExpenses = total;
      });
    }
  }

  // --- COMPLETED METHOD: PIE CHART SECTIONS ---
  List<PieChartSectionData> _buildPieChartSections() {
    int index = 0;
    return categoryData.entries.map((entry) {
      final isLast = index >= pieColors.length;
      final color = isLast ? Colors.grey : pieColors[index % pieColors.length];
      index++;

      final percentage = totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // --- COMPLETED METHOD: LEGEND ITEM ---
  Widget _buildLegendItem(String category, double amount) {
    int catIndex = categoryData.keys.toList().indexOf(category);
    Color iconColor = pieColors[catIndex % pieColors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          formatCurrency.format(amount),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadStatistics();
          widget.onRefresh();
        },
        child: categoryData.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No expense data', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text('Add expenses to see statistics', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Month indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(DateFormat('MMMM yyyy').format(DateTime.now()), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Total Expenses Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.red[700]!, Colors.red[500]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('Total Expenses This Month', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(formatCurrency.format(totalExpenses), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Pie Chart
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Breakdown by Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  // FIXED: Spreading the mapped list into children
                  ...categoryData.entries.map((entry) => _buildLegendItem(entry.key, entry.value)),
                ],
              ),
      ),
    );
  }
}