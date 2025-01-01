// Create a global AudioPlayer instance in a separate file (e.g., audio_manager.dart)
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioPlayer player = AudioPlayer();
  static bool isPlaying = false;
}
