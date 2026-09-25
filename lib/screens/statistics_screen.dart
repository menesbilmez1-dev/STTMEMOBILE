import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../l10n/app_localizations.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<EntryProvider>();
    final categoryCounts = entryProvider.categoryCounts;
    final dailyCounts = entryProvider.dailyCounts;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statisticsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.categoryDistributionTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: categoryCounts.isEmpty
                  ? Center(child: Text(l10n.noDataFound))
                  : PieChart(
                      PieChartData(
                        sections: categoryCounts.entries.map((entry) {
                          return PieChartSectionData(
                            color: _getColorForCategory(entry.key),
                            value: entry.value.toDouble(),
                            title: '${entry.key}\n${entry.value}',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.dailyRecordCountTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: dailyCounts.isEmpty
                  ? Center(child: Text(l10n.noDataFound))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (dailyCounts.values.reduce((a, b) => a > b ? a : b).toDouble() + 1),
                        barGroups: dailyCounts.entries.map((entry) {
                          // Extracting day from the key "YYYY-MM-DD"
                          final day = entry.key.split('-').last;
                          return BarChartGroupData(
                            x: int.parse(day),
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                color: Colors.blueAccent,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString());
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.totalRecords),
                trailing: Text(
                  '${entryProvider.entries.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.amber,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    final index = category.hashCode % colors.length;
    return colors[index];
  }
}
