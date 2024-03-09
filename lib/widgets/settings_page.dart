import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';



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
      }catch(e){
        //log error
      }
      
  }




  _saveUrl() async {

    GetStorage().write('serverUrl', _serverUrlTextController.text);

}

   @override
   void  initState() {
    super.initState();
    GetStorage.init();
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
    helper.getAllArtists();
    albumsHelper.getAllAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B1B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1B1B),
        title: const Center(child: Text("Jel Settings", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      ),
      body:
        Container(
          padding: const EdgeInsets.all(20),
          child: 
            Column(
              children: 
              [
                const Text('Server URL', style: TextStyle(color:Colors.white)),
                TextField(obscureText: false, style: const TextStyle(color:Colors.white), controller: _serverUrlTextController, decoration: InputDecoration( suffixIcon: IconButton(icon: const Icon(Icons.save), onPressed: (_saveUrl),)),),
                TextField(obscureText: false, style: const TextStyle(color:Colors.white), controller: _usernameTextController,),
                TextField(obscureText: false, style: const TextStyle(color:Colors.white), controller: _passwordTextController, decoration: InputDecoration( suffixIcon: IconButton(icon: const Icon(Icons.save), onPressed: (_login),)),),
                TextButton(onPressed: () { sync(); }, child: Text('test', style: TextStyle(color: Colors.white)),)
              ],
            ),
                
   
            )
        );
  }
}