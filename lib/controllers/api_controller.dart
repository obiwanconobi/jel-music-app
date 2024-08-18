import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/apihelper.dart';
import 'package:jel_music/models/log.dart';


class ApiController{
  ApiHelper apiHelper = ApiHelper();
   var logger = GetIt.instance<LogHandler>();

  jellyfinLogin() async {
    try {
      var username = GetStorage().read('username');
      var password = GetStorage().read('password');
      var baseServerUrl = GetStorage().read('serverUrl');

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
        GetStorage().write('accessToken', json.decode(res.body)["AccessToken"]);
         logger.addToLog(LogModel(logMessage: "Login Successful", logDateTime:DateTime.now(), logType: "INFO"));

      } else {
        logger.addToLog(LogModel(logMessage: "Failed o login with username: $username at the url: $baseServerUrl", logDateTime:DateTime.now(), logType: "ERROR"));
        //log error
      }

    } catch (e) {
      //log error
    }
  }

  getUser()async{
  
    var baseServerUrl = await GetStorage().read('serverUrl');
    var accessToken = await GetStorage().read('accessToken');
    var deviceId = GetStorage().read('deviceId');
        try {

           //var requestHeaders = apiHelper.returnJellyfinHeaders();
               Map<String, String> requestHeaders = {
              'Content-type': 'application/json',
              'X-MediaBrowser-Token': '$accessToken',
              'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
            };
          String url = "$baseServerUrl/Users/me";
          http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
          if (res.statusCode == 200) {
            return json.decode(res.body);
          }
        } catch (e) {
           logger.addToLog(LogModel(logMessage: "Failed to get user. $e", logDateTime:DateTime.now(), logType: "ERROR"));
           
          rethrow;
        }
  }

  getSimilarItems(String itemId)async{
      var accessToken = await GetStorage().read('accessToken');
      var baseServerUrl = await GetStorage().read('serverUrl');
        try {
          var requestHeaders = await apiHelper.returnJellyfinHeaders();
          String url = "$baseServerUrl/Items/$itemId/Similar?limit=10";
          http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
          if (res.statusCode == 200) {
            return json.decode(res.body);
          }
        } catch (e) {
           logger.addToLog(LogModel(logMessage: "Failed to get similar items. $e", logDateTime:DateTime.now(), logType: "ERROR"));
          rethrow;
        }
  }

}