import 'package:get_storage/get_storage.dart';

class ApiHelper{


  Future<Map<String, String>> returnJellyfinHeaders()async{
    var deviceId = GetStorage().read('deviceId');
    var accessToken = GetStorage().read('accessToken');
    var baseServerUrl = GetStorage().read('serverUrl');
        Map<String, String> requestHeaders = {
              'Content-type': 'application/json',
              'X-MediaBrowser-Token': '$accessToken',
              'X-Emby-Authorization': 'MediaBrowser Client="Panaudio",Device="Android",DeviceId="$deviceId",Version="10.8.13"'
        };

        return requestHeaders;
  } 


}