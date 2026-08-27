import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/e_wallet_provider.dart';
import '../../../core/constants/app_colors.dart';

class PdfGenerator {
  /// Fungsi utama untuk membuat PDF dan menampilkannya dalam pratinjau cetak/bagikan.
  /// Fungsi utama untuk membuat PDF dan menampilkannya dalam pratinjau cetak/bagikan.
  static Future<void> generateAndShare(
    BuildContext context, {
    required SettingsProvider settings,
    required TransactionProvider transProvider,
    required EWalletProvider walletProvider,
    required Widget chartWidget,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Default range jika tidak ditentukan (7 hari terakhir)
    final start = startDate ?? now.subtract(const Duration(days: 6));
    final end = endDate ?? now;

    final dateRangeStr =
        '${DateFormat('dd/MM/yyyy').format(start)} - ${DateFormat('dd/MM/yyyy').format(end)}';
    final fileName =
        'Laporan_Camelio_${DateFormat('yyyyMMdd').format(start)}_${DateFormat('yyyyMMdd').format(end)}';

    // Filter transaksi sesuai range
    final filteredTransactions = transProvider.transactions.where((t) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      return tDate.isAfter(start.subtract(const Duration(days: 1))) &&
          tDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    // Hitung total dari data terfilter
    double totalIncome = 0;
    double totalExpense = 0;
    for (var t in filteredTransactions) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    try {
      // 1. Capture Grafik sebagai Gambar
      final screenshotController = ScreenshotController();
      final Uint8List chartBytes = await screenshotController.captureFromWidget(
        Container(
          width: 600,
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: chartWidget,
        ),
        context: context,
        delay: const Duration(milliseconds: 300),
      );

      final pw.MemoryImage chartImage = pw.MemoryImage(chartBytes);

      // 2. Membangun Struktur Halaman PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              'Camelio Finance - ${context.pageNumber}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ),
          build: (pw.Context context) {
            return [
              // Header Laporan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CAMELIO FINANCE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        settings.translate(
                          'Laporan Transaksi Kustom',
                          'Custom Transaction Report',
                        ),
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        dateRangeStr,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        settings.translate('Dicetak pada: ', 'Printed on: ') +
                            DateFormat('dd/MM/yyyy HH:mm').format(now),
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 20),

              // Summary Cards
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryBox(
                    settings.translate(
                      'Total Saldo Saat Ini',
                      'Current Total Balance',
                    ),
                    walletProvider.totalBalance,
                    PdfColors.blue800,
                  ),
                  _buildSummaryBox(
                    settings.translate(
                      'Total Pemasukan (Range)',
                      'Total Income (Range)',
                    ),
                    totalIncome,
                    PdfColors.green800,
                  ),
                  _buildSummaryBox(
                    settings.translate(
                      'Total Pengeluaran (Range)',
                      'Total Expense (Range)',
                    ),
                    totalExpense,
                    PdfColors.red800,
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Grafik
              pw.Text(
                settings.translate(
                  'Visualisasi Aktivitas',
                  'Activity Visualization',
                ),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey100),
                  ),
                  child: pw.Image(chartImage, width: 450),
                ),
              ),
              pw.SizedBox(height: 24),

              // AI Insight
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 6,
                          height: 6,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.blue900,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          settings.translate(
                            'Saran Keuangan AI',
                            'AI Financial Advice',
                          ),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      _generateAIAdvice(settings, totalIncome, totalExpense),
                      style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Wallet List
              pw.Text(
                settings.translate('Aset & Dompet', 'Assets & Wallets'),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: [
                  settings.translate('Nama', 'Name'),
                  settings.translate('Tipe', 'Type'),
                  settings.translate('Saldo', 'Balance'),
                ],
                data: walletProvider.wallets
                    .map(
                      (w) => [
                        w.name,
                        w.type.toUpperCase(),
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        ).format(w.balance),
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue900,
                ),
                cellHeight: 25,
                cellStyle: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 24),

              // Transaction Detail
              pw.Text(
                settings.translate('Detail Transaksi', 'Transaction Details'),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: [
                  settings.translate('Tanggal', 'Date'),
                  settings.translate('Keterangan', 'Description'),
                  settings.translate('Kategori', 'Category'),
                  settings.translate('Jumlah', 'Amount'),
                ],
                data: filteredTransactions.isEmpty
                    ? [
                        [
                          settings.translate(
                            'Tidak ada data pada periode ini',
                            'No data for this period',
                          ),
                          '-',
                          '-',
                          '-',
                        ],
                      ]
                    : filteredTransactions
                          .map(
                            (t) => [
                              DateFormat('dd/MM/yy').format(t.date),
                              t.description,
                              settings.translateCategory(t.category),
                              '${t.type == 'expense' ? '-' : '+'}${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(t.amount)}',
                            ],
                          )
                          .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 9,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue900,
                ),
                cellHeight: 20,
                cellStyle: const pw.TextStyle(fontSize: 8),
                columnWidths: {
                  0: const pw.FixedColumnWidth(45),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(60),
                  3: const pw.FixedColumnWidth(80),
                },
              ),

              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 30),
                child: pw.Center(
                  child: pw.Text(
                    'Laporan ini dihasilkan secara otomatis oleh Camelio Finance',
                    style: const pw.TextStyle(
                      fontSize: 7,
                      color: PdfColors.grey400,
                    ),
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // 3. Share
      final Uint8List pdfBytes = await pdf.save();
      await Printing.sharePdf(bytes: pdfBytes, filename: '$fileName.pdf');
    } catch (e) {
      debugPrint('PDF_EXPORT_ERROR: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $e')));
      }
    }
  }

  static String _generateAIAdvice(
    SettingsProvider settings,
    double income,
    double expense,
  ) {
    if (income == 0 && expense == 0) {
      return settings.translate(
        'Belum ada data transaksi untuk dianalisis.',
        'No transaction data to analyze.',
      );
    }
    final ratio = income > 0 ? (expense / income) * 100 : 100.0;
    if (ratio > 80) {
      return settings.translate(
        'Peringatan: Pengeluaran Anda mencapai ${ratio.toStringAsFixed(1)}% dari pemasukan. Disarankan untuk membatasi pengeluaran non-prioritas segera.',
        'Warning: Your expenses reached ${ratio.toStringAsFixed(1)}% of income. It is recommended to limit non-priority spending immediately.',
      );
    } else if (ratio < 30) {
      return settings.translate(
        'Luar biasa! Rasio pengeluaran Anda sangat rendah (${ratio.toStringAsFixed(1)}%). Pertimbangkan untuk menginvestasikan kelebihan dana Anda.',
        'Excellent! Your expense ratio is very low (${ratio.toStringAsFixed(1)}%). Consider investing your surplus funds.',
      );
    } else {
      return settings.translate(
        'Kondisi keuangan Anda dalam rentang aman. Pastikan untuk tetap mencatat setiap transaksi agar anggaran tetap terkontrol.',
        'Your financial condition is within a safe range. Make sure to keep recording every transaction to keep your budget under control.',
      );
    }
  }

  /// Membangun kotak ringkasan untuk PDF
  static pw.Widget _buildSummaryBox(
    String label,
    double amount,
    PdfColor color,
  ) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return pw.Container(
      width: 155,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            format.format(amount),
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun widget grafik fl_chart untuk dikonversi menjadi gambar PDF
  static Widget buildExportChart(
    BuildContext context,
    TransactionProvider provider, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    final start = startDate ?? now.subtract(const Duration(days: 6));
    final end = endDate ?? now;

    // Hitung selisih hari
    final diffDays = end.difference(start).inDays + 1;
    final int points = diffDays > 7
        ? 7
        : diffDays; // Batasi 7 titik untuk kejelasan visual di PDF

    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    double maxAmount = 100000;

    for (int i = 0; i < points; i++) {
      double dayIncome = 0;
      double dayExpense = 0;

      // Bagi range menjadi 'points' bagian
      final checkDate = start.add(
        Duration(days: (diffDays / points * i).floor()),
      );

      for (var tx in provider.transactions) {
        if (tx.date.year == checkDate.year &&
            tx.date.month == checkDate.month &&
            tx.date.day == checkDate.day) {
          if (tx.type == 'income') {
            dayIncome += tx.amount;
          } else {
            dayExpense += tx.amount;
          }
        }
      }
      incomeSpots.add(FlSpot(i.toDouble(), dayIncome));
      expenseSpots.add(FlSpot(i.toDouble(), dayExpense));
      if (dayIncome > maxAmount) maxAmount = dayIncome;
      if (dayExpense > maxAmount) maxAmount = dayExpense;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx < 0 || idx >= points) return const SizedBox();
                  final date = start.add(
                    Duration(days: (diffDays / points * idx).floor()),
                  );
                  return Text(
                    DateFormat('dd/MM').format(date),
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (points - 1).toDouble(),
          minY: 0,
          maxY: maxAmount * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: Colors.green,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withValues(alpha: 0.1),
              ),
            ),
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: AppColors.error,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.error.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
