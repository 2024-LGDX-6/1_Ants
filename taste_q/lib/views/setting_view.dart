import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/models/recipe_mode.dart';
import 'package:taste_q/providers/recipe_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class SettingView extends StatelessWidget { // Provider를 적용한 모드 설정 뷰
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    final selectedMode = recipeProvider.mode; // 현재 모드 가져오기

    final List<String> modes = ["표준 모드", "웰빙 모드", "미식 모드"];
    final List<String> descriptions = [
      "가장 표준적인 레시피를 따릅니다.\n실패하지는 않지만 맛있을 수도 있습니다.",
      "LG는 사용자의 건강도 생각합니다.\n싱거울 수는 있지만 건강에는 좋아요.",
      "강렬한 맛을 선사합니다.\n풍미와 개성이 담긴 만족스런 식사를 위해",
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전력량 모니터링 박스
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 24.w),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "전력량 모니터링",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                // 전력량 데이터 생성 및 그래프 표시
                _PowerChart(),
                // Legend (manual text)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('— 이번달', style: TextStyle(color: Colors.cyanAccent)),
                      Text('  |  ', style: TextStyle(color: Colors.black)),
                      Text('— 지난달', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),

          Text(
            "MODE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 12.h),

          // 모드 설정 버튼 목록
          ListView.builder(
            itemCount: modes.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final mode = RecipeMode.values[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<RecipeMode>(
                    title: Text(
                      modes[index],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: mode,
                    groupValue: selectedMode,
                    onChanged: (RecipeMode? newMode) {
                      if (newMode != null) {
                        context.read<RecipeProvider>().setMode(newMode); // setMode로 변경
                      }
                    },
                  ),
                  if (selectedMode == mode)
                    Padding(
                      padding: EdgeInsets.only(left: 72.w, bottom: 12.h),
                      child: Text(
                        descriptions[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PowerChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final random = Random();
    // 두 세트 데이터 (이번달, 지난달)
    final powerDataCurrent = List.generate(24, (i) {
      return {
        'hour': i.toString(),
        'usage': (random.nextDouble() * 5 + 1).toStringAsFixed(1)
      };
    });
    final powerDataLastMonth = List.generate(24, (i) {
      return {
        'hour': i.toString(),
        'usage': (random.nextDouble() * 5 + 1).toStringAsFixed(1)
      };
    });

    final spotsCurrent = List<FlSpot>.generate(
      powerDataCurrent.length,
      (i) => FlSpot(i.toDouble(), double.parse(powerDataCurrent[i]['usage']!)),
    );
    final spotsLastMonth = List<FlSpot>.generate(
      powerDataLastMonth.length,
      (i) => FlSpot(i.toDouble(), double.parse(powerDataLastMonth[i]['usage']!)),
    );

    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 160.h,
        width: MediaQuery.of(context).size.width * 0.7,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: LineChart(
          LineChartData(
            backgroundColor: Colors.grey[200],
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 2,
              verticalInterval: 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(
                    value % 2 == 0 ? value.toInt().toString() : '',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                  reservedSize: 36,
                ),
                axisNameWidget: Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('(시간)', style: TextStyle(fontSize: 11, color: Colors.black)),
                ),
                axisNameSize: 24,
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 4,
                  getTitlesWidget: (value, meta) {
                    int hour = value.toInt();
                    if (hour < 0 || hour > 23) return const SizedBox();
                    return Text(
                      '${hour}시',
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    );
                  },
                  reservedSize: 28,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            minY: 0,
            maxY: 12,
            minX: 0,
            maxX: 23,
            lineBarsData: [
              // 이번달 (파랑, dot 강조)
              LineChartBarData(
                isCurved: true,
                spots: spotsCurrent,
                barWidth: 2,
                isStrokeCapRound: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue,
                    Colors.blue.withOpacity(0.7),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: 3,
                        color: Colors.blue,
                        strokeColor: Colors.white,
                        strokeWidth: 1,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.10),
                      Colors.blue.withOpacity(0.02),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // 지난달 (회색, dot 없음)
              LineChartBarData(
                isCurved: true,
                spots: spotsLastMonth,
                barWidth: 2,
                isStrokeCapRound: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[400]!,
                    Colors.grey.withOpacity(0.7),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                dotData: FlDotData(
                  show: false,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.08),
                      Colors.grey[400]!.withOpacity(0.01),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                // Remove tooltipBgColor and tooltipRoundedRadius entirely
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final isCurrent = spot.barIndex == 0;
                    final idx = spot.spotIndex;
                    final data = isCurrent ? powerDataCurrent : powerDataLastMonth;
                    return LineTooltipItem(
                      '${data[idx]['hour']}시\n${data[idx]['usage']} kWh',
                      TextStyle(
                        color: isCurrent ? Colors.blue : Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.transparent,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
