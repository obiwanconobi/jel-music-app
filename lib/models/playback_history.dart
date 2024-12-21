class PlaybackHistory{
  int? PlaybackId;
  String? SongId;
  String? UserId;
  DateTime? PlaybackStart;
  int? Seconds;
  DateTime? PlaybackEnd;


  PlaybackHistory({
    this.PlaybackId,
    this.SongId,
    this.UserId,
    this.PlaybackStart,
    this.Seconds,
    this.PlaybackEnd

  });
}