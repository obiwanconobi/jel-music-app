import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/controllers/download_controller.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/isynchelper.dart';
import 'package:jel_music/models/log.dart';
import 'package:jel_music/widgets/downloads_page.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _MyWidgetState();
}



class _MyWidgetState extends State<SettingsPage> {
  final TextEditingController _serverUrlTextController = TextEditingController();
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _logController = TextEditingController();
  var downloadController = GetIt.instance<DownloadController>();
   var logger = GetIt.instance<LogHandler>();
  AlbumsHelper albumsHelper = AlbumsHelper();

  late ISyncHelper syncHelper;
  var apiController = GetIt.instance<ApiController>();
  ArtistsHelper helper = ArtistsHelper();
  late String totalCachedFileCount = "";
  late bool playbackReporting;
  late bool autoPlay;
  List<LogModel> logHistory = [];



  _login()async{
    if(_selectedOption == "Jellyfin"){
      await _jellyfinLogin();
    }else if (_selectedOption == "Subsonic"){
      await _subSoniclogin();
    }
  }

  _subSoniclogin()async{
    var username = _usernameTextController.text;
    var password =  _passwordTextController.text;
    await GetStorage().write('username', username);
    await GetStorage().write('password', password);
  }

  _jellyfinLogin() async{

      var username = _usernameTextController.text;
      var password =  _passwordTextController.text;
      var baseServerUrl = _serverUrlTextController.text;

      await GetStorage().write('username', username);
      await GetStorage().write('password', password);
      await apiController.login();
      await getUserId();
  }

  getUserId()async{
    var user = await apiController.getUser();
    await GetStorage().write('userId', user["Id"]);

  }

  getLogInfo()async{
    await logger.openBox();
    logHistory = logger.listFromLog();
    for (var log in logHistory){
      _logController.text +=("\n${log.logMessage!}");
    }
  }

  _saveUrl() async {

    await GetStorage().write('serverUrl', _serverUrlTextController.text);

}

   @override
   void  initState() {
    super.initState();
    GetStorage.init();



    _selectedOption = GetStorage().read('ServerType') ?? "Jellyfin";

    syncHelper = GetIt.instance<ISyncHelper>(instanceName: _selectedOption);


      getCachedSongs();
      playbackReporting = getPlaybackReporting();
      autoPlay = getAutoPlay();
   
    getLogInfo();
    syncHelper.openBox();
    helper.openBox();
    albumsHelper.openBox();
    // Set the initial value of the TextField
    _serverUrlTextController.text = GetStorage().read('serverUrl') ?? 'No Server Set';
    _usernameTextController.text = GetStorage().read('username') ?? 'Username';
    _passwordTextController.text = GetStorage().read('password') ?? 'Password';
  }

   @override
  void dispose() {
   // albumsHelper.albumsBox.close();
   // helper.artistBox.close(); // Close the Hive box in dispose
    super.dispose();
  }

  
  void sync()async{
    /* helper.getAllArtists();
    albumsHelper.getAllAlbums(); */
  if(_selectedOption == "Jellyfin"){
   await syncHelper.runSync(true);
  }else if (_selectedOption == "Subsonic"){

  }else if(_selectedOption == "PanAudio"){
    await syncHelper.runSync(true);
    //await panaudioSyncHelper.runSync(true);
  }

  }

  void clear()async{
    await helper.clearArtists();
    await albumsHelper.clearAlbums();
    await syncHelper.clearSongs();
  }

  void toggleTheme(){
      AdaptiveTheme.of(context).toggleThemeMode();

  }

  void clearCache()async{
  //  MusicControllerProvider.of(context, listen:false).clearCache();
    await downloadController.clearDownloads();

  }

  void check(){

    setState(() {
      getCachedSongs();
    });
  }

  bool getPlaybackReporting(){
    var value = GetStorage().read('playbackReporting') ?? false;
    return value;
  }

  bool getAutoPlay(){
    return GetStorage().read('autoPlay') ?? false;
  }

    setPlaybackReporting(bool value)async{
      await GetStorage().write('playbackReporting', value);
   }

   setAutoPlay(bool value)async{
    await GetStorage().write('autoPlay', value);
   }

  getCachedSongs()async{
    var documentsDar = await getApplicationDocumentsDirectory();
    final files = Directory(p.joinAll([documentsDar.path, 'panaudio/cache/'])).listSync();
      totalCachedFileCount = (files.length/2).toString();
  }

  goToDownloads()async{
      // ignore: prefer_const_constructors
      Navigator.push(context, MaterialPageRoute(builder: (context) =>  DownloadsPage()),);
  }

  writeServerType(String serverType)async{
    await GetStorage().write('ServerType', serverType);
  }
  String? _selectedOption = 'Jellyfin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall!.color)),
      ),
      body:
          Container(
          padding: const EdgeInsets.all(20),
          child: 
            SingleChildScrollView(
              child: Column(
                children: 
                [
                DropdownButton<String>(
                value: _selectedOption,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedOption = newValue;
                      writeServerType(newValue);
                    });
                  }
                },
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'Jellyfin',
                    child: Text('Jellyfin'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Subsonic',
                    child: Text('Subsonic'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'PanAudio',
                    child: Text('PanAudio'),
                  ),
                ],
              ),
                   Text('Server URL', style: TextStyle(color:Theme.of(context).textTheme.bodySmall!.color)),
                  TextField(obscureText: false, style: TextStyle(color:Theme.of(context).textTheme.bodySmall!.color), controller: _serverUrlTextController, decoration: InputDecoration( suffixIcon: IconButton(icon: const Icon(Icons.save), onPressed: (_saveUrl),)),),
                  TextField(obscureText: false, style: TextStyle(color:Theme.of(context).textTheme.bodySmall!.color), controller: _usernameTextController,),
                  TextField(obscureText: true, style: TextStyle(color:Theme.of(context).textTheme.bodySmall!.color), controller: _passwordTextController, decoration: InputDecoration( suffixIcon: IconButton(icon: const Icon(Icons.save), onPressed: (_login),)),),
                  TextButton(onPressed: () { sync(); }, child: Text('Sync', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)),),
                  TextButton(onPressed: () { check(); }, child: Text('Check', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)),),
                  TextButton(onPressed: () { clear(); }, child: Text('Clear', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)),),
                  TextButton(onPressed: () { toggleTheme(); }, child: Text('Toggle Theme', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)),),
                   TextButton(onPressed: () { clearCache(); }, child: Text('Clear Cache', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)),),
                  Text("Cached Songs: $totalCachedFileCount"),
                   TextButton(onPressed: () { goToDownloads(); }, child: Text('Downloads', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)),),
                   Row(
                     children: [
                      const Text("AutoPlay:"),
                      Switch(
                          value: autoPlay,
                          onChanged: (value) {
                            setState(() {
                              setAutoPlay(value);
                              autoPlay = getAutoPlay();
                            });
                          },
                        ),
                     ],
                   ),

                  Row(
                    children:[
                      Text("Playback reporting:"),
                      Switch(
                        value: playbackReporting,
                        onChanged: (value) {
                          setState(() {
                            setPlaybackReporting(value);
                            playbackReporting = getPlaybackReporting();
                          });
                        },
                      ),
                    ]
                  ),
                  SizedBox(
                    height: 30.h,
                      child: TextField(maxLines: null, controller: _logController))
                ],
              
              ),
            ),

            )
        );
  }
}