import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/fav_albums.dart';


class SyncHelper{
  SongsHelper songsHelper = SongsHelper();
  AlbumsHelper albumsHelper = AlbumsHelper();
  ArtistsHelper artistsHelper = ArtistsHelper();

  runSync()async{

    List<FavAlbums> favAlbums = [];
    var albumsRaw = await albumsHelper.getAlbumDataFavourite();

    for(var album in albumsRaw["Items"]){
          
      try{
        favAlbums.add(FavAlbums(title: album["Name"], artist: album["AlbumArtist"]));
       }catch(e){
        //log error
      
      }
      
    }

    List<String> favArtists = [];
    var artistRaw = await artistsHelper.getArtistDataFavourite();
    for(var artist in artistRaw["Items"]){
      favArtists.add(artist["Name"]);
    }

    await songsHelper.addSongsToBox();
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

       
        await artistsHelper.addArtistToBox(Artists(id: song.artistId, name: song.artist, picture: song.artistId, favourite: artistFavourite));
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