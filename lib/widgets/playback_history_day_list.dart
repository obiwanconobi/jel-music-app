import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/playback_history_day_list_controller.dart';
import 'package:jel_music/models/playback_history.dart';
import 'package:jel_music/widgets/individual_song.dart';
import 'package:sizer/sizer.dart';

class PlaybackHistoryDayList extends StatefulWidget  {
  const PlaybackHistoryDayList({super.key, required this.day});

  final DateTime day;

  @override
  State<PlaybackHistoryDayList> createState() => _PlaybackHistoryDayListState();
}

class _PlaybackHistoryDayListState extends State<PlaybackHistoryDayList> {
  late final ScrollController _scrollController;
  var controller = GetIt.instance<PlaybackHistoryDayListController>();
  late Future<List<PlaybackHistory>> historyFuture;
  List<PlaybackHistory> history = [];
  DateTime? dayVal;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    history.clear();
    dayVal = widget.day;
    controller.day = widget.day;
    historyFuture = controller.onInit();
  }

  previousDay(){
    controller.day = controller.day!.add(const Duration(days:-1));
    setterState();
  }

  nextDay(){
    controller.day = controller.day!.add(const Duration(days:1));
    setterState();
  }

  setterState(){
    setState(() {
      historyFuture = controller.onInit();
      dayVal = controller.day;
    });
  }


  @override
  Widget build(BuildContext context) {
    return
      SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed:previousDay, icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).colorScheme.secondary, size:30),),
                  Text("${dayVal!.day}/${dayVal!.month}"),
                  IconButton(  onPressed: nextDay, icon: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.secondary, size:30),),
                ]),
            FutureBuilder<List<PlaybackHistory>>(
              future: historyFuture,
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
                child: Text('No data available.'),
              );
            } else {
              history = snapshot.data!;
              return Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: SizedBox(
                    height: 100.h,
                    child: GridView.builder(
                        //shrinkWrap: true,
                       gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(mainAxisSpacing: 0, mainAxisExtent: 12.h, maxCrossAxisExtent:100.w),
                        itemCount: history.length,
                        physics: const RangeMaintainingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 0),
                            child:  IndividualSong(songId: history[index].SongId!, playbackDate: history[index].PlaybackStart!,),
                          );
                      }
                    ),
                  ),
                ),
              );
            }
            }),
          ],
        ),
      );
  }
}
