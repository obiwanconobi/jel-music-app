import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/songs_list_item_controller.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SongsListItem extends StatefulWidget {
  const SongsListItem({
    super.key,
    required this.songsList,
    required this.index,
  });

  final List<Songs> songsList;
  final int index;

  @override
  State<SongsListItem> createState() => _SongsListItemState();
}

class _SongsListItemState extends State<SongsListItem> {

  var controller = GetIt.instance<SongsListItemController>();




  @override
  void initState(){
    super.initState();

    controller.onInit();

    _loadPlaylists();

  }


  List<PopupMenuEntry<String>> playlistMenuItems = [];

  _loadPlaylists()async{
    playlistMenuItems.clear();
    var playlistsRaw = await controller.returnPlaylists();
    List<PopupMenuEntry<String>> playlistMenus = [];
    for(var playlist in playlistsRaw){
      playlistMenus.add(PopupMenuItem(
        value: playlist.id,
        child: Text(playlist.name!, style: Theme.of(context).textTheme.bodyMedium),
      ));
    }
    playlistMenuItems = playlistMenus;

  }

  StreamModel returnStream(Songs song){
    return StreamModel(id: song.id, composer: song.artist, music: song.id, picture: song.albumPicture, title: song.title, long: song.length, isFavourite: song.favourite, downloaded: song.downloaded, codec: song.codec, bitdepth: song.bitdepth, bitrate: song.bitrate, samplerate: song.samplerate);
  }

  _addToPlaylist(String songId, String playlistId)async{
    var result = await controller.addSongToPlaylist(songId, playlistId);
    if (result == true){
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          maxLines: 2,
          message:
          "added_to_playlist".localise(),
        ),
      );
    }
  }

  _playSong(List<Songs> allSongs, index){
    if(allSongs.isNotEmpty){
      List<StreamModel> playList = [];
      for(var song in allSongs){
        playList.add(returnStream(song));
      }
      MusicControllerProvider.of(context, listen: false).addPlaylistToQueue(playList, index: index);
    }

  }

  _downloadFile(Songs song)async{
    var result = await MusicControllerProvider.of(context, listen: false).downloadSong(song.id!, song.codec!);
    String? title = song.title;
    String? artist = song.artist;
    var newSong = song;
    if(result){
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          maxLines: 2,
          message:
          "Download of $title by $artist Completed",
        ),
      );
      song.downloaded = true;
      var index =  widget.songsList.indexWhere((element) => element.title == title);
      setState(() {
        widget.songsList[index] = song;
      });

    }else{
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          maxLines: 2,
          message:
          "Download of $title by $artist Failed",
        ),
      );
    }
  }

  _favouriteSong(String songId, bool current, String artist, String title, int index)async{
    await controller.favouriteSong(songId, artist, title, current);

    setState(() {
      widget.songsList[index].favourite = !widget.songsList[index].favourite!;
    });

  }


  styleSongLength(String input){
    //This basically checks if the song length is in the format 00:00 or in seconds only. Needs a proper fix but who can be assed
    if(input.contains(':'))return input;

    Duration duration = Duration(seconds: int.parse(input));
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:() => _playSong(widget.songsList, widget.index),
      borderRadius: BorderRadius.all(
        Radius.circular(10.sp),
      ),
      child: Container(
        height: 69.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10.sp),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text('${widget.songsList[widget.index].trackNumber}. ', style: Theme.of(context).textTheme.bodyMedium),
                            Flexible(
                              child: Text(widget.songsList[widget.index].title!,
                                style: Theme.of(context).textTheme.bodyMedium,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis, // Set overflow property
                                maxLines: 1, // Set the maximum number of lines
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Text(styleSongLength(widget.songsList[widget.index].length.toString()), style:  Theme.of(context).textTheme.bodySmall)),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: IconButton(icon: Icon(Icons.download, size: 30, color: ((widget.songsList[widget.index].downloaded ?? false) ? Colors.green : Colors.blueGrey)), onPressed: () { _downloadFile(widget.songsList[widget.index]); }),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child:PopupMenuButton<String>(
                          icon: const Icon(Icons.playlist_add, color: Colors.blueGrey), // Set your desired icon here
                          onSelected: (String value) {
                            _addToPlaylist(widget.songsList[widget.index].id!, value);
                          },
                          itemBuilder: (context) => playlistMenuItems.toList(),
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: IconButton(icon: Icon(Icons.favorite, color: ((widget.songsList[widget.index].favourite ?? false) ? Colors.red : Colors.blueGrey), size:30), onPressed: () {_favouriteSong(widget.songsList[widget.index].id!, widget.songsList[widget.index].favourite!, widget.songsList[widget.index].artist!, widget.songsList[widget.index].title!, widget.index); },))
                    ],
                  ),
                  Divider(color: Theme.of(context).colorScheme.secondary, indent: 40, endIndent: 40,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
