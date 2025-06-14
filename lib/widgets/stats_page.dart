import 'package:flutter/material.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/widgets/most_played_songs.dart';
import 'package:jel_music/widgets/playback_by_artist_chart.dart';
import 'package:jel_music/widgets/playback_days_chart.dart';
import 'package:jel_music/widgets/playback_history_day_list.dart';
import 'package:jel_music/widgets/playback_songs_monthly.dart';
import 'package:page_swiper/page_swiper.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stacked_page_view/stacked_page_view.dart';

class StatsPage extends StatefulWidget {
  static const pageNum = 2;
  const StatsPage({this.initialPage = 1,
    this.titleHeight = 250,
    this.titleHeightCollapsed = 100,super.key});

  final int initialPage;
  final double titleHeight;
  final double titleHeightCollapsed;

  @override
  State<StatsPage> createState() => _StatsPageState();
}



class _StatsPageState extends State<StatsPage> {

  late PageController _pageController;
  late List<ScrollController> _pageScrollControllers;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    _pageScrollControllers = [
      for (int i = 0; i < StatsPage.pageNum; i++)
        ScrollController()
    ];
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (int i = 0; i < StatsPage.pageNum; i++) {
      _pageScrollControllers[i].dispose();
    }
    super.dispose();
  }


  Widget returnWidget(int index){
    if(index == 0){
      return PlaybackHistoryDayList(day: DateTime.now());
    }else if(index == 1){
      return const PlaybackDaysChart();

    }else if(index == 2){
      return const PlaybackByArtistChart();
    }else{
      return const PlaybackSongsMonthly();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
    Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('statistics'.localise(), style: Theme.of(context).textTheme.bodyLarge),
          actions: [Padding(padding: const EdgeInsets.fromLTRB(0, 0, 15, 0), child: IconButton(icon: const Icon(Icons.format_list_numbered), onPressed: () { Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MostPlayedSongs()),
          ); },))],
      ),
      body: Column(
        children: [
          SmoothPageIndicator(
              controller: _pageController,  // PageController
              count:  4,
              effect:  WormEffect(),  // your preferred effect
              onDotClicked: (index){
              }
          ),
          SizedBox(
            height: 85.h,
            child: PageView.builder(
              itemCount: 4,
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              itemBuilder: (context, index){
                return StackPageView(
                  controller: _pageController,
                  index: index,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  animationAxis: Axis.horizontal,
                  child: returnWidget(index)
                );
              }
            ),
          ),
        ],
      )
    ));
  }
}
