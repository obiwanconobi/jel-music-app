import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

class CacheHelper{
  Future<Uri?> getCachedImage(String imageUrl)async{
    try{
      final fileInfo = await CachedNetworkImageProvider.defaultCacheManager.getFileFromCache(imageUrl);
      if (fileInfo != null) {
        return fileToContentUri(fileInfo.file); //Uri.file(fileInfo.file.path);
      }

      final file = await CachedNetworkImageProvider.defaultCacheManager.getSingleFile(imageUrl);
      return fileToContentUri(fileInfo!.file);

    }catch(e){
      print('Error getting cached image: $e');
      return null;
    }
  }

  Future<Uri?> fileToContentUri(File file) async {
    if (!Platform.isAndroid) return Uri.file(file.path);

    try {
      final channel = const MethodChannel('com.pansoft.jel_music/file_utils');
      final contentUri = await channel.invokeMethod('getContentUri', {
        'filePath': file.path,
        'packageName': 'com.pansoft.jel_music',
      });
      return Uri.parse(contentUri);
    } catch (e) {
      return Uri.file(file.path);
    }
  }


}