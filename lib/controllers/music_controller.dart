import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/ioclient.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/log.dart';
import 'package:jel_music/models/stream.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as p;

import '../hive/classes/songs.dart';



class MusicController extends BaseAudioHandler with ChangeNotifier {
  final AudioPlayer _advancedPlayer = AudioPlayer(
    audioLoadConfiguration: const AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: Duration(seconds: 60),
        maxBufferDuration: Duration(seconds: 300),
        prioritizeTimeOverSizeThresholds: true,
      ),),
  );
  final StreamController<Duration> _durationController = BehaviorSubject();
  final StreamController<Duration> _bufferController = BehaviorSubject();
  var logger = GetIt.instance<LogHandler>();
  Mappers mapper = Mappers();

  // StreamController<Duration> _bufferedDurationController = BehaviorSubject();
  SongsHelper songsHelper = SongsHelper();
  ArtistsHelper artistsHelper = ArtistsHelper();
  AlbumsHelper albumsHelper = AlbumsHelper();
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
  String? tempCodec;
  String? tempBitrate;
  String? tempBitdepth;
  String? tempSampleRate;
  bool? tempDownloaded;
  String? tempDuration = "00:00";
  bool? isShuffle;
  bool npChange = true;
  IndexedAudioSource? currentSource;
  String baseServerUrl = "";
  List<IndexedAudioSource>? currentQueue = [];
  int currentIndexSource = 0;
  String lastUpdateSong = "";
  bool lastUpdateStatus = false;
  List<MediaItem> artistMediaItemList = [];
  List<MediaItem> albumsMediaItemList = [];

//android auto menu
  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    loadArtists();
    loadAlbums();
    // This is where you define your menu structure
    switch (parentMediaId) {
      case AudioService.browsableRootId:
      // Return your main menu items here
        return [
          const MediaItem(
            id: 'songs',
            title: 'Songs',
            playable: false,
          ),
          const MediaItem(
            id: 'artists',
            title: 'Artists',
            playable: false,
          ),
          const MediaItem(
            id: 'albums',
            title: 'Albums',
            playable: false
          )

        ];
      case 'songs':
        return [
          const MediaItem(
            id: 'liked_songs',
            title: 'Liked Songs',
            playable: true,
          ),
          const MediaItem(
            id: 'most_played',
            title: 'Most Played',
            playable: true,
          ),
        ];
      case 'artists':
        return artistMediaItemList;
      case 'albums':
        return albumsMediaItemList;
      default:
        return [];
    }
  }



  @override
    Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    // This method is likely to be called by Android Auto
    final mediaItem = await getMediaItem(mediaId);

    if(mediaItem == null){
      var idAlbumArtist = mediaId.split('|');
      if(idAlbumArtist[0] == "artist"){
        logger.addToLog(LogModel(logType: "Error",logMessage: "Playing from null case. artist: ${idAlbumArtist[1]}", logDateTime: DateTime.now()));
        await playAllSongsFromArtist(idAlbumArtist[1]);
      }else {
        //play album
        logger.addToLog(LogModel(logType: "Error",logMessage: "Playing album", logDateTime: DateTime.now()));
        await playSongsInAlbum(idAlbumArtist[1], idAlbumArtist[2]);
      }
    }else if(mediaItem.id == "liked_songs"){
      logger.addToLog(LogModel(logType: "Error",logMessage: "Trying to play liked songs from Android Auto", logDateTime: DateTime.now()));
      await _autoPlay();
    }else if(mediaItem.id == "most_played"){
      await mostPlayed();
    }else{
      var idAlbumArtist = mediaId.split('|');
      if(idAlbumArtist[0] == "artist"){
        logger.addToLog(LogModel(logType: "Error",logMessage: "Playing from else case. artist: ${mediaItem.artist}", logDateTime: DateTime.now()));
        await playAllSongsFromArtist(idAlbumArtist[1]);
      }else {
        //play album
        logger.addToLog(LogModel(logType: "Error",logMessage: "Playing album", logDateTime: DateTime.now()));
        await playSongsInAlbum(mediaItem.artist!, mediaItem.title);
      }

    }
  }

  @override
  Future<MediaItem?> getMediaItem(String mediaId) async {
    // Implement this method to return the MediaItem for a given ID
    switch (mediaId) {
      case 'songs':
        return const MediaItem(
          id: 'songs',
          title: 'Songs',
          playable: false,
        );
      case 'liked_songs':
        return const MediaItem(
          id: 'liked_songs',
          title: 'Liked Songs',
          playable: true,
        );
      case 'most_played':
        return const MediaItem(
          id: 'most_played',
          title: 'Most Played',
          playable: true,
        );
      default:
         var idAlbumArtist = mediaId.split('|');
         logger.addToLog(LogModel(logType: "Error",logMessage: "Getting MediaItem: $mediaId", logDateTime: DateTime.now()));
         if(idAlbumArtist[0] == "artist"){
           logger.addToLog(LogModel(logType: "Error",logMessage: "Artist Media Item: ${idAlbumArtist[1]}", logDateTime: DateTime.now()));
           return artistMediaItemList.where((element) => element.id == mediaId).singleOrNull;
        }else if(idAlbumArtist[0] == "album"){
           logger.addToLog(LogModel(logType: "Error",logMessage: "Album Media Item: ${idAlbumArtist[1]} - ${idAlbumArtist[2]}", logDateTime: DateTime.now()));
           return albumsMediaItemList.where((element) => element.id == mediaId).singleOrNull;
        }
        return null;
    }
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'favourite':
        return await updateCurrentSongFavStatus();
      default:
        return super.customAction(name, extras);
    }
  }


  var playlist = ConcatenatingAudioSource(
    // Start loading next item just before reaching it
    useLazyPreparation: true,
    // Customise the shuffle algorithm
    //   shuffleOrder: DefaultShuffleOrder(),
    // Specify the playlist items
    children: [
    ],
  );

  int? currentTicks;
  AudioHandler? _audioHandler;

  Future<void> initAudioService() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _audioHandler ??= await AudioService.init(
      builder: () => this,
      config: AudioServiceConfig(
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: false,
          androidNotificationChannelName: "Playback",
          androidNotificationChannelId: "com.pansoft.panaudio.channel.audio"
      ),
    );
  }




  MusicController(){
    logger.openBox();
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

    _advancedPlayer.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
      if (e is PlatformException) {
        logger.addToLog(LogModel(logType: "Error",logMessage: e.message, logDateTime: DateTime.now()));
        nextSong();
      } else {
        print('An error occurred: $e');
      }
    });

    _advancedPlayer.playbackEventStream.listen((event) async {
      final prevState = playbackState.valueOrNull;
      final prevIndex = prevState?.queueIndex;
      final prevItem = mediaItem.valueOrNull;
      final currentState = _transformEvent(event);
      final currentIndex = currentState.queueIndex;




      if (playbackState.valueOrNull != null &&
          playbackState.valueOrNull?.processingState !=
              AudioProcessingState.idle &&
          playbackState.valueOrNull?.processingState !=
              AudioProcessingState.completed) {
      }

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
      currentTicks = position.inMicroseconds * 10;
    });

    _advancedPlayer.bufferedPositionStream.listen((position){
      _bufferController.add(position);
    });


    _advancedPlayer.currentIndexStream.listen((event) {
      setUiElements();
      setDownloaded(currentSource!.tag.id);
      // _updatePlaybackProgress();
      _startPlaybackProgress();
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
    return const MediaItem(id: "", title: "");
  }


  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_advancedPlayer.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
        //MediaControl.custom(androidIcon: 'favourite', label: 'favourite', name: 'favourite')
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


  _playbackPausePlay(bool pause)async{
    var playbackLog = GetStorage().read('playbackReporting') ?? false;
    if(playbackLog) {
      var userId = await GetStorage().read('userId');
      JellyfinHandler jellyfinHandler = JellyfinHandler();
      String current = currentSource!.tag.id;
      bool playing = playbackState.valueOrNull?.playing ?? false;
      await jellyfinHandler.updatePlaybackProgress(
          current, userId, pause, currentTicks!);
    }
  }

  _startPlaybackProgress()async{
    var playbackLog = GetStorage().read('playbackReporting') ?? false;
    if(playbackLog) {
      var userId = await GetStorage().read('userId');
      JellyfinHandler jellyfinHandler = JellyfinHandler();
      String current = currentSource!.tag.id;
      bool playing = playbackState.valueOrNull?.playing ?? false;
      await jellyfinHandler.startPlaybackReporting(current, userId);
    }
  }

  _updatePlaybackProgress()async{
    var playbackLog = GetStorage().read('playbackReporting') ?? false;
    if(playbackLog){
      var userId = await GetStorage().read('userId');
      JellyfinHandler jellyfinHandler = JellyfinHandler();
      String current = currentSource!.tag.id;
      bool playing = playbackState.valueOrNull?.playing ?? false;


      if(playbackState.valueOrNull?.playing == true){
        if(lastUpdateStatus == false || lastUpdateSong != current){
          lastUpdateStatus = true;
          lastUpdateSong = current;
          await jellyfinHandler.startPlaybackReporting(current, userId);
        }else{
          //update song progress
          print('test');
          await jellyfinHandler.updatePlaybackProgress(current, userId, false, currentTicks!);
        }

      }else if(playbackState.valueOrNull?.playing == false){
        if(lastUpdateStatus == true){
          lastUpdateStatus = false;
          lastUpdateSong = current;
          //await jellyfinHandler.stopPlaybackReporting(current, userId);
          await jellyfinHandler.updatePlaybackProgress(current, userId, true, currentTicks!);
        }

      }

    }

  }


  @override
  Future<void> play()async{
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause],
    ));
    _advancedPlayer.play();
    await _playbackPausePlay(false);
    // await _updatePlaybackProgress();
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
    await _playbackPausePlay(true);
    //   await _updatePlaybackProgress();
    notifyListeners();
  }

  @override
  Future<void> skipToNext()async{
    await nextSong();
    // await _updatePlaybackProgress();
  }

  @override
  Future<void> skipToPrevious()async{
    await previousSong();
    //  await _updatePlaybackProgress();
  }


  Stream<Duration> get durationStream => _durationController.stream;
  Stream<Duration> get bufferStream => _bufferController.stream;

  void setDownloaded(String id)async{
    var documentsDar = await getApplicationDocumentsDirectory();

    final directory = Directory(p.joinAll([documentsDar.path, 'panaudio/cache/']));
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    final files = directory.listSync();



    if(files.where((element) => element.path.contains(id)).isNotEmpty){
      await songsHelper.openBox();
      await songsHelper.setDownloaded(id);
    }
  }


  void onInit()async{
    currentSource = getCurrentSong();

    baseServerUrl = GetStorage().read('serverUrl') ?? "";

  }

  loadArtists()async{

      await logger.addToLog(LogModel(logType: "Error",logMessage: "Loading artists for android auto", logDateTime: DateTime.now()));
      await artistsHelper.openBox();
      var artistList = artistsHelper.returnFavouriteArtistsByPlayCount();

      artistMediaItemList.clear();
      for(var artist in artistList){
        var pictureUrl = "$baseServerUrl/Items/${artist.id}/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
        artistMediaItemList.add(MediaItem(id: 'artist|${artist.name}',title: artist.name, artUri: Uri(path: pictureUrl), playable: true));
      }
      await logger.addToLog(LogModel(logType: "Error",logMessage: "Artist Count: ${artistMediaItemList.length}", logDateTime: DateTime.now()));



  }

  loadAlbums()async{
    await albumsHelper.openBox();
    albumsMediaItemList.clear();
    var albumsList = albumsHelper.returnFavouriteAlbumsByPlayCount();
    for(var album in albumsList){
      albumsMediaItemList.add(MediaItem(id: 'album|${album.artist}|${album.name}',artist: album.artist, title: album.name, artUri: Uri(path: album.picture), playable: true));
    }
  }

  playSongsInAlbum(String artist, String album)async{
    logger.addToLog(LogModel(logType: "Error",logMessage:"Trying to play album from android auto: $album for $artist}", logDateTime: DateTime.now()));

    try{
      await songsHelper.openBox();
      var songs = songsHelper.returnSongsFromAlbum(artist, album);
      List<StreamModel> streamModels = await mapper.convertHiveSongsToModelSongs(songs);
      await addPlaylistToQueue(streamModels);
    }catch(e){
      logger.addToLog(LogModel(logType: "Error",logMessage: e.toString(), logDateTime: DateTime.now()));
    }
  }

  playAllSongsFromArtist(String artist)async{
    logger.addToLog(LogModel(logType: "Error",logMessage:"Trying to play Artist from android auto: $artist}", logDateTime: DateTime.now()));

    try{
      await songsHelper.openBox();
      var songs = songsHelper.returnSongsForArtist(artist);
      List<StreamModel> streamModels = await mapper.convertHiveSongsToModelSongs(songs);
      await addPlaylistToQueue(streamModels);
    }catch(e){
      logger.addToLog(LogModel(logType: "Error",logMessage: e.toString(), logDateTime: DateTime.now()));
    }


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

  getSongUrl(String id)async{
    var serverType = await GetStorage().read('ServerType');
    if(serverType == "Jellyfin"){
      await getToken();
      return "$baseServerUrl/Items/$id/Download?api_key=$accessToken";
      //return "$baseServerUrl/Audio/$id";
    }else if (serverType == "Subsonic"){
      return "$baseServerUrl/rest/download?id=$id";
    }
  }

  Future<bool> downloadSong(String id, String codec)async{
    var documentsDar = await getApplicationDocumentsDirectory();

    baseServerUrl = await GetStorage().read('serverUrl');
    String songUrl = await getSongUrl(id);
    var result = await cacheFile(url: songUrl, path: p.joinAll([documentsDar.path, 'panaudio/cache/', '$id.$codec']));

    if(result){
      setDownloaded(id);
      return true;
    }else{
      return false;
    }
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
    await _updatePlaybackProgress();
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

  mostPlayed()async{
    try{
      await songsHelper.openBox();
      var songsRaw = await songsHelper.returnMostPlayedSongs();
      var songs = await mapper.convertHiveSongsToModelSongs(songsRaw);
      addPlaylistToQueue(songs);
    }catch(e){
      print(e.toString());
    }
  }

  autoPlay()async{
    await _autoPlay();
  }

  _autoPlay()async{

    try{
      await songsHelper.openBox();
      var songsRaw = await songsHelper.returnFavouriteSongs();
      var songs = await mapper.convertHiveSongsToModelSongs(songsRaw);
      addPlaylistToQueue(songs);
    }catch(e){
      print(e.toString());
    }

  }


  //play
  resume() async {
    await getToken();
    baseServerUrl = GetStorage().read('serverUrl');

    String baseUrl = await getSongUrl(tempId!);
    List<String> timeParts = tempDuration!.split(':');

    var documentsDar = await getApplicationDocumentsDirectory();

    AudioSource source = LockCachingAudioSource(Uri.parse(baseUrl),
        cacheFile: File(p.joinAll([documentsDar.path, 'panaudio/cache/', '$tempId.$tempCodec'])),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: tempId!,
          // Metadata to display in the notification:
          album: tempArtist ?? "Error",
          title: tempAlbum ?? "Error",
          extras: {"favourite": tempFavourite ?? false,
            "bitrate": tempBitrate ?? "",
            "bitdepth": tempBitdepth ?? "",
            "samplerate": tempSampleRate ?? "",
            "codec": tempCodec ?? "",
            "downloaded": tempDownloaded ?? "",
          },
          artUri: Uri.parse(tempPicture!),
          duration: Duration(minutes: int.parse(timeParts[0]), seconds: int.parse(timeParts[1])),
        ));

    try{
      List<AudioSource> list = [];
      list.add(source);
      playlist.addAll(list);
      if(playlist.children.isNotEmpty){
        var countPlaylist = playlist.length;
        //_advancedPlayer.dynamicSet(url: baseUrl);

        _advancedPlayer.setAudioSource(playlist, initialIndex: countPlaylist-1);
        playlistPlay();
        await _updatePlaybackProgress();

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
        extras: {'favourite': tempFavourite ?? false,
          "bitrate": "",
          "bitdepth": "",
          "samplerate": "",
          "codec": "",
          "downloaded": "",
        },
        artUri: Uri.parse(tempPicture ?? ('https://error.com')),
      ),
    );


    return _advancedPlayer.sequenceState?.currentSource ?? ss;

  }


  previousSong() async{

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
    if(_advancedPlayer.currentIndex == (currentQueue!.length - 1) && GetStorage().read('autoPlay')){
      await _autoPlay();
    }else{
      _advancedPlayer.seekToNext();
    }

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
    tempCodec = value.codec;
    tempBitdepth = value.bitdepth.toString();
    tempBitrate = value.bitrate.toString();
    tempSampleRate = value.samplerate.toString();
    tempDownloaded = value.downloaded;

    _addSongToQueue(value);
  }

  _addSongToQueue(StreamModel stream)async{
    var documentsDar = await getApplicationDocumentsDirectory();
    String pictureUrl = stream.picture!;
    String id = stream.id!;
    String codec = stream.codec!;
    //   String baseUrl = "$baseServerUrl/Items/$id/Download?api_key=$accessToken";
    String baseUrl = await getSongUrl(id);
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
      cacheFile: File(p.joinAll([documentsDar.path, 'panaudio/cache/', '$id.$codec'])),
      tag: MediaItem(
        // Specify a unique ID for each media item:
        id: stream.id!,
        // Metadata to display in the notification:
        album: stream.composer ?? "Error",
        title: stream.title ?? "Error",
        extras: {
          "favourite": stream.isFavourite,
          "bitrate": stream.bitrate.toString(),
          "bitdepth": stream.bitdepth.toString(),
          "samplerate": stream.samplerate.toString(),
          "codec": stream.codec,
          "downloaded": stream.downloaded,
        },
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
      tempCodec = value.codec;
      tempBitdepth = value.bitdepth.toString();
      tempBitrate = value.bitrate.toString();
      tempSampleRate = value.samplerate.toString();
      tempDownloaded = value.downloaded;
      resume();
    }else{
      var documentsDar = await getApplicationDocumentsDirectory();
      String pictureUrl = value.picture!;
      String id = value.id!;
      //   String baseUrl = "$baseServerUrl/Items/$id/Download?api_key=$accessToken";
      String baseUrl = await getSongUrl(id);
      List<String> timeParts = value.long!.split(':');
      AudioSource source = LockCachingAudioSource(Uri.parse(baseUrl),
        cacheFile: File(p.joinAll([documentsDar.path, 'panaudio/cache/', '$id.$tempCodec'])),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: value.id!,
          // Metadata to display in the notification:
          album: value.composer ?? "Error",
          title: value.title ?? "Error",
          extras: {
            "favourite": value.isFavourite,
            "bitrate": value.bitrate.toString(),
            "bitdepth": value.bitdepth.toString(),
            "samplerate": value.samplerate.toString(),
            "codec": value.codec,
            "downloaded": value.downloaded,

          },
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
    _advancedPlayer.play();
    await _updatePlaybackProgress();
    isPlaying = _advancedPlayer.playing;
    getQueue();
    notifyListeners();
  }

  addPlaylistToQueue(List<StreamModel> listOfStreams, {int index = 0}) async{
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
      String codec = stream.codec!;
      //    String baseUrl = "$baseServerUrl/Audio/$id/stream";
      String baseUrl = await getSongUrl(id);
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
        cacheFile: File(p.joinAll([documentsDar.path, 'panaudio/cache/', '$id.$codec'])),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: stream.id!,
          // Metadata to display in the notification:
          album: stream.composer ?? "Error",
          title: stream.title ?? "Error",
          extras: {
            "favourite": stream.isFavourite,
            "bitrate": stream.bitrate.toString(),
            "bitdepth": stream.bitdepth.toString(),
            "samplerate": stream.samplerate.toString(),
            "codec": stream.codec,
            "downloaded": stream.downloaded,

          },
          duration: Duration(minutes: int.parse(timeParts[0]), seconds: int.parse(timeParts[1])),
          artUri: Uri.parse(pictureUrl),

        ),);

      sourceList.add(source);

    }
    playlist.addAll(sourceList);
    _advancedPlayer.setAudioSource(playlist, initialIndex: index, initialPosition: Duration.zero);

    if(_isPlaying == false){
      _isPlaying = !_isPlaying;
      setUiElements();
    }
    currentSource = getCurrentSong();
    await playlistPlay();
    setUiElements();
  }

  void shuffleQueue()async{
    playlist.children.shuffle();
    setUiElements();

  }


  _getData() async {
    return GetStorage().read('accessToken');
  }

}