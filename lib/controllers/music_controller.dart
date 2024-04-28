import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jel_music/helpers/ioclient.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/stream.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as p;



class MusicController extends BaseAudioHandler with ChangeNotifier{
  final AudioPlayer _advancedPlayer = AudioPlayer(
    audioLoadConfiguration: const AudioLoadConfiguration(
        androidLoadControl: AndroidLoadControl(
          minBufferDuration: Duration(seconds: 60),
          maxBufferDuration: Duration(seconds: 300),
          prioritizeTimeOverSizeThresholds: true,
        ),),
  );
  StreamController<Duration> _durationController = BehaviorSubject();
 // StreamController<Duration> _bufferedDurationController = BehaviorSubject();
  SongsHelper songsHelper = SongsHelper();
  bool _isPlaying = false;
 // List<StreamModel> queue = [];
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
  

     
  
   var playlist = ConcatenatingAudioSource(
    // Start loading next item just before reaching it
    useLazyPreparation: true,
    // Customise the shuffle algorithm
 //   shuffleOrder: DefaultShuffleOrder(),
    // Specify the playlist items
    children: [
    ],
); 


AudioHandler? _audioHandler;

  

  Future<void> initAudioService() async {
    _audioHandler ??= await AudioService.init(
      builder: () => this,
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: true,
        androidNotificationChannelName: "Playback",
        androidNotificationChannelId: "com.pansoft.panaudio.channel.audio",
        androidNotificationOngoing: true,
      ),
    );
  }  

  MusicController(){

    // final _cache = JustAudioCache();

     initAudioService();

      playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.play],
        processingState: AudioProcessingState.loading,
    ));

      _advancedPlayer.setAudioSource(playlist).then((_) {
      // Broadcast that we've finished loading
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
      ));
    });

    _advancedPlayer.playbackEventStream.listen((event) async {
      final prevState = playbackState.valueOrNull;
      final prevIndex = prevState?.queueIndex;
      final prevItem = mediaItem.valueOrNull;
      final currentState = _transformEvent(event);
      final currentIndex = currentState.queueIndex;

      playbackState.add(currentState);

      if (currentIndex != null) {
        final currentItem = _getQueueItem(currentIndex);

        // Differences in queue index or item id are considered track changes
        if (currentIndex != prevIndex || currentItem.id != prevItem?.id) {
          mediaItem.add(currentItem);

        //  onTrackChanged(currentItem, currentState, prevItem, prevState);
        }
      }
    });

    _advancedPlayer.positionStream.listen((position) {
    _durationController.add(position);
    });

    _advancedPlayer.currentIndexStream.listen((event) {
          setUiElements();
          setDownloaded(currentSource!.tag.id);
     
    });

    _advancedPlayer.playingStream.listen((event){
            setUiElements();
    });

    

    _advancedPlayer.processingStateStream.listen((event){
        setUiElements();
    });


  }    

    MediaItem _getQueueItem(int index) {
    if(playlist.sequence.isNotEmpty){
        return playlist.sequence[index].tag as MediaItem;
    }
    return MediaItem(id: "", title: "");
  }


   PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_advancedPlayer.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_advancedPlayer.processingState]!,
      playing: _advancedPlayer.playing,
      updatePosition: _advancedPlayer.position,
      bufferedPosition: _advancedPlayer.bufferedPosition,
      speed: _advancedPlayer.speed,
      queueIndex: event.currentIndex,
      shuffleMode: _advancedPlayer.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: AudioServiceRepeatMode.none,
    );
  }

   @override
  Future<void> play()async{
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause],
    ));
    _advancedPlayer.play();
   // MusicHelper helper = MusicHelper();
    notifyListeners();
   // helper.setUiElements(false);
  } 

  @override
  Future<void> pause()async{
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.play],
    ));
    _advancedPlayer.pause();
    notifyListeners();
  }
  
  @override
  Future<void> skipToNext()async{
    nextSong();
  }

  @override
  Future<void> skipToPrevious()async{
    previousSong();
  }

  Stream<Duration> get durationStream => _durationController.stream;

    void setDownloaded(String id)async{
       var documentsDar = await getApplicationDocumentsDirectory();
      final files = Directory(p.joinAll([documentsDar.path, 'panaudio/cache/'])).listSync();

      if(files.where((element) => element.path.contains(id)).isNotEmpty){
        await songsHelper.openBox();
        await songsHelper.setDownloaded(id);
        await songsHelper.closeBox();
      }
    }


    void onInit()async{
      currentSource = getCurrentSong();
     
      baseServerUrl = GetStorage().read('serverUrl') ?? "";

      
        
    }

    deleteDownloadedSong(String id)async{
      
    }

    Future<bool> cacheFile({required String url, String? path}) async {
    var openDir = await getApplicationDocumentsDirectory();
    final dirPath = path ?? openDir.path;
    final storedPath = await IoClient.download(url: url, path: dirPath);
    if (storedPath != null) {
      return true;
    }
    return false;
  }

    downloadSong(String id)async{
      var documentsDar = await getApplicationDocumentsDirectory();
      await getToken();
      baseServerUrl = GetStorage().read('serverUrl');
      String songUrl =  "$baseServerUrl/Items/$id/Download?api_key=$accessToken";
      var result = await cacheFile(url: songUrl, path: p.joinAll([documentsDar.path, 'panaudio/cache/', '$id.flac']));

      if(result)setDownloaded(id);
    }


    clearCache()async{
     
     
    }

    returnPlaylist()async{
      if(_advancedPlayer.audioSource?.sequence == null)return null;
      
      return _advancedPlayer.audioSource!.sequence;
    }
    

    

    void endOfSong() async{
      setUiElements();
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
        pause();
        
        }else{
        this.play();
        }
      }else{
        //  _advancedPlayer.stop();
          this.play();
      }
    }
    setUiElements();
    
  }
  
  @override
  Future<void> seek(Duration seek)async{
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

    var documentsDar = await getApplicationDocumentsDirectory();

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
    /* var sourceold = AudioSource.uri(
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
                ); */
  
      try{
        List<AudioSource> list = [];
        list.add(source);
        playlist.addAll(list);
        if(playlist.children.isNotEmpty){
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

  nextSong() async{
    _advancedPlayer.seekToNext();
    setUiElements();
  }

  void addNextInQueue(StreamModel value){
   // queue.insert(1, value);
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
    /*   var sourceold = AudioSource.uri(
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
                      );  */

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


  void playSong(StreamModel value)async{
     
    if(playlist.length == 0){
       tempId = value.id;
        tempAlbum = value.title;
        tempArtist = value.composer;
        tempPicture = value.picture;
        tempFavourite = value.isFavourite;
        tempDuration = value.long;
      resume();
    }else{
      var documentsDar = await getApplicationDocumentsDirectory();
      String pictureUrl = value.picture!;
      String id = value.id!;
   //   String baseUrl = "$baseServerUrl/Items/$id/Download?api_key=$accessToken";
        String baseUrl = "$baseServerUrl/Audio/$id/value";
            List<String> timeParts = value.long!.split(':');
         /*    var sourceold = AudioSource.uri(
                              Uri.parse(baseUrl),
                              tag: MediaItem(
                                // Specify a unique ID for each media item:
                                id: value.id!,
                                // Metadata to display in the notification:
                                album: value.composer ?? "Error",
                                title: value.title ?? "Error",
                                extras: {"favourite": value.isFavourite},
                                duration: Duration(minutes: int.parse(timeParts[0]), seconds: int.parse(timeParts[1])),
                                artUri: Uri.parse(pictureUrl),
                              ),
                            );  */

          AudioSource source = LockCachingAudioSource(Uri.parse(baseUrl),
                        cacheFile: File(p.joinAll([documentsDar.path, 'panaudio/cache/', '$id.flac'])),
                        tag: MediaItem(
                                // Specify a unique ID for each media item:
                                id: value.id!,
                                // Metadata to display in the notification:
                                album: value.composer ?? "Error",
                                title: value.title ?? "Error",
                                extras: {"favourite": value.isFavourite},
                                duration: Duration(minutes: int.parse(timeParts[0]), seconds: int.parse(timeParts[1])),
                                artUri: Uri.parse(pictureUrl),
                              ),);                  
        playlist.insert(currentIndexSource+1, source);
    }
    
    
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
    clearQueue();
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
             /*  var sourceold = AudioSource.uri(
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
                      ); */ 

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