import 'package:get_it/get_it.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/playlists.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/repos/jellyfin_repo.dart';

class JellyfinHandler{

  late JellyfinRepo jellyfinRepo;
  
  JellyfinHandler(){
    jellyfinRepo = GetIt.instance<JellyfinRepo>();
  }

  Future<List<Playlists>> returnPlaylists()async{
    var playlistsRaw = await jellyfinRepo.getPlaylists();
    List<Playlists> playlistList = [];
    for(var playlistRaw in playlistsRaw["Items"]){
      playlistList.add(Playlists(id: playlistRaw["Id"], name: playlistRaw["Name"], runtime: playlistRaw["RunTimeTicks"].toString()));
    }
    return playlistList;
  }

  Future<List<Songs>> returnSongsFromPlaylist(String playlistId)async{
    Mappers mapper = Mappers();
    var songsRaw = await jellyfinRepo.getPlaylistSongs(playlistId);

    var mappedSongs = mapper.returnSongFromRaw(songsRaw);
    return mappedSongs;
  }
  

}