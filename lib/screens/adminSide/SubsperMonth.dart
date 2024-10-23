import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import '../../services/Database_Service.dart'; // Update with your package name

class SubscriptionChart extends StatefulWidget {
  const SubscriptionChart({super.key});

  @override
  State<SubscriptionChart> createState() => _SubscriptionChartState();
}

class _SubscriptionChartState extends State<SubscriptionChart> {
  List<String> months = [];
  List<List<int>> subsCount = [];
  bool isLoading = true;

  @override
  void initState() {
    getMonthsAndSubs().then((value) {
      setState(() {
        months = value;
        isLoading = false;
      });
    });
    super.initState();
  }

  Future<List<String>> getMonthsAndSubs() async {
    DateTime now = DateTime.now();

    List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    for (int i = 1; i <= now.month; i++) {
      months.add(monthNames[i - 1]);
      Map<String, int> counts =
          await Database_Service.fetchSubscriptionCounts(i, now.year);
      print('STANDARD: ${counts["standard"]!}');
      print('PREMIUM: ${counts["premium"]!}');
      subsCount.add([counts['premium']!, counts['standard']!]);
    }

    print('Subscription counts: $subsCount'); // For debugging purposes

    return months;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Subscription Chart',
        style: GoogleFonts.poppins(),
      )),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.appNeon,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                swapAnimationCurve: Curves.linear,
                swapAnimationDuration: Duration(milliseconds: 3000),
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _createBarGroups(),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, axis) {
                          if (value % 1 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: GoogleFonts.poppins(
                                color: const Color.fromARGB(255, 255, 253, 253),
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                              ),
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, axis) {
                          int index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            return Text(
                              months[index],
                              style: GoogleFonts.poppins(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                              ),
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < months.length; i++) {
      barGroups.add(
        BarChartGroupData(
          barsSpace: 3,
          x: i,
          barRods: [
            BarChartRodData(
              borderRadius: BorderRadius.zero,
              fromY: 0,
              toY: subsCount[i][0].toDouble(),
              color: AppColors.premiumColor,
              width: 15,
            ),
            BarChartRodData(
              borderRadius: BorderRadius.zero,
              fromY: 0,
              toY: subsCount[i][1].toDouble(),
              color: AppColors.standardColor,
              width: 15,
            ),
          ],
        ),
      );
    }

    return barGroups;
  }
}
