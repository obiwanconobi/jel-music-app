import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jel_music/models/stream.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio_cache/just_audio_cache.dart';
import 'package:path/path.dart' as p;



class MusicController extends ChangeNotifier{
  final AudioPlayer _advancedPlayer = AudioPlayer();
  StreamController<Duration> _durationController = BehaviorSubject();
  StreamController<Duration> _bufferedDurationController = BehaviorSubject();
 
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
 String? tempDuration = "00:00";
 bool? isShuffle;
 bool npChange = true;
 IndexedAudioSource? currentSource;
 String baseServerUrl = "";
  List<IndexedAudioSource>? currentQueue = [];
  int currentIndexSource = 0;

 // final _cache = JustAudioCache;  
     
  
   var playlist = ConcatenatingAudioSource(
    // Start loading next item just before reaching it
    useLazyPreparation: true,
    // Customise the shuffle algorithm
 //   shuffleOrder: DefaultShuffleOrder(),
    // Specify the playlist items
    children: [
    ],
); 

  MusicController(){

     // final _cache = JustAudioCache();

     

    _advancedPlayer.positionStream.listen((position) {
    _durationController.add(position);
    });

    _advancedPlayer.currentIndexStream.listen((event) {

          setUiElements();
    });

    _advancedPlayer.playingStream.listen((event){
            setUiElements();
    });

    _advancedPlayer.bufferedPositionStream.listen((position){
      print("buffered: "+  position.toString());      
    });


  }    
  
  Stream<Duration> get durationStream => _durationController.stream;

  

    void onInit()async{
      currentSource = getCurrentSong();
     
      baseServerUrl = GetStorage().read('serverUrl') ?? "";

      
        
    }



    clearCache()async{
     await _advancedPlayer.clearCache();
    }

    returnPlaylist()async{
      if(_advancedPlayer.audioSource?.sequence == null)return null;
      
      return _advancedPlayer.audioSource!.sequence;
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
    //AudioSource dd = LockCachingAudioSource(uri)
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

  seekInSong(Duration seek)async{
    await _advancedPlayer.seek(seek, index: _advancedPlayer.currentIndex); 
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
  //  String baseUrl = "$baseServerUrl/Audio/$tempId/stream";
    List<String> timeParts = tempDuration!.split(':');

 //   await _advancedPlayer.cacheFile(url: baseUrl);
  //  await Future.delayed(Duration(seconds: 5), () {});
   // var path = await _advancedPlayer.getCachedPath(url: baseUrl);

    final cacheDir = File('/panaudio/Cache/');
    if(!cacheDir.existsSync()){

    }

    var documentsDar = await getApplicationDocumentsDirectory();

    

    final files = Directory(p.joinAll([documentsDar.path, 'panaudio/cache/'])).listSync();

    for(var file in files){
      print(file.path);
    }

    AudioSource source = LockCachingAudioSource(Uri.parse(baseUrl),
                  cacheFile: File(p.joinAll([documentsDar.path, 'panaudio/cache/', '$tempId.flac'])),
                  tag: MediaItem(
                    // Specify a unique ID for each media item:
                    id: tempId!,
                    // Metadata to display in the notification:
                    album: tempArtist ?? "Error",
                    title: tempAlbum ?? "Error",
                    extras: {"favourite": tempFavourite ?? false},
                    artUri: Uri.parse(tempPicture!),
                    duration: Duration(minutes: int.parse(timeParts[0]), seconds: int.parse(timeParts[1])),
                  ));

  //  String baseUrl = "https://localhost:44312/api/audio-dl";
    var sourceold = AudioSource.uri(
                  Uri.parse(baseUrl),
                  tag: MediaItem(
                    // Specify a unique ID for each media item:
                    id: tempId!,
                    // Metadata to display in the notification:
                    album: tempArtist ?? "Error",
                    title: tempAlbum ?? "Error",
                    extras: {"favourite": tempFavourite ?? false},
                    artUri: Uri.parse(tempPicture!),
                    duration: Duration(minutes: int.parse(timeParts[0]), seconds: int.parse(timeParts[1])),
                  ),
                );
  
      try{
        List<AudioSource> list = [];
        list.add(source);
        playlist.addAll(list);
        if(!playlist.children!.isEmpty){
          var countPlaylist = playlist.length;
          //_advancedPlayer.dynamicSet(url: baseUrl);
          
          _advancedPlayer.setAudioSource(playlist, initialIndex: countPlaylist-1);
            playlistPlay();

        }else{
          playPause(false, false);
        }

        playPause(false,true);
        

      }on PlayerException {
       //log error
      }on PlayerInterruptedException {
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
                    duration: const Duration(seconds: 0),
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
    tempFavourite = value.isFavourite;
    tempDuration = value.long;
    _addSongToQueue(value);
  }

   _addSongToQueue(StreamModel stream)async{
     var documentsDar = await getApplicationDocumentsDirectory();
      String pictureUrl = stream.picture!;
      String id = stream.id!;
   //   String baseUrl = "$baseServerUrl/Items/$id/Download?api_key=$accessToken";
   String baseUrl = "$baseServerUrl/Audio/$id/stream";
      List<String> timeParts = stream.long!.split(':');
      var sourceold = AudioSource.uri(
                        Uri.parse(baseUrl),
                        tag: MediaItem(
                          // Specify a unique ID for each media item:
                          id: stream.id!,
                          // Metadata to display in the notification:
                          album: stream.composer ?? "Error",
                          title: stream.title ?? "Error",
                          extras: {"favourite": stream.isFavourite},
                          duration: Duration(minutes: int.parse(timeParts[0]), seconds: int.parse(timeParts[1])),
                          artUri: Uri.parse(pictureUrl),
                        ),
                      ); 

    AudioSource source = LockCachingAudioSource(Uri.parse(baseUrl),
                  cacheFile: File(p.joinAll([documentsDar.path, 'panaudio/cache/', '$id.flac'])),
                  tag: MediaItem(
                          // Specify a unique ID for each media item:
                          id: stream.id!,
                          // Metadata to display in the notification:
                          album: stream.composer ?? "Error",
                          title: stream.title ?? "Error",
                          extras: {"favourite": stream.isFavourite},
                          duration: Duration(minutes: int.parse(timeParts[0]), seconds: int.parse(timeParts[1])),
                          artUri: Uri.parse(pictureUrl),
                        ),);                  

    playlist.add(source);      
  }


  void playSong(StreamModel value){
    
    tempId = value.id;
    tempAlbum = value.title;
    tempArtist = value.composer;
    tempPicture = value.picture;
    tempFavourite = value.isFavourite;
    tempDuration = value.long;
    resume();
  }

  void clearQueue(){
    playlist.clear();
    setUiElements();
  //  queue.clear();
  }

  playlistPlay()async{
    await _advancedPlayer.play();
    isPlaying = _advancedPlayer.playing;
    getQueue();
    notifyListeners();
  }

  addPlaylistToQueue(List<StreamModel> listOfStreams) async{
     var documentsDar = await getApplicationDocumentsDirectory();
    List<AudioSource> sourceList = [];
    int count = playlist.children.length;
  
      if(accessToken == null){
            await getToken();
      }

      for(var stream in listOfStreams){
              String pictureUrl = stream.picture!;
              String id = stream.id!;
              String baseUrl = "$baseServerUrl/Audio/$id/stream";
            //  String baseUrl = "$baseServerUrl/Items/$id/Download?api_key=$accessToken";
              List<String> timeParts = stream.long!.split(':');
              var sourceold = AudioSource.uri(
                        Uri.parse(baseUrl),
                        tag: MediaItem(
                          // Specify a unique ID for each media item:
                          id: stream.id!,
                          // Metadata to display in the notification:
                          album: stream.composer ?? "Error",
                          title: stream.title ?? "Error",
                          extras: {"favourite": stream.isFavourite},
                          duration: Duration(minutes: int.parse(timeParts[0]), seconds: int.parse(timeParts[1])),
                          artUri: Uri.parse(pictureUrl),
                        ),
                      ); 

              AudioSource source = LockCachingAudioSource(Uri.parse(baseUrl),
                  cacheFile: File(p.joinAll([documentsDar.path, 'panaudio/cache/', '$id.flac'])),
                  tag: MediaItem(
                          // Specify a unique ID for each media item:
                          id: stream.id!,
                          // Metadata to display in the notification:
                          album: stream.composer ?? "Error",
                          title: stream.title ?? "Error",
                          extras: {"favourite": stream.isFavourite},
                          duration: Duration(minutes: int.parse(timeParts[0]), seconds: int.parse(timeParts[1])),
                          artUri: Uri.parse(pictureUrl),
                        ),);        

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