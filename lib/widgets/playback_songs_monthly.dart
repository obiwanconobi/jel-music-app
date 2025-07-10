import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/playback_songs_monthly_controller.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/playback_songs_monthly.dart';
import 'package:jel_music/widgets/songs_page.dart';
import 'package:sizer/sizer.dart';

class PlaybackSongsMonthly extends StatefulWidget {
  const PlaybackSongsMonthly({super.key});

  @override
  State<PlaybackSongsMonthly> createState() => _PlaybackSongsMonthlyState();
}

class _PlaybackSongsMonthlyState extends State<PlaybackSongsMonthly> {

  var controller = GetIt.instance<PlaybackSongsMonthlyController>();
  late Future<List<PlaybackSongsMonthlyModel>> songsFuture;
  List<PlaybackSongsMonthlyModel> days = [];
  int currentWeek = 1;


  @override
  void initState() {
    super.initState();

    songsFuture = controller.fetchData(
        DateTime.now().add(new Duration(days: -30)), DateTime.now().add(Duration(days:1)));
  }

  lastMonth(){
    currentWeek++;
    setState(() {
      songsFuture = controller.changeDate(currentWeek);
    });
  }

  nextMonth(){
    currentWeek--;
    setState(() {
      songsFuture = controller.changeDate(currentWeek);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed:lastMonth, icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).colorScheme.secondary, size:30),),
                IconButton(  onPressed: currentWeek > 1 ? nextMonth : null, icon: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.secondary, size:30),),
              ]),
          FutureBuilder(
              key: ValueKey(currentWeek),
              future: songsFuture,
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
                  return Center(
                    child: Text('no_data_error'.localise()),
                  );
                } else {
                  days = snapshot.data!;
                  return ListView.builder(
          shrinkWrap: true,
          itemCount: days.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
          return InkWell(
            onTap: ()=>{
              Navigator.push(context,
              MaterialPageRoute(maintainState: true, builder: (context) => SongsPage(albumId: days[index].Album!, artistId: days[index].Artist!,)),
            )},
            child: Padding(
              padding:  EdgeInsets.fromLTRB(10, 2.w, 0, 0),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2.w),
                        child: CachedNetworkImage(
                          imageUrl: days[index].ArtUri ?? "",
                          memCacheHeight: 70,
                          memCacheWidth: 70,
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF71B77A),
                            child: const Center(
                              child: Text("404"),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 1.h, 0, 0),
                          width:74.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(days[index].SongTitle!,style: Theme.of(context).textTheme.bodySmall, maxLines:1, overflow: TextOverflow.ellipsis),
                              Text(days[index].Artist!,style: Theme.of(context).textTheme.bodySmall,maxLines:1, overflow: TextOverflow.ellipsis),
                              Text('${days[index].TotalCount.toString()} plays')
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
          });
                }
              }),
        ],
      ),
    );
  }
}


