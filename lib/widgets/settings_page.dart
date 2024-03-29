import 'dart:convert';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/sync_helper.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _MyWidgetState();
}



class _MyWidgetState extends State<SettingsPage> {
  final TextEditingController _serverUrlTextController = TextEditingController();
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  AlbumsHelper albumsHelper = AlbumsHelper();
  SyncHelper syncHelper = SyncHelper();
  ApiController apiController = ApiController();
  ArtistsHelper helper = ArtistsHelper();
  _login() async{

      try{
      var username = _usernameTextController.text;
      var password =  _passwordTextController.text;
      var baseServerUrl = _serverUrlTextController.text;
      

      String loginBody = '{"Username": "$username","Pw": "$password"}';

      Map<String, String> requestHeaders = {
       'Content-type': 'application/json',
       'X-Emby-Authorization': 'MediaBrowser Client="Jel Android App",Device="Mobile",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI2",Version="10.8.13"'
     };
      String url = "$baseServerUrl/Users/AuthenticateByName";
      
            http.Response res = await http.post(Uri.parse(url), headers: requestHeaders, body: loginBody);
            if (res.statusCode == 200) {
              
              GetStorage().write('accessToken', json.decode(res.body)["AccessToken"]);
              GetStorage().write('username', username);
              GetStorage().write('password', password);
              
            }else{
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

  _saveUrl() async {

    GetStorage().write('serverUrl', _serverUrlTextController.text);

}

   @override
   void  initState() {
    super.initState();
    GetStorage.init();
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

  void check(){

    var artistList = helper.returnArtists();

    for(var artistr in artistList){
      var artist = artistr.name;
      var id = artistr.id;

    }
  

    var albumsList = albumsHelper.returnAlbums();
    

    for(var album in albumsList){
      var albumname = album.name;
      var artist = album.artist;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
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
                TextButton(onPressed: () { toggleTheme(); }, child: Text('Toggle Theme', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)),)
              ],
            ),
                
   
            )
        );
  }
}