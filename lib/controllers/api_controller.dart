import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';


class ApiController{


  getSimilarItems(String itemId)async{
      var accessToken = await GetStorage().read('accessToken');
      var baseServerUrl = await GetStorage().read('serverUrl');
        try {
              Map<String, String> requestHeaders = {
              'Content-type': 'application/json',
              'X-MediaBrowser-Token': '$accessToken',
              'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
            };
          String url = "$baseServerUrl/Items/$itemId/Similar?limit=10";
          http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
          if (res.statusCode == 200) {
            return json.decode(res.body);
          }
        } catch (e) {
          rethrow;
        }
  }

    Future<void> updateFavouriteStatus(String input, bool current) async {

       String itemId = '${input.substring(0, 8)}-${input.substring(8, 12)}-${input.substring(12, 16)}-${input.substring(16, 20)}-${input.substring(20)}';

        if(!current){
          favouriteItem(itemId);
        }else{
          unFavouriteItem(itemId);
        }
    }

    Future<void> favouriteItem(String itemId) async {
        var accessToken = GetStorage().read('accessToken');
              var baseServerUrl = GetStorage().read('serverUrl');
                
                  Map<String, String> requestHeaders = {
                  'Content-type': 'application/json',
                  'X-MediaBrowser-Token': '$accessToken',
                  'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
                };
              String url = "$baseServerUrl/Users/D8B7A1C3-8440-4C88-80A1-04F7119FAA7A/FavoriteItems/$itemId";
              
              http.Response res = await http.post(Uri.parse(url), headers: requestHeaders);
              if (res.statusCode == 200) {
                return json.decode(res.body);
              }
    }

    Future<void> unFavouriteItem(String itemId) async {
        var accessToken = await GetStorage().read('accessToken');
              var baseServerUrl = await GetStorage().read('serverUrl');
                
                  Map<String, String> requestHeaders = {
                  'Content-type': 'application/json',
                  'X-MediaBrowser-Token': '$accessToken',
                  'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
                };
              String url = "$baseServerUrl/Users/D8B7A1C3-8440-4C88-80A1-04F7119FAA7A/FavoriteItems/$itemId";
              
              http.Response res = await http.delete(Uri.parse(url), headers: requestHeaders);
              if (res.statusCode == 200) {
                return json.decode(res.body);
              }
    }

}