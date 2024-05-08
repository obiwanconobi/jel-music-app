import 'dart:convert';
import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/controllers/download_controller.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/androidid.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/sync_helper.dart';
import 'package:jel_music/models/log.dart';
import 'package:jel_music/widgets/downloads_page.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _MyWidgetState();
}



class _MyWidgetState extends State<SettingsPage> {
  final TextEditingController _serverUrlTextController = TextEditingController();
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  var downloadController = GetIt.instance<DownloadController>();
   var logger = GetIt.instance<LogHandler>();
  AlbumsHelper albumsHelper = AlbumsHelper();
  SyncHelper syncHelper = SyncHelper();
  //ApiController apiController = ApiController();
  var apiController = GetIt.instance<ApiController>();
  ArtistsHelper helper = ArtistsHelper();
  late String totalCachedFileCount = "";
  late bool playbackReporting;
  List<LogModel> logHistory = [];
  _login() async{

      try{
      var username = _usernameTextController.text;
      var password =  _passwordTextController.text;
      var baseServerUrl = _serverUrlTextController.text;
      
      //var deviceId = await const AndroidId().getDeviceId();
      String deviceId = "TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2";
      GetStorage().write('deviceId', deviceId);
      String loginBody = '{"Username": "$username","Pw": "$password"}';

      Map<String, String> requestHeaders = {
       'Content-type': 'application/json',
       'X-Emby-Authorization': 'MediaBrowser Client="Panaudio",Device="Mobile",DeviceId="$deviceId", Version="10.8.13"'
     };
      String url = "$baseServerUrl/Users/AuthenticateByName";
      
            http.Response res = await http.post(Uri.parse(url), headers: requestHeaders, body: loginBody);
            if (res.statusCode == 200) {
              var stringgg = json.decode(res.body)["AccessToken"];
              GetStorage().write('accessToken', json.decode(res.body)["AccessToken"]);
              GetStorage().write('username', username);
              GetStorage().write('password', password);
              var strginggg = res.body.toString();
               logger.addToLog(LogModel(logMessage: "Login Successful", logDateTime:DateTime.now(), logType: "INFO"));
           
            }else{
              logger.addToLog(LogModel(logMessage: "Failed o login with username: $username at the url: $baseServerUrl", logDateTime:DateTime.now(), logType: "ERROR"));
              //log error
            }

        await _getUserId();

      }catch(e){
        //log error
      }
      
  }

  _getUserId()async{
    var user = await apiController.getUser();
    GetStorage().write('userId', user["Id"]);

  }

  _getLogInfo()async{
    logHistory = logger.listFromLog();
  }

  _saveUrl() async {

    GetStorage().write('serverUrl', _serverUrlTextController.text);

}

   @override
   void  initState() {
    super.initState();
    GetStorage.init();

      getCachedSongs();
      playbackReporting = getPlaybackReporting();
   

    syncHelper.songsHelper.openBox();
    helper.openBox();
    albumsHelper.openBox();
    // Set the initial value of the TextField
    _serverUrlTextController.text = GetStorage().read('serverUrl') ?? 'No Server Set';
    _usernameTextController.text = GetStorage().read('username') ?? 'Username';
    _passwordTextController.text = GetStorage().read('password') ?? 'Password';
  }

   @override
  void dispose() {
    albumsHelper.albumsBox.close();
    helper.artistBox.close(); // Close the Hive box in dispose
    super.dispose();
  }

  
  void sync(){
    /* helper.getAllArtists();
    albumsHelper.getAllAlbums(); */

    syncHelper.runSync();
  }

  void clear(){
    helper.clearArtists();
    albumsHelper.clearAlbums();
    syncHelper.songsHelper.clearSongs();
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
    return GetStorage().read('playbackReporting') ?? false;
  }

   setPlaybackReporting(bool value){
     GetStorage().write('playbackReporting', value);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        foregroundColor: Theme.of(context).textTheme.bodySmall!.color,
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        title: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall!.color)),
      ),
      body:
          Container(
          padding: const EdgeInsets.all(20),
          child: 
            Column(
              children: 
              [
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
                    const Text("Playback reporting:"),
                    Switch(
                        value: playbackReporting,
                        onChanged: (value) {
                          setState(() {
                            setPlaybackReporting(value);
                            playbackReporting = getPlaybackReporting();
                          });
                        },
                      ),
                   ],
                 ),
              ],
            ),
            )
        );
  }
}