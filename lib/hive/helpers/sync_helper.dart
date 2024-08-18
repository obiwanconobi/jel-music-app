import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/fav_albums.dart';

import '../../handlers/subsonic_handler.dart';
import '../../models/log.dart';


class SyncHelper{
  SongsHelper songsHelper = SongsHelper();
  AlbumsHelper albumsHelper = AlbumsHelper();
  ArtistsHelper artistsHelper = ArtistsHelper();
  JellyfinHandler jellyfinHandler = JellyfinHandler();
  LogHandler logger = LogHandler();


  SubsonicHandler testHandler = SubsonicHandler();

  getTest()async{
    var test = await testHandler.getArtists();
    return test;
  }

  Future<List<FavAlbums>> getFavouriteAlbums()async{
    List<FavAlbums> favAlbums = [];
    var albumsRaw = await albumsHelper.getAlbumDataFavourite();

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

  runSync()async{


    List<FavAlbums> favAlbums = await getFavouriteAlbums();
    List<String> favArtists = await getFavouriteArtists();
    var songs = await jellyfinHandler.returnSongs();

    await songsHelper.addSongsToBox(songs);
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
        await artistsHelper.addArtistToBox(Artists(id: song.artistId, name: song.artist, picture: song.artistId, favourite: artistFavourite, overview: overview));
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
         
         await albumsHelper.addAlbumToBox(Albums(id: song.albumId, name: song.album, picture: song.albumId, favourite: favourite, artist: song.artist, artistId: song.artistId, year: song.year.toString()));
      }

      

    }

  }


}