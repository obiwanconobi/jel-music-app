import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/controllers/download_controller.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/app_translations.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/isynchelper.dart';
import 'package:jel_music/models/log.dart';
import 'package:jel_music/themes/dark_theme.dart';
import 'package:jel_music/themes/light_theme.dart';
import 'package:jel_music/widgets/downloads_page.dart';
import 'package:jel_music/widgets/log_box.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


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

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  late Future<PackageInfo> packageInfo;
  String version = "";
  var downloadController = GetIt.instance<DownloadController>();
   var logger = GetIt.instance<LogHandler>();
  AlbumsHelper albumsHelper = AlbumsHelper();

  late ISyncHelper syncHelper;
  var apiController = GetIt.instance<ApiController>();
  ArtistsHelper helper = ArtistsHelper();
  late String totalCachedFileCount = "";
  late bool playbackReporting;
  late bool autoPlay;
  late bool launcher;
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
    StringBuffer logBuffer = StringBuffer();
    for (var log in logHistory) {
      logBuffer.writeln(log.logMessage);
    }
    _logController.text = logBuffer.toString();
  }

  _saveUrl() async {

    await GetStorage().write('serverUrl', _serverUrlTextController.text);

}

_getVersionNumber()async{
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  setState(() {
    _packageInfo = packageInfo;
  });

}

   @override
   void initState() {
    super.initState();
    GetStorage.init();




    _selectedOption = GetStorage().read('ServerType') ?? "Jellyfin";
    _font = GetStorage().read('font') ?? "Inconsolata";
    _language = GetStorage().read('language') ?? "en";
    syncHelper = GetIt.instance<ISyncHelper>(instanceName: _selectedOption);

      playbackReporting = getPlaybackReporting();
      autoPlay = getAutoPlay();
      launcher = getLauncher();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getVersionNumber();
      getCachedSongs();
      getLogInfo();
    });

    Future.wait([
      openBox()
    ]);


    // Set the initial value of the TextField
    _serverUrlTextController.text = GetStorage().read('serverUrl') ?? 'No Server Set';
    _usernameTextController.text = GetStorage().read('username') ?? 'Username';
    _passwordTextController.text = GetStorage().read('password') ?? 'Password';
  }


  Future<void> openBox() async{
   await syncHelper.openBox();
   await helper.openBox();
   await albumsHelper.openBox();
  }


   @override
  void dispose() {
   // albumsHelper.albumsBox.close();
   // helper.artistBox.close(); // Close the Hive box in dispose
    super.dispose();
  }


  void scan()async{
    await syncHelper.scan();
  }
  
  void sync()async{
    /* helper.getAllArtists();
    albumsHelper.getAllAlbums(); */
    syncHelper = GetIt.instance<ISyncHelper>(instanceName: _selectedOption);
  if(_selectedOption == "Jellyfin"){
   await syncHelper.runSync(true);
  }else if (_selectedOption == "Subsonic"){
    await syncHelper.runSync(true);
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

  clearLogs()async{
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

  bool getLauncher(){
    return GetStorage().read('launcher') ?? false;
  }

    setPlaybackReporting(bool value)async{
      await GetStorage().write('playbackReporting', value);
   }

   setAutoPlay(bool value)async{
    await GetStorage().write('autoPlay', value);
   }

   setLauncher(bool value)async{
     await GetStorage().write('launcher', value);
   }

  getCachedSongs()async{
    try{

      if (kIsWeb) {
        // Set web-specific directory
      } else {
        var documentsDar = await getApplicationDocumentsDirectory();
        final files = await Directory(p.joinAll([documentsDar.path, 'panaudio/cache/'])).list().toList();
        setState(() {
          totalCachedFileCount = (files.length/2).toString();
        });

      }

    }catch(e){
      await logger.addToLog(LogModel(logType: "Error", logMessage: "Error getting cached songs", logDateTime: DateTime.now()));
    }

  }

  goToDownloads()async{
      // ignore: prefer_const_constructors
      Navigator.push(context, MaterialPageRoute(builder: (context) =>  DownloadsPage()),);
  }

  goToLogBox()async{
    // ignore: prefer_const_constructors
    Navigator.push(context, MaterialPageRoute(builder: (context) =>  LogBox()),);
  }
  writeServerType(String serverType)async{
    await GetStorage().write('ServerType', serverType);
  }

  writeFont(String font)async{
    await GetStorage().write('font', font);
  }

  writeLanguage(String language)async{
    await GetStorage().write('language', language);
    AppTranslations.reload('assets/language/$language.json');
  }

  setThemes(){
    AdaptiveTheme.of(context).setTheme(
      light: getLightTheme(),
      dark: getDarkTheme()
    );

  }

  setLightTheme(){
    setThemes();
    AdaptiveTheme.of(context).setLight();
  }

  setDarkTheme(){
    setThemes();
    AdaptiveTheme.of(context).setDark();
  }

  String? _selectedOption = 'Jellyfin';
  String _font = 'Inconsolata';
  String? _language = "en";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("settings_title".localise(), style: Theme.of(context).textTheme.bodyLarge),
      ),
      body:
          Container(
          padding: const EdgeInsets.all(20),
          child:
            SingleChildScrollView(
              child: Column(
                children: [
                  GridView(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 60.w, // Adjust this value according to your needs
                  mainAxisSpacing: 6.w,
                  mainAxisExtent: 52.w,
                                ),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('server_type'.localise(), style: Theme.of(context).textTheme.bodySmall),
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
                              items:  <DropdownMenuItem<String>>[
                                DropdownMenuItem<String>(
                                  value: 'Jellyfin',
                                  child: Text('Jellyfin',  style: Theme.of(context).textTheme.bodySmall),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Subsonic',
                                  child: Text('Subsonic',  style: Theme.of(context).textTheme.bodySmall),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'PanAudio',
                                  child: Text('PanAudio',  style: Theme.of(context).textTheme.bodySmall),
                                ),
                              ],
                                            ),
                              TextButton(onPressed: () { scan(); }, child: Text('Scan', style:  Theme.of(context).textTheme.bodySmall),),
                            ],
                          ),
                        ),
                      ),
                      Card(child:
                      Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          children: [
                            TextButton(onPressed: () { sync(); }, child: Text('Sync', style:  Theme.of(context).textTheme.bodySmall),),
                            TextButton(onPressed: () { clear(); }, child: Text('clear'.localise(), style:  Theme.of(context).textTheme.bodySmall),),
                            DropdownButton<String>(
                              value: _language,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _language = newValue;
                                    writeLanguage(newValue);
                                  });
                                }
                              },
                              items: <DropdownMenuItem<String>>[
                                DropdownMenuItem<String>(
                                  value: 'en',
                                  child: Text('English',style: Theme.of(context).textTheme.bodySmall),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'it',
                                  child: Text('Italian',style: Theme.of(context).textTheme.bodySmall),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                      Card(child:
                      Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          children: [
                            Text('Server URL', style: Theme.of(context).textTheme.bodySmall),
                            TextField(obscureText: false, style: Theme.of(context).textTheme.bodySmall, controller: _serverUrlTextController, decoration: InputDecoration( suffixIcon: IconButton(icon: const Icon(Icons.save), onPressed: (_saveUrl),)),),
                            DropdownButton<String>(
                              value: _font,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _font = newValue;
                                    writeFont(newValue);
                                    setThemes();
                                  });
                                }
                              },
                              items: <DropdownMenuItem<String>>[
                                DropdownMenuItem<String>(
                                  value: 'Inconsolata',
                                  child: Text('Inconsolata', style: Theme.of(context).textTheme.bodySmall),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Roboto',
                                  child: Text('Roboto',style: Theme.of(context).textTheme.bodySmall),
                                ),
                              ],
                            ),
                            Row(children: [
                              TextButton(onPressed: () { setLightTheme(); }, child: Text('Light', style:  Theme.of(context).textTheme.bodySmall),),
                              TextButton(onPressed: () { setDarkTheme(); }, child: Text('Dark', style:  Theme.of(context).textTheme.bodySmall),),

                            ],)
                          ],
                        ),
                      )),
                      Card(child:
                      Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          children: [
                            Text("login_details".localise()),
                            TextField(obscureText: false, style: Theme.of(context).textTheme.bodySmall, controller: _usernameTextController,),
                            TextField(obscureText: true, style:Theme.of(context).textTheme.bodySmall, controller: _passwordTextController, decoration: InputDecoration( suffixIcon: IconButton(icon: const Icon(Icons.save), onPressed: (_login),)),),
                            Row(
                              children: [
                                Text("Launcher:",  style: Theme.of(context).textTheme.bodySmall),
                                Switch(
                                  value: launcher,
                                  onChanged: (value) {
                                    setState(() {
                                      setLauncher(value);
                                      launcher = getLauncher();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),

                      Card(child:
                      Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          children: [
                            Text("advanced".localise()),
                            TextButton(onPressed: () { toggleTheme(); }, child: Text('Toggle Theme', style: Theme.of(context).textTheme.bodySmall)),
                            Row(
                              children: [
                                Text("AutoPlay:",  style: Theme.of(context).textTheme.bodySmall),
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
                                  Text("Report:",  style: Theme.of(context).textTheme.bodySmall),
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
                          ],
                        ),
                      )),
                      Card(child:
                      Padding(
                        padding: EdgeInsets.all(1.w),
                        child: Column(
                          children: [
                            Text("Downloads",  style: Theme.of(context).textTheme.bodySmall),
                            TextButton(onPressed: () { clearCache(); }, child: Text('Clear Cache', style:  Theme.of(context).textTheme.bodySmall)),
                            TextButton(onPressed: () { goToDownloads(); }, child: Text('Downloads', style: Theme.of(context).textTheme.bodySmall)),
                            TextButton(onPressed: () { goToLogBox(); }, child: Text('Log Box', style: Theme.of(context).textTheme.bodySmall)),

                            Text("Cached Songs: $totalCachedFileCount", style: Theme.of(context).textTheme.bodySmall),
                          ]
                      )),
                      )
                    ],
                  ),
                  Text("Version: ${_packageInfo.version}", style: Theme.of(context).textTheme.bodyMedium),

                ],
              ),
            ),

            )
        );
  }
}