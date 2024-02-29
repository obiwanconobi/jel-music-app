import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jel_music/models/stream.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get_storage/get_storage.dart';



class MusicController extends ChangeNotifier{
  final AudioPlayer _advancedPlayer = AudioPlayer();
  
  bool _isPlaying = false;
  List<StreamModel> queue = [];
  int currentStreamIndex = 0;
 // bool get isPlaying => _isPlaying;
 bool? isPlaying;
 String? accessToken;
 bool isCompleted = true;
 String? tempId;
 String? tempArtist;
 String? tempAlbum;
 String? tempPicture;
 bool? tempFavourite;
 bool? isShuffle;
 bool npChange = true;
 IndexedAudioSource? currentSource;
 String baseServerUrl = "";
  List<IndexedAudioSource>? currentQueue = [];
 

   var playlist = ConcatenatingAudioSource(
    // Start loading next item just before reaching it
    useLazyPreparation: true,
    // Customise the shuffle algorithm
 //   shuffleOrder: DefaultShuffleOrder(),
    // Specify the playlist items
    children: [
    ],
); 


    void onInit()async{
      currentSource = getCurrentSong();
     
      baseServerUrl = GetStorage().read('serverUrl');

       /*  _advancedPlayer.playerStateStream.listen((playerState) {
          if (playerState.processingState == ProcessingState.completed) {
              setUiElements();
          }
      }); */
    }
    

    

    void endOfSong() async{
      //setUiElements();
    }
  
    getToken() async{
    accessToken ??= await _getData();
    }

  //the bool is for wether the command comes from the play/pause button or from the queue
  void playPause(bool play, bool ignore) {

    //_isPlaying = !_isPlaying;

    if(!ignore){
      if(_advancedPlayer.audioSource == null){
      _advancedPlayer.setAudioSource(playlist);
      }
    
      isPlaying = _advancedPlayer.playing;
      if(play){
        if(isPlaying!){
        _advancedPlayer.pause();
        
        }else{
        _advancedPlayer.play();
        }
      }else{
        //  _advancedPlayer.stop();
          _advancedPlayer.play();
      }
    }
    setUiElements();
    
  }

  getQueue(){
    currentQueue  = _advancedPlayer.sequenceState?.effectiveSequence;
    //setUiElements();
  }

  updateCurrentSongFavStatus(){
    _advancedPlayer.sequenceState?.currentSource!.tag.extras["favourite"] = !_advancedPlayer.sequenceState?.currentSource!.tag.extras["favourite"];
    setUiElements();
  }

  setUiElements() async{
    currentSource = getCurrentSong();
    npChange = !npChange;
    isPlaying = _advancedPlayer.playing;
     await Future.delayed(const Duration(milliseconds: 60));
    notifyListeners();
  }

 
  //play
  resume() async {
    await getToken();
    baseServerUrl = GetStorage().read('serverUrl');
    String baseUrl =  "$baseServerUrl/Items/$tempId/Download?api_key=$accessToken";

    var source = AudioSource.uri(
                  Uri.parse(baseUrl),
                  tag: MediaItem(
                    // Specify a unique ID for each media item:
                    id: tempId!,
                    // Metadata to display in the notification:
                    album: tempArtist ?? "Error",
                    title: tempAlbum ?? "Error",
                    extras: {"favourite": tempFavourite ?? false},
                    artUri: Uri.parse(tempPicture!),
                  ),
                );
 
      try{
        List<AudioSource> list = [];
        list.add(source);
        playlist.addAll(list);
        if(_advancedPlayer.playing){
          var countPlaylist = playlist.length;
          _advancedPlayer.setAudioSource(playlist, initialIndex: countPlaylist-1);
            playlistPlay();

        }else{
          playPause(false, false);
        }

        playPause(false,true);
        

      }on PlayerException catch(e){
       //log error
      }on PlayerInterruptedException catch(e){
        //log error
      }

    }

  

  IndexedAudioSource? getCurrentSong(){

    IndexedAudioSource ss = AudioSource.uri(
                  Uri.parse("www.test.com"),
                  tag: MediaItem(
                    // Specify a unique ID for each media item:
                    id: "TT",
                    // Metadata to display in the notification:
                    album: tempArtist ?? "Error",
                    title: tempAlbum ?? "Error",
                    displayDescription: tempPicture ??  ("error"),
                    extras: {'favourite': tempFavourite ?? false},
                    artUri: Uri.parse(tempPicture ?? ('https://error.com')),
                  ),
                );


    return _advancedPlayer.sequenceState?.currentSource ?? ss;
    
  }
  

  void previousSong() async{
    
    _advancedPlayer.seekToPrevious();
    setUiElements();

  }

  void seekSong(int index) async{
   if(!_advancedPlayer.playing){
    _advancedPlayer.play();
    _advancedPlayer.seek(Duration.zero, index: index);
   }else{
    _advancedPlayer.seek(Duration.zero, index: index);
   }
   setUiElements();
    
  }

  void nextSong() async{
    _advancedPlayer.seekToNext();
    setUiElements();
  }

  void addNextInQueue(StreamModel value){
    queue.insert(1, value);
    setUiElements();
  }

  void addToQueue(StreamModel value){
    
    tempId = value.id;
    tempAlbum = value.title;
    tempArtist = value.composer;
    tempPicture = value.picture;
    resume();
  }

  void clearQueue(){
    queue.clear();
  }

  playlistPlay()async{
    await _advancedPlayer.play();
    isPlaying = _advancedPlayer.playing;
    getQueue();
    notifyListeners();
  }

  addPlaylistToQueue(List<StreamModel> listOfStreams) async{
    
    List<AudioSource> sourceList = [];
    int count = playlist.children.length;
  
      if(accessToken == null){
            await getToken();
      }

      for(var stream in listOfStreams){
              String pictureUrl = stream.picture!;
              String id = stream.id!;
              String baseUrl = "$baseServerUrl/Items/$id/Download?api_key=$accessToken";
              var source = AudioSource.uri(
                        Uri.parse(baseUrl),
                        tag: MediaItem(
                          // Specify a unique ID for each media item:
                          id: stream.id!,
                          // Metadata to display in the notification:
                          album: stream.composer ?? "Error",
                          title: stream.title ?? "Error",
                          extras: {"favourite": stream.isFavourite},
                          artUri: Uri.parse(pictureUrl),
                        ),
                      ); 

              sourceList.add(source);       
              
      }
    playlist.addAll(sourceList);
    _advancedPlayer.setAudioSource(playlist, initialIndex: count, initialPosition: Duration.zero);
    
    if(_isPlaying == false){
      _isPlaying = !_isPlaying;
      setUiElements();
    }

    await playlistPlay();
   currentSource = getCurrentSong();
    setUiElements();
  }

  void shuffleQueue()async{
   if(_advancedPlayer.shuffleModeEnabled == true){
      await _advancedPlayer.setShuffleModeEnabled(false);      // Shuffle playlist order (true|false)
   }else{
    await _advancedPlayer.setShuffleModeEnabled(true);      // Shuffle playlist order (true|false)
   }
    setUiElements();
   
  }


  _getData() async {
    return GetStorage().read('accessToken');
  }

}