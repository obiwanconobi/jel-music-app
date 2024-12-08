import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/PlaybackByDaysController.dart';
import 'package:jel_music/models/bar%20chart/bar_data.dart';
import 'package:jel_music/models/playback_days.dart';
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



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No artists available.'),
            );
          } else {
            days = snapshot.data!;
            var ff = (days.where((element) => element.Day!.weekday == 7).firstOrNull?.TotalSeconds ?? 0)/60;
            var fff = ff.round();
            var ffff= ff.truncate();
            BarData barData = BarData(
                monAmount: ((days.where((element) => element.Day!.weekday == 1).firstOrNull?.TotalSeconds ?? 0)/60).round().toDouble(),
                tueAmount:  ((days.where((element) => element.Day!.weekday == 2).firstOrNull?.TotalSeconds ?? 0)/60).round().toDouble(),
                wedAmount:  ((days.where((element) => element.Day!.weekday == 3).firstOrNull?.TotalSeconds ?? 0)/60).round().toDouble(),
                thuAmount:  ((days.where((element) => element.Day!.weekday == 4).firstOrNull?.TotalSeconds ?? 0)/60).round().toDouble(),
                friAmount:  ((days.where((element) => element.Day!.weekday == 5).firstOrNull?.TotalSeconds ?? 0)/60).round().toDouble(),
                satAmount:  ((days.where((element) => element.Day!.weekday == 6).firstOrNull?.TotalSeconds ?? 0)/60).round().toDouble(),
                sunAmount: ((days.where((element) => element.Day!.weekday == 7).firstOrNull?.TotalSeconds ?? 0)/60).round().toDouble(),);
            barData.initializeBarData();
            var maxSize = getHighestTotal(days)/60;
            return SizedBox(
              height: 30.h,
              width: 100.w,
              child: Padding(
                padding:  EdgeInsets.fromLTRB(0,15.w, 0,5.w),
                child: BarChart(
                    BarChartData(
                      maxY: maxSize,
                      minY: 0,
                      barGroups: barData.barData.map((data) => BarChartGroupData(x: data.x,
                          barRods: [
                            BarChartRodData(toY: data.y, color: Theme.of(context).colorScheme.secondary, backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxSize, color:Theme.of(context).canvasColor))])).toList(),
                      borderData: FlBorderData(
                          border: const Border(bottom: BorderSide(), left: BorderSide())),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show:true,
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),

                    )
                ),
              ),
            );
          }
        }
    );
  }
}
