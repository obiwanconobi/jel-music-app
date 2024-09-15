import 'package:flutter/material.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/liked_songs.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/liked_controller.dart';
import 'package:jel_music/controllers/music_controller.dart';

class QuickActionsHandler {
  final QuickActions _quickActions = QuickActions();

  void initialize(BuildContext context) {
    _quickActions.initialize((shortcutType) {
      if (shortcutType == 'play_liked_songs') {
        _navigateToLikedSongs(context);
      }
    });
  }

  void _navigateToLikedSongs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LikedSongs(autoPlayAll: true)),
    ).then((_) {
      // This callback will be called after the LikedSongs page is popped
      // You can perform any cleanup or additional actions here if needed
    });
  }
}