import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/playback_songs_monthly_controller.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/playback_songs_monthly.dart';

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
        DateTime.now().add(new Duration(days: -30)), DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
    return Row(
      children: [
        Column(
          children: [
            Text(days[index].SongTitle!),
            Text(days[index].Artist!),
          ],
        ),
        Text(days[index].TotalCount.toString()),
      ],
    );
    });
          }
        });
  }
}


