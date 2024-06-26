import 'package:get_it/get_it.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/models/playlists.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/repos/jellyfin_repo.dart';

class JellyfinHandler{

  late JellyfinRepo jellyfinRepo;
  Conversions conversions = Conversions();
  Mappers mapper = Mappers();
  
  JellyfinHandler(){
    jellyfinRepo = GetIt.instance<JellyfinRepo>();
  
  }




  updateFavouriteStatus(String itemId, bool current)async{
    await jellyfinRepo.updateFavouriteStatus(itemId, current);
  }

  returnArtistBio(String artistName)async{
    return await jellyfinRepo.getArtistBio(artistName);
  }


  Future<List<Album>>  returnLatestAlbums()async{
    var albumsRaw =  await jellyfinRepo.getLatestAlbums();
    return await mapper.mapAlbumFromRaw(albumsRaw);
  }

  Future<List<Artists>> fetchArtists()async{

      var artistRaw = await jellyfinRepo.getArtistData();
      

      List<Artists> artistList = [];

      for(var artist in artistRaw["Items"]){  
        String test = artist["Name"];
          if(test.contains('blink')){
          
          }    
          artistList.add(Artists(id: artist["Id"], name: artist["Name"], favourite: artist["UserData"]["IsFavorite"], picture: artist["Id"]));
      }
      return artistList;
  }

  Future<List<Playlists>> returnPlaylists()async{
    var playlistsRaw = await jellyfinRepo.getPlaylists();
    List<Playlists> playlistList = [];
    for(var playlistRaw in playlistsRaw["Items"]){
      
      playlistList.add(Playlists(id: playlistRaw["Id"], name: playlistRaw["Name"], runtime: conversions.returnTicksToTimestampString(playlistRaw["RunTimeTicks"] ?? 0)));
    }
    return playlistList;
  }

  Future<List<Songs>> returnSongsFromPlaylist(String playlistId)async{
    var songsRaw = await jellyfinRepo.getPlaylistSongs(playlistId);
    var mappedSongs = await mapper.mapSongFromRaw(songsRaw["Items"]);
    return mappedSongs;
  }

  addSongToPlaylist(String songId, String playlistId)async{
    await jellyfinRepo.addSongToPlaylist(songId, playlistId);
  }

  deleteSongFromPlaylist(String songId, String playlistId)async{
    await jellyfinRepo.deleteSongFromPlaylist(songId, playlistId);
  }

  startPlaybackReporting(String songId, String userId)async{
    await jellyfinRepo.startPlaybackReporting(songId, userId);
  }

  stopPlaybackReporting(String songId, String userId)async{
    await jellyfinRepo.stopPlaybackReporting(songId, userId);
  }
  

}