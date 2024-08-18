import 'package:get_storage/get_storage.dart';

class ApiHelper{

  Future<String> returnSubsonicHeaders()async {
    var username = await GetStorage().read('username');
    var password = await GetStorage().read('password');
    Map<String, String> requestHeaders = {
      'u': username,
      'p': password,
      'v': '1.16.1',
      'c': 'curl',
      'f': 'json'
    };


    String test = 'u=$username&p=$password&v=1.16.1&c=curl&f=json&musicFolderId=1';
    return test;
  }


  Future<Map<String, String>> returnJellyfinHeaders()async{
    var deviceId = await GetStorage().read('deviceId');
    var accessToken = await GetStorage().read('accessToken');
    var baseServerUrl = await GetStorage().read('serverUrl');
        Map<String, String> requestHeaders = {
              'Content-type': 'application/json',
              'X-MediaBrowser-Token': '$accessToken',
              'X-Emby-Authorization': 'MediaBrowser Client="Panaudio",Device="Android",DeviceId="$deviceId",Version="10.8.13"'
        };

        return requestHeaders;
  } 


}