import 'package:flutter/material.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/liked_songs.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/liked_controller.dart';
import 'package:jel_music/controllers/music_controller.dart';

bool _quickActionHandled = false;
class QuickActionsHandler {
  final QuickActions _quickActions = QuickActions();

  void resetBool() {
    _quickActionHandled = false;
  }

  void initialize(BuildContext context) {
    _quickActions.initialize((shortcutType) {

      if(!_quickActionHandled){
        _quickActionHandled = true;
        if (shortcutType == 'play_liked_songs') {
          _navigateToLikedSongs(context);
        }else if (shortcutType == 'play_most_played'){
          _navigateToMostPlayedSongs(context);
        }
      }
    });
  }

  void _navigateToMostPlayedSongs(BuildContext context)async{
    await MusicControllerProvider.of(context, listen: false).mostPlayed();
  }

  void _navigateToLikedSongs(BuildContext context)async {
    await MusicControllerProvider.of(context, listen:false).autoPlay();
  }
}