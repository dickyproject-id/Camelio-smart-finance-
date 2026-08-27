import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_finance_app/providers/transaction_provider.dart';
import 'package:smart_finance_app/providers/e_wallet_provider.dart';
import 'package:smart_finance_app/core/constants/app_colors.dart';
import 'package:smart_finance_app/core/locator.dart';
import 'package:smart_finance_app/data/services/gemini_ai_service.dart';
import 'package:smart_finance_app/providers/settings_provider.dart';

enum PortfolioView { weekly, monthly, yearly }

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  PortfolioView _selectedView = PortfolioView.weekly;
  int? _selectedDayIndex; // Index hari yang dipilih di kalender mingguan

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    context.watch<TransactionProvider>();
    context.watch<EWalletProvider>();

    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                settings.translate(
                  'Portofolio Keuangan',
                  'Financial Portfolio',
                ),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                settings.translate(
                  'Analisis pemasukan dan pengeluaran Anda.',
                  'Analysis of your income and expenses.',
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 24),

              // --- TOGGLE VIEW ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTabItem(
                      PortfolioView.weekly,
                      settings.translate('Mingguan', 'Weekly'),
                    ),
                    _buildTabItem(
                      PortfolioView.monthly,
                      settings.translate('Bulanan', 'Monthly'),
                    ),
                    _buildTabItem(
                      PortfolioView.yearly,
                      settings.translate('Tahunan', 'Yearly'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              _buildSummaryCards(context),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getChartTitle(settings),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAIInsight(context),
                    icon: const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      settings.translate('Minta Saran AI', 'Ask AI for Tips'),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildChart(context),
              const SizedBox(height: 32),

              // --- NEW: PIE CHART ---
              Text(
                settings.translate(
                  'Distribusi Pengeluaran',
                  'Expense Distribution',
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              _buildPieChart(context),
              const SizedBox(height: 32),

              // --- NEW: WALLET BALANCE PIE CHART ---
              Text(
                settings.translate(
                  'Distribusi Saldo per Platform',
                  'Balance Distribution per Platform',
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              _buildWalletPieChart(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  String _getChartTitle(SettingsProvider settings) {
    switch (_selectedView) {
      case PortfolioView.weekly:
        return settings.translate('Aktivitas Harian', 'Daily Activity');
      case PortfolioView.monthly:
        return settings.translate('Aktivitas Mingguan', 'Weekly Activity');
      case PortfolioView.yearly:
        return settings.translate('Aktivitas Bulanan', 'Monthly Activity');
    }
  }

  Widget _buildTabItem(PortfolioView view, String label) {
    final isSelected = _selectedView == view;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedView = view;
          _selectedDayIndex = null; // Reset saat pindah tab
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedView) {
      case PortfolioView.weekly:
        // Gunakan DateTime yang di-reset ke 00:00:00 agar transaksi di pagi hari pada hari Senin tetap terhitung
        final todayStart = DateTime(now.year, now.month, now.day);
        startDate = todayStart.subtract(Duration(days: now.weekday - 1));
        break;
      case PortfolioView.monthly:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case PortfolioView.yearly:
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    double income = 0;
    double expense = 0;

    for (var tx in provider.transactions) {
      if (tx.date.isAfter(startDate.subtract(const Duration(seconds: 1)))) {
        bool includeTx = true;

        // Filter spesifik untuk hari yang diklik pada kalender mingguan
        if (_selectedView == PortfolioView.weekly &&
            _selectedDayIndex != null) {
          final targetDay = now.subtract(
            Duration(days: now.weekday - 1 - _selectedDayIndex!),
          );
          if (tx.date.year != targetDay.year ||
              tx.date.month != targetDay.month ||
              tx.date.day != targetDay.day) {
            includeTx = false;
          }
        }

        if (includeTx) {
          if (tx.type == 'income') {
            income += tx.amount;
          } else {
            expense += tx.amount;
          }
        }
      }
    }

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            settings.translate('Pemasukan', 'Income'),
            income,
            Colors.green,
            Icons.arrow_upward,
            context,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            settings.translate('Pengeluaran', 'Expense'),
            expense,
            Colors.red,
            Icons.arrow_downward,
            context,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    String title,
    double amount,
    Color color,
    IconData icon,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${NumberFormat('#,###').format(amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return Column(
      children: [
        if (_selectedView == PortfolioView.weekly) _buildCalendarStrip(),
        if (_selectedView == PortfolioView.weekly) const SizedBox(height: 16),
        _buildChartContent(context),
      ],
    );
  }

  Widget _buildCalendarStrip() {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      return now.subtract(Duration(days: now.weekday - 1 - index));
    });

    final dayNames = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        AppColors.lightTextPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = weekDays[index];

        // Tentukan apakah hari ini dipilih
        bool isSelected = false;
        if (_selectedDayIndex != null) {
          isSelected = index == _selectedDayIndex;
        } else {
          isSelected = date.day == now.day && date.month == now.month;
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDayIndex = index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : Colors.transparent, // Menggunakan AppColors.primary
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  dayNames[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChartContent(BuildContext context) {
    switch (_selectedView) {
      case PortfolioView.weekly:
        return _buildWeeklyChart(context);
      case PortfolioView.monthly:
        return _buildMonthlyChart(context);
      case PortfolioView.yearly:
        return _buildYearlyChart(context);
    }
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      return now.subtract(Duration(days: now.weekday - 1 - index));
    });

    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    for (int i = 0; i < 7; i++) {
      double dayIncome = 0;
      double dayExpense = 0;
      final day = weekDays[i];
      for (var tx in provider.transactions) {
        if (tx.date.year == day.year &&
            tx.date.month == day.month &&
            tx.date.day == day.day) {
          if (tx.type == 'income') {
            dayIncome += tx.amount;
          } else {
            dayExpense += tx.amount;
          }
        }
      }
      incomeSpots.add(FlSpot(i.toDouble(), dayIncome));
      expenseSpots.add(FlSpot(i.toDouble(), dayExpense));
    }
    return _buildChartContainer(incomeSpots, expenseSpots, (value) {
      final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
      return days[value.toInt()];
    });
  }

  Widget _buildMonthlyChart(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    final now = DateTime.now();

    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    for (int i = 0; i < 4; i++) {
      double weekIncome = 0;
      double weekExpense = 0;
      DateTime start = DateTime(now.year, now.month, (i * 7) + 1);
      DateTime end = DateTime(now.year, now.month, (i + 1) * 7);
      if (i == 3) end = DateTime(now.year, now.month + 1, 0);

      for (var tx in provider.transactions) {
        if (tx.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            tx.date.isBefore(end.add(const Duration(seconds: 1)))) {
          if (tx.type == 'income') {
            weekIncome += tx.amount;
          } else {
            weekExpense += tx.amount;
          }
        }
      }
      incomeSpots.add(FlSpot(i.toDouble(), weekIncome));
      expenseSpots.add(FlSpot(i.toDouble(), weekExpense));
    }
    return _buildChartContainer(
      incomeSpots,
      expenseSpots,
      (value) => 'Wk ${value.toInt() + 1}',
    );
  }

  Widget _buildYearlyChart(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    final now = DateTime.now();

    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    for (int i = 0; i < 12; i++) {
      double monthIncome = 0;
      double monthExpense = 0;

      for (var tx in provider.transactions) {
        if (tx.date.year == now.year && tx.date.month == (i + 1)) {
          if (tx.type == 'income') {
            monthIncome += tx.amount;
          } else {
            monthExpense += tx.amount;
          }
        }
      }
      incomeSpots.add(FlSpot(i.toDouble(), monthIncome));
      expenseSpots.add(FlSpot(i.toDouble(), monthExpense));
    }
    return _buildChartContainer(incomeSpots, expenseSpots, (value) {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return months[value.toInt()];
    });
  }

  Widget _buildChartContainer(
    List<FlSpot> incomeSpots,
    List<FlSpot> expenseSpots,
    String Function(double) labelGetter,
  ) {
    final maxY = _calculateMaxY(incomeSpots, expenseSpots);

    // 1. Buat instance LineChartBarData terlebih dahulu agar referensinya sama
    final expenseLineBarData = LineChartBarData(
      spots: expenseSpots,
      isCurved: true,
      color: AppColors.error,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: AppColors.error,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: AppColors.error.withAlpha(38), // 15% opacity
      ),
    );

    final incomeLineBarData = LineChartBarData(
      spots: incomeSpots,
      isCurved: true,
      color: Colors.green,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: Colors.green,
          );
        },
      ),
      belowBarData: BarAreaData(show: true, color: Colors.green.withAlpha(38)),
    );

    // Konfigurasi Tooltip Permanen berdasarkan kalender yang diklik
    List<ShowingTooltipIndicators> showingTooltips = [];
    if (_selectedView == PortfolioView.weekly && _selectedDayIndex != null) {
      if (_selectedDayIndex! < expenseSpots.length) {
        showingTooltips.add(
          ShowingTooltipIndicators([
            LineBarSpot(
              expenseLineBarData, // Harus menggunakan referensi yang sama persis
              0,
              expenseSpots[_selectedDayIndex!],
            ),
          ]),
        );
      }
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          showingTooltipIndicators: showingTooltips,
          maxY: maxY,
          minY: 0,
          lineTouchData: LineTouchData(
            enabled: true,
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  if (event is FlTapUpEvent &&
                      touchResponse != null &&
                      touchResponse.lineBarSpots != null) {
                    if (_selectedView == PortfolioView.weekly) {
                      setState(() {
                        _selectedDayIndex =
                            touchResponse.lineBarSpots!.first.spotIndex;
                      });
                    }
                  }
                },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) =>
                  Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withAlpha(230)
                  : const Color(0xFF0B083A),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    'Rp ${NumberFormat('#,###').format(spot.y)}',
                    TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF0B083A)
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.withAlpha(50), strokeWidth: 1),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.withAlpha(50),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labelGetter(value),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [incomeLineBarData, expenseLineBarData],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    // Hitung data pengeluaran per kategori
    final now = DateTime.now();
    DateTime startDate;
    switch (_selectedView) {
      case PortfolioView.weekly:
        final todayStart = DateTime(now.year, now.month, now.day);
        startDate = todayStart.subtract(Duration(days: now.weekday - 1));
        break;
      case PortfolioView.monthly:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case PortfolioView.yearly:
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    Map<String, double> categoryMap = {};
    double totalExpense = 0;

    for (var tx in provider.transactions) {
      if (tx.type == 'expense' &&
          tx.date.isAfter(startDate.subtract(const Duration(seconds: 1)))) {
        categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
        totalExpense += tx.amount;
      }
    }

    if (totalExpense == 0) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          settings.translate(
            'Belum ada data pengeluaran',
            'No expense data yet',
          ),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    final colors = [
      AppColors.primary,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.blue,
      Colors.amber,
      Colors.teal,
    ];

    int colorIndex = 0;
    List<PieChartSectionData> sections = categoryMap.entries.map((e) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '', // No text inside
        radius: 25, // Thinner ring as in image
        showTitle: false,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: categoryMap.entries.map((e) {
                final index = categoryMap.keys.toList().indexOf(e.key);
                final color = colors[index % colors.length];
                final percentage = (e.value / totalExpense * 100)
                    .toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          settings.translateCategory(e.key),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletPieChart(BuildContext context) {
    final walletProvider = Provider.of<EWalletProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    if (walletProvider.wallets.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          settings.translate('Belum ada data dompet', 'No wallet data yet'),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    double totalBalance = walletProvider.totalBalance;
    if (totalBalance == 0) totalBalance = 1; // Avoid division by zero

    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];

    int colorIndex = 0;
    List<PieChartSectionData> sections = walletProvider.wallets.map((w) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: w.balance <= 0 ? 0.01 : w.balance,
        title: '', // No text inside
        radius: 25, // Thinner ring
        showTitle: false,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: walletProvider.wallets.asMap().entries.map((entry) {
                final index = entry.key;
                final w = entry.value;
                final color = colors[index % colors.length];
                final percentage = (w.balance / totalBalance * 100)
                    .toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          w.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY(List<FlSpot> incomeSpots, List<FlSpot> expenseSpots) {
    double max = 0;
    for (var spot in incomeSpots) {
      if (spot.y > max) max = spot.y;
    }
    for (var spot in expenseSpots) {
      if (spot.y > max) max = spot.y;
    }
    return max == 0 ? 100 : max * 1.2;
  }

  void _showAIInsight(BuildContext context) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final gemini = locator<GeminiAIService>();

    // 1. Hitung Data Ringkasan
    final now = DateTime.now();
    DateTime startDate;
    switch (_selectedView) {
      case PortfolioView.weekly:
        final todayStart = DateTime(now.year, now.month, now.day);
        startDate = todayStart.subtract(Duration(days: now.weekday - 1));
        break;
      case PortfolioView.monthly:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case PortfolioView.yearly:
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    double income = 0;
    double expense = 0;
    Map<String, double> categoryMap = {};

    for (var tx in provider.transactions) {
      if (tx.date.isAfter(startDate.subtract(const Duration(seconds: 1)))) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else {
          expense += tx.amount;
          categoryMap[tx.category] =
              (categoryMap[tx.category] ?? 0) + tx.amount;
        }
      }
    }

    // Ambil top 3 kategori terboros
    var sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    List<String> topCats = sortedCategories
        .take(3)
        .map((e) => settings.translateCategory(e.key))
        .toList();

    // 2. Tampilkan Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              settings.translate(
                'AI sedang menganalisis data Anda...',
                'AI is analyzing your data...',
              ),
            ),
          ],
        ),
      ),
    );

    // 3. Panggil AI
    final insight = await gemini.getPortfolioInsight(
      range: _selectedView.name,
      income: income,
      expense: expense,
      topCategories: topCats.isEmpty
          ? [settings.translate('Belum ada data', 'No data yet')]
          : topCats,
      language: settings.languageCode,
    );

    // 4. Update UI (Tutup loading, buka hasil)
    if (context.mounted) {
      Navigator.pop(context); // Tutup loading

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                settings.translate('Analisis AI', 'AI Analysis'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(insight),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(settings.translate('Terima Kasih', 'Thank You')),
            ),
          ],
        ),
      );
    }
  }
}
