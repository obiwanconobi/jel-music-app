import 'package:get_it/get_it.dart';
import 'package:jel_music/repos/panaudio_repo.dart';

class PanaudioHandler{

  late PanaudioRepo repo;
  PanaudioHandler(){
    repo = GetIt.instance<PanaudioRepo>();
  }

  updateFavouriteStatus(String itemId, bool current)async{
    await repo.updateFavouriteStatus(itemId, !current);
  }

  returnSongs()async{
    return await repo.getSongsDataRaw();
    //return await mapper.mapListSongsFromRaw(songsRaw);
  }

  returnArtist()async{

  }
}