import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/download_controller.dart';
import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/isynchelper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/fav_albums.dart';

import '../../handlers/subsonic_handler.dart';
import '../../models/log.dart';

class SyncHelper implements ISyncHelper {
  SongsHelper songsHelper = SongsHelper();
  AlbumsHelper albumsHelper = AlbumsHelper();
  ArtistsHelper artistsHelper = ArtistsHelper();
  JellyfinHandler jellyfinHandler = JellyfinHandler();
  Conversions conversions = Conversions();
  LogHandler logger = LogHandler();

  @override
  runSync(bool check)async{

    var lastSyncRaw = await GetStorage().read('lastSync') ?? DateTime.now().add(Duration(hours:-2)).toString();
    var lastSync = DateTime.parse(lastSyncRaw);

    if(conversions.isMoreThanAnHourBefore(lastSync) || check){

      List<FavAlbums> favAlbums = await getFavouriteAlbums();
      List<String> favArtists = await getFavouriteArtists();
      var songs = await jellyfinHandler.returnSongs();

      try{
        await songsHelper.openBox();
        await songsHelper.addSongsToBox(songs);
      }catch(e){
        logger.addToLog(LogModel(logType: "Error", logMessage: "Error Adding Songs: ${e.toString()}", logDateTime: DateTime.now()));
      }

      await albumsHelper.openBox();
      await artistsHelper.openBox();

      List<Songs> listOfSongs = await songsHelper.returnSongs();

      for(var song in listOfSongs){

        var artist = artistsHelper.returnArtist(song.artist);
        bool artistFavourite = false;
        if(artist == null){
          if(favArtists.contains(song.artist)){
            artistFavourite = true;
          }else{
            artistFavourite = false;
          }
          var artistFull = await jellyfinHandler.returnArtistBio(song.artist);
          var overview = artistFull["Overview"];

          try{
            await artistsHelper.addArtistToBox(Artists(id: song.artistId, name: song.artist, picture: song.artistId, favourite: artistFavourite, overview: overview, playCount: song.playCount));

          }catch(e){
            logger.addToLog(LogModel(logType: "Error", logMessage: "Error Adding ${song.artist} to box: ${e.toString()}", logDateTime: DateTime.now()));
          }

        }else{
          artist.playCount = artist.playCount + song.playCount;

          await artistsHelper.updateArtist(artist);
        }

        var album = albumsHelper.returnAlbum(song.artist, song.album);

        if(album == null){
          bool favourite = false;
          //FavAlbums targetAlbum = FavAlbums(title: song.album, artist: song.artist);
          FavAlbums targetAlbum = FavAlbums(artist: song.artist, title: song.album);


          bool containsTargetAlbum = favAlbums.contains(targetAlbum);
          for(var album in favAlbums){
            if(album.artist == song.artist && album.title == song.album){
              containsTargetAlbum = true;
              break;
            }
          }
          if (containsTargetAlbum) {
            favourite = true;
          } else {

          }


          var imgUrl = await getImageUrl(song.albumId);
          try{
            //here
            await albumsHelper.addAlbumToBox(Albums(id: song.albumId, name: song.album, picture: imgUrl, favourite: favourite, artist: song.artist, artistId: song.artistId, year: song.year.toString(), playCount: song.playCount));

          }catch(e){
            logger.addToLog(LogModel(logType: "Error", logMessage: "Error Adding Album ${song.album} to box: ${e.toString()}", logDateTime: DateTime.now()));
          }

        }else{
          album.playCount = album.playCount + song.playCount;
          albumsHelper.updateAlbum(album, album.key);
        }

      }

      logger.addToLog(LogModel(logType: "Error", logMessage: "Sync Complete", logDateTime: DateTime.now()));
      await GetStorage().write('lastSync', DateTime.now().toString());

    }

  }

  @override
  openBox() async{
    await songsHelper.openBox();
  }

  @override
  clearSongs() {
    songsHelper.clearSongs();
  }


  Future<List<FavAlbums>> getFavouriteAlbums()async{
    List<FavAlbums> favAlbums = [];
    var albumsRaw = await albumsHelper.getAlbumDataFavourite();

    if(albumsRaw == null){
      List<FavAlbums> albums = [];
      return albums;
    }

    for(var album in albumsRaw["Items"]){

      try{
        favAlbums.add(FavAlbums(title: album["Name"], artist: album["AlbumArtist"]));
      }catch(e){
        //log error
        logger.addToLog(LogModel(logType: "Error", logDateTime: DateTime.now(), logMessage: "Failed to get favourite albums: $e"));

      }
    }
    return favAlbums;
  }

  Future<List<String>> getFavouriteArtists()async{
    List<String> favArtists = [];
    dynamic artistRaw;
    try{
      artistRaw = await artistsHelper.getArtistDataFavourite();
    }catch(e){
      logger.addToLog(LogModel(logType: "Error", logDateTime: DateTime.now(), logMessage: "Failed to get favourite artists: $e"));
    }

    try{
      for(var artist in artistRaw["Items"]){
        favArtists.add(artist["Name"]);
      }
      return favArtists;
    }catch(e){
      logger.addToLog(LogModel(logType: "Error", logDateTime: DateTime.now(), logMessage: "Failed to get favourite artists: $e"));
    }
    return [];
  }

  getImageUrl(String Id)async{
    var baseServerUrl = await GetStorage().read('serverUrl');
    var imgUrl = "$baseServerUrl/Items/$Id/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
    return imgUrl;
  }


}