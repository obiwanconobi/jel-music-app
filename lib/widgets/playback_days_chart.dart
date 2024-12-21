import 'dart:ffi';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/PlaybackByDaysController.dart';
import 'package:jel_music/helpers/datetime_extensions.dart';
import 'package:jel_music/models/bar%20chart/bar_data.dart';
import 'package:jel_music/models/playback_days.dart';
import 'package:jel_music/widgets/most_played_songs_artist.dart';
import 'package:jel_music/widgets/playback_history_day_list.dart';
import 'package:sizer/sizer.dart';

class PlaybackDaysChart extends StatefulWidget {
  const PlaybackDaysChart({super.key});

  @override
  State<PlaybackDaysChart> createState() => _PlaybackDaysChartState();
}

class _PlaybackDaysChartState extends State<PlaybackDaysChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var daysController = GetIt.instance<PlaybackByDaysController>();
  late Future<List<PlaybackDays>> daysFuture;
  List<PlaybackDays> days = [];
  int currentWeek = 1;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    daysFuture = daysController.onInit();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  _getHistoryByDays(){

  }


  Widget getBottomTiles(double value, TitleMeta meta){
    var values = days[value.toInt()].Day.toString();
    return Text(values);
  }

  AxisTitles get bottomAxisTitles => AxisTitles(
      sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (val, meta) => getBottomTiles(val, meta),
          reservedSize: 42));


  List<BarChartGroupData> _chartGroups() {
    List<BarChartGroupData> data = [];

    for(var d in days){
      int count = 0;
      data.add(BarChartGroupData(
          x:  count,
          barRods: [
            BarChartRodData(
                toY: d.TotalSeconds!.toDouble()
            )
          ]
      ));
      count++;
    }

    return data.toList();



  }


  int getHighestTotal(List<PlaybackDays> days){
    if(days.isEmpty)return 0;
    return days.map((day) => day.TotalSeconds ?? 0)
        .reduce((max, current) => current> max ? current : max);
  }


  Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
    );
    Widget text;

    var ff = days[value.toInt() - 1].Day?.weekday.intToStringDay();
    var ffff = days[value.toInt()-1].Day?.day.intWithSuff();
    return SideTitleWidget(axisSide: meta.axisSide, child: Text(ffff ?? "X"));
  }

  void previous7Days()async{
    currentWeek++;
    setState(() {
      daysFuture = daysController.changeDate(currentWeek);
    });

  }

  void next7Days()async{
    currentWeek--;
    setState(() {
      daysFuture = daysController.changeDate(currentWeek);
    });

  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 5.w, 0, 0),
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed:previous7Days, icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).colorScheme.secondary, size:30),),
                IconButton(  onPressed: currentWeek > 1 ? next7Days : null, icon: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.secondary, size:30),),
              ]),
          FutureBuilder(
              key: ValueKey(currentWeek),
              future: daysFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    //child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty || snapshot.data!.length < 7) {
                  return const Center(
                    child: Text('No data available.'),
                  );
                } else {
                  days = snapshot.data!;
                  var ff = (days.where((element) => element.Day!.weekday == 7).firstOrNull?.TotalSeconds ?? 0)/60;
                  var fff = ff.round();
                  var ffff= ff.truncate();

                  BarData  barData = BarData(
                      monAmount: ((days[0].TotalSeconds ?? 0)/60).round().toDouble(),
                      tueAmount:  ((days[1].TotalSeconds ?? 0)/60).round().toDouble(),
                      wedAmount:  ((days[2].TotalSeconds ?? 0)/60).round().toDouble(),
                      thuAmount:  ((days[3].TotalSeconds ?? 0)/60).round().toDouble(),
                      friAmount:  ((days[4].TotalSeconds ?? 0)/60).round().toDouble(),
                      satAmount:  ((days[5].TotalSeconds ?? 0)/60).round().toDouble(),
                      sunAmount: ((days[6].TotalSeconds ?? 0)/60).round().toDouble(),);
                    barData.initializeBarData();
                  var maxSize = getHighestTotal(days)/60;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: SizedBox(
                      height: 35.h,
                      width: 90.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(30, 39, 48, 1.0),
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding:  EdgeInsets.fromLTRB(0,2.w, 0,2.w),
                          child: BarChart(
                              BarChartData(
                                maxY: maxSize,
                                minY: 0,
                                barGroups: barData.barData.map((data) => BarChartGroupData(x: data.x,
                                    barRods: [
                                      BarChartRodData(toY: data.y, width:25, borderRadius: BorderRadius.circular(15), color: const Color.fromRGBO(15, 195, 207, 1.0), backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxSize, color:const Color.fromRGBO(30, 39, 48, 1.0),))])).toList(),
                                borderData: FlBorderData(
                                    border: const Border(bottom: BorderSide(width: 0), left: BorderSide(width: 0))),
                                gridData: FlGridData(show: false),
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (
                                        BarChartGroupData group,
                                        int groupIndex,
                                        BarChartRodData rod,
                                        int rodIndex,
                                        ) {
                                      final color = rod.gradient?.colors.first ?? rod.color;
                                      final textStyle = TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      );
                                      return BarTooltipItem("${rod.toY.toString().replaceAll(".0", "")}mins", Theme.of(context).textTheme.labelSmall!);
                                    }
                                  )
                                ),
                                titlesData: FlTitlesData(
                                  show:true,
                                  bottomTitles: AxisTitles(
                                    axisNameSize: 12,
                                    sideTitles: SideTitles(
                                      reservedSize: 5.h,
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) =>
                                          getBottomTitles(value, meta),
                                    ),
                                  ),
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                              )
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
          ),
        ],
      ),
    );
  }
}
