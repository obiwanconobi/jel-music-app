import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/download_controller.dart';
import 'package:jel_music/handlers/quick_actions_handler.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/hive/helpers/isynchelper.dart';
import 'package:jel_music/widgets/favourite_albums.dart';
import 'package:jel_music/widgets/favourite_artists.dart';
import 'package:jel_music/widgets/latest_albums.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/settings_page.dart';
import 'package:jel_music/widgets/start_page_buttons.dart';
import 'package:sizer/sizer.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});



  @override
  State<StartPage> createState() => _StartPageState();
  

}

class _StartPageState extends State<StartPage> {

  late ISyncHelper syncHelper;
  DownloadController downloadsController = DownloadController();
  final QuickActionsHandler _quickActionsHandler = QuickActionsHandler();

  @override
  void initState() {
    String serverType = GetStorage().read('ServerType') ?? "Jellyfin";
    super.initState();
    syncHelper = GetIt.instance<ISyncHelper>(instanceName: serverType);
    _quickActionsHandler.initialize(context);
    syncAsync();
    // You could also try forcing a rebuild here
    // WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  syncAsync()async{
    await syncHelper.runSync(false);
    await downloadsController.syncDownloads();
  }

  @override
  Widget build(BuildContext context) {
    // sets theme mode to dark
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
                  actions: [Padding(padding: const EdgeInsets.fromLTRB(0, 0, 15, 0), child: IconButton(icon:  const Icon(Icons.settings), 
                  onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()),);}))],
                  centerTitle: true, title: Text('panaudio', style: Theme.of(context).textTheme.bodyLarge),),
        //backgroundColor: Theme.of(context).colorScheme.background,
        body:
        Padding(
          padding: EdgeInsets.only(
            top: 2.h,
            left: 0.sp,
            bottom: 10.sp,
            right: 0.sp,
          ),
          child: SingleChildScrollView(
            child: Column( 
                children: [
                  // ignore: prefer_const_constructors
                  FavouriteAlbums(),
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: Text('fav_artists_title'.localise(), style: Theme.of(context).textTheme.bodyLarge)),
                  // ignore: prefer_const_constructors
                  FavouriteArtists(),
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: Text('latest_albums_title'.localise(), style: Theme.of(context).textTheme.bodyLarge)),
                  // ignore: prefer_const_constructors
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 70),
                    child: const LatestAlbums(),
                  ),
                ],
                    ),
          )
      ),
      bottomSheet: const Controls(),
      /* floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              
            });
          },
          foregroundColor: Colors.blueGrey,
          backgroundColor: const Color.fromARGB(255, 59, 59, 59),
          child: const Icon(Icons.search),
        ),
      ), */
          )
    );
  }
}