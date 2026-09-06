import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

class CacheHelper{
  static const _artworkAuthority = 'com.pansoft.jel_music.artwork';

  Future<Uri?> getCachedImage(String imageUrl)async{
    try{
      final fileInfo = await CachedNetworkImageProvider.defaultCacheManager.getFileFromCache(imageUrl);
      if (fileInfo != null) {
        return fileToContentUri(fileInfo.file);
      }

      final file = await CachedNetworkImageProvider.defaultCacheManager.getSingleFile(imageUrl);
      return fileToContentUri(file);

    }catch(e){
      print('Error getting cached image: $e');
      return null;
    }
  }

  Uri fileToContentUri(File file) {
    if (!Platform.isAndroid) return Uri.file(file.path);

    final encodedPath = Uri.encodeComponent(file.absolute.path).replaceAll('+', '%2B');
    return Uri.parse('content://$_artworkAuthority/$encodedPath');
  }
}
