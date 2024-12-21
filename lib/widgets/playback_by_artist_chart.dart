import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:jel_music/controllers/playback_artists_controller.dart';
import 'package:jel_music/main.dart';
import 'package:jel_music/models/playback_artists.dart';
import 'package:sizer/sizer.dart';

class PlaybackByArtistChart extends StatefulWidget {
  const PlaybackByArtistChart({super.key});

  @override
  State<PlaybackByArtistChart> createState() => _PlaybackByArtistChartState();
}

class _PlaybackByArtistChartState extends State<PlaybackByArtistChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int touchedIndex = -1;
  var playbackArtistController = GetIt.instance<PlaybackArtistsController>();
  late Future<List<PlaybackArtists>> playbackArtistsFuture;
  List<PlaybackArtists> playbackArtists = [];
  int currentMonth = 1;
  List<PieChartSectionData> sections = [];
  String title = "";
  String dateTitle = "";
  List<Color> colours = [
    const Color.fromRGBO(204, 223, 32, 1),
    const Color.fromRGBO(14, 63, 92, 1),
    const Color.fromRGBO(104, 23, 132, 1),
    const Color.fromRGBO(44, 23, 232, 1),
    const Color.fromRGBO(204, 23, 32, 1),
    const Color.fromRGBO(36, 107, 239, 1.0),
    const Color.fromRGBO(169, 74, 255, 1.0),
    const Color.fromRGBO(23, 255, 236, 1.0),
    const Color.fromRGBO(123, 107, 255, 1.0),
  ];

  @override
  void initState() {
    super.initState();
    dateTitle = DateFormat('MMMM').format(DateTime(DateTime.now().year, DateTime.now().month - (playbackArtistController.currentMonth ?? 0)));

    playbackArtistController.currentMonth = 0;
    playbackArtistsFuture = playbackArtistController.onInit();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  previousMonth(){
    playbackArtistController.currentMonth = (playbackArtistController.currentMonth ?? 0) -1;
    setState(() {
      playbackArtistsFuture = playbackArtistController.onInit();
      dateTitle = DateFormat('MMMM').format(DateTime(DateTime.now().year, DateTime.now().month + (playbackArtistController.currentMonth ?? 0)));
    });

  }
  nextMonth(){
    playbackArtistController.currentMonth =(playbackArtistController.currentMonth ?? 0) + 1;
    setState(() {
      playbackArtistsFuture = playbackArtistController.onInit();
      dateTitle = DateFormat('MMMM').format(DateTime(DateTime.now().year, DateTime.now().month + (playbackArtistController.currentMonth ?? 0)));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed:previousMonth, icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).colorScheme.secondary, size:30),),
              Text(dateTitle),
              IconButton(  onPressed: nextMonth, icon: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.secondary, size:30),),
            ]),
        FutureBuilder(
            key: ValueKey(currentMonth),
            future: playbackArtistsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  //child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty ||
                  snapshot.data!.length < 7) {
                return const Center(
                  child: Text('No data available.'),
                );
              } else {
                playbackArtists = snapshot.data!;
                sections = getSections();
                return Column(
                  children: [
                    Text('Favourite Artists', style: Theme.of(context).textTheme.bodyLarge),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20.w, 0, 0),
                      child: Container(
                        height: 50.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [PieChart(
                              PieChartData(
                                  centerSpaceRadius: 30.w,
                                  startDegreeOffset: 0,
                                  sections: sections,
                                  pieTouchData: PieTouchData(
                                      touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse)
                                      {
                                        setState(() {
                                          if (!event.isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection == null) {
                                            touchedIndex = -1;
                                            return;
                                          }
                                          touchedIndex = pieTouchResponse
                                              .touchedSection!.touchedSectionIndex;
                                            if(touchedIndex != -1){
                                              title = sections[touchedIndex].title;
                                            }


                                        });
                                      }),
                              )
                          ),
                            SizedBox(
                              width: 40.w,
                                child: Text(title, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.visible, maxLines: 2,)),
                          ]
                        )),
                    ),
                    Padding(
                      padding:  EdgeInsets.fromLTRB(0, 15.w, 0, 0),
                      child: SizedBox(
                        height: 30.h,
                        child: ListView.builder(
                        // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, mainAxisExtent: 26.h),
                        itemCount: playbackArtists.length,
                        shrinkWrap: true,
                        physics: const RangeMaintainingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(playbackArtists[index].artistName!),
                                Row(
                                  children: [
                                    Text("${((playbackArtists[index].totalSeconds ?? 0)/60).round()} mins"),
                                    Text(" - "),
                                    Text("${playbackArtists[index].playCount} plays"),
                                  ],
                                ),
                                Divider(height: 2,)
                              ],
                            ),
                          );
                        }
                        ),
                      ),
                    )
                  ],

                );
              }
            }),
      ],
    );
  }

  List<PieChartSectionData> getSections(){
    List<PieChartSectionData> list = [];
    int totalSecondsSum = playbackArtists.fold(0, (sum, artist) => sum + (artist.totalSeconds ?? 0));
    int count = 0;
    for(var artist in playbackArtists){
      if(count > 7){
        var restOfArtists = playbackArtists.sublist(7, playbackArtists.length);
        int restSum = restOfArtists.fold(0, (sum, artist) => sum + (artist.totalSeconds ?? 0));
        var restTot = (restSum / totalSecondsSum)*100;
        list.add(PieChartSectionData(title: "Others - ${restTot.round()}%", color: colours[count], showTitle: false ,titlePositionPercentageOffset: 0.8,value: restTot.truncateToDouble()));
        return list;
      }
      var percent = (artist.totalSeconds! / totalSecondsSum)*100;
      list.add(PieChartSectionData(title: "${artist.artistName} - ${percent.round()}%", color: colours[count], showTitle: false,titlePositionPercentageOffset: 0.8, value: percent.truncateToDouble()));
      count++;
    }
      return list;
  }

}