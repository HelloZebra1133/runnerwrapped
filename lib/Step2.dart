import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gal/gal.dart';
import 'package:flutter/services.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'audio_manager.dart';

class WrappedScreen extends StatefulWidget {
  final List<List<dynamic>> data;

  WrappedScreen({required this.data});

  @override
  _WrappedScreenState createState() => _WrappedScreenState();
}

class _WrappedScreenState extends State<WrappedScreen> {
  late Map<String, dynamic> stats;
  late AudioPlayer _audioPlayer;
  PageController? _pageController;
  Timer? _timer;
  int _currentSlideIndex = 0;
  final int slideCount = 18; // Adjust this to match the number of slides

  // Create a list of ScreenshotControllers
  final List<ScreenshotController> _screenshotControllers = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    stats = calculateStats(widget.data); // Initialize stats
    _pageController = PageController(); // Initialize the PageController
    _audioPlayer = AudioPlayer(); // Initialize the AudioPlayer
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _startAudio(); // Start the audio when the widget is created
    _startTimer(); // Start the timer for the slides

    // Initialize ScreenshotControllers for each slide
    for (int i = 0; i < slideCount; i++) {
      _screenshotControllers.add(ScreenshotController());
    }
  }




  @override
  void dispose() {
    // Stop and dispose of audio player
    _audioPlayer.stop();
    _audioPlayer.dispose();

    // Cancel the timer
    _timer?.cancel();

    // Dispose the page controller
    _pageController?.dispose();

    super.dispose();
  }

  bool _showWatermark = false;

  Widget buildSlide(String title, String description, String imagePath, int index) {
    return Screenshot(
      controller: _screenshotControllers[index],
      child: Container(
        width: double.infinity, // Ensures the container takes the full width
        height: double.infinity, // Ensures the container takes the full height
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover, // Ensures the image covers the whole container
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            if (_showWatermark)
              Positioned(
                bottom: 10,
                right: 10,
                child: SvgPicture.asset(
                  "assets/code.svg",
                  width: 50, // Optional: Specify size
                  height: 50,
                ),
              ),
          ],
        ),
      ),
    );
  }


  void _stopAudio() async {
    await AudioManager.player.stop();
    setState(() {
      AudioManager.isPlaying = false;
    });
  }

  void _startAudio() async {
    await AudioManager.player.play(AssetSource('space/bg_music.mp3'));
    //AudioManager.player.resume();
    setState(() {
      AudioManager.isPlaying = true;
    });
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel the existing timer if any
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (_currentSlideIndex < slideCount - 1) {
        _currentSlideIndex++;
        _pageController?.animateToPage(
          _currentSlideIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _timer?.cancel();
      }
    });
  }





  Map<String, dynamic> calculateStats(List<List<dynamic>> data) {
    double totalDistance = 0.0;
    double totalSeconds = 0.0;
    int totalTime = 0; // in seconds
    double longestActivity = 0.0;
    double fastestSpeed = 0.0;
    double elevationGain = 0.0;
    double totalCalories = 0;
    double totalSteps = 0;
    print("Data: ${data.length} rows");
    if (data.isNotEmpty) {
      print("First row: ${data[0]}");
    }


    for (var i = 1; i < data.length; i++) { // Start from index 1 to skip header
      var row = data[i];
      double distance = double.tryParse(row[6].toString()) ?? 0.0; // Distance
      double seconds = double.tryParse(row[5].toString()) ??
          0.0; // Seconds Spent
      double speed = double.tryParse(row[19].toString()) ?? 0.0;
      int time = int.tryParse(row[4].toString()) ?? 0; // Elapsed Time
      double elevation = double.tryParse(row[21].toString()) ?? 0.0;
      double calories = double.tryParse(row[34].toString()) ?? 0;
      double steps = double.tryParse(row[85].toString()) ?? 0;
      print("StepsCount: ${steps}");

      totalDistance += distance;
      totalSeconds += seconds;
      totalTime += time;
      if (distance > longestActivity) longestActivity = distance;
      if (speed > fastestSpeed) fastestSpeed = speed;
      elevationGain += elevation;
      totalCalories += calories;
      totalSteps += steps;
      print("Steps: ${totalSteps}");
    }

    return {
      'totalDistance': totalDistance,
      'totalSeconds': totalSeconds,
      'totalTime': (totalSeconds / 60 / 60).toStringAsPrecision(2),
      'longestActivity': longestActivity,
      'fastestSpeed': fastestSpeed,
      'elevationGain': elevationGain,
      'elevationGainmm': (elevationGain * 100 * 10).toInt(),
      'totalCalories': totalCalories.toInt(),
      'totalSteps': totalSteps.toInt(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // Handle back button press here
      print("Back button pressed!");
      setState(() {
        // Return `true` to allow the app to navigate back
        // Return `false` to prevent it
        AudioManager.player.stop();
      });
      return true;
    },
    child: Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentSlideIndex = index;
                });
                _startTimer(); // Reset the timer whenever the user changes the page
              },
              itemCount: slideCount,
              itemBuilder: (context, index) {
                // Replace the embedded PageView with the slide data
                switch (index) {
                  case 0:
                    return buildSlide("", "", "assets/space/1.png", index
                    );
                  case 1:
                    return buildSlide("", "", "assets/space/2.png", index
                    );
                  case 2:
                    return buildSlide("", "", "assets/space/3.png", index
                    );
                  case 3:
                    return buildSlide("", "", "assets/space/4.png", index
                    );
                  case 4:
                    return buildSlide("", "", "assets/space/5.png", index
                    );
                  case 5:
                    return  buildSlide("", "", "assets/space/6.png", index
                    );
                  case 6:
                    return buildSlide("", "", "assets/space/7.png", index
                    );
                  case 7:
                    return buildSlide(
                      "Your 2024 Journey",
                      "You covered ${stats['totalDistance'].toStringAsFixed(2)} km this year.\n\n${calculateMoonDistance(stats['totalDistance'])}",
                      "assets/space/8.png",
                      index,

                    );
                  case 8:
                    return buildSlide(
                      "Time Well Spent",
                      "You spent approximately ${stats['totalTime']} hours moving.\n\n${convertSpeedOfLight(stats['totalSeconds'].toStringAsFixed(0))}",
                      "assets/space/9.png",
                      index,

                    );
                  case 9:
                    return  buildSlide(
                      "Longest Activity",
                      "Your longest single activity was ${stats['longestActivity'].toStringAsFixed(2)} km.\n\n${martianDaysTravel(stats['longestActivity'])}",
                      "assets/space/10.png",
                      index,

                    );
                  case 10:
                    return buildSlide(
                      "Speeding Through",
                      "At your fastest, you reached ${stats['fastestSpeed'].toStringAsFixed(2)} km/h.\n\n${earthVelocitySpeed(stats['fastestSpeed'])}",
                      "assets/space/10.png",
                      index,
                    );
                  case 11:
                    return buildSlide(
                      "Rising High",
                      "You climbed ${stats['elevationGain'].toStringAsFixed(2)} m.\n\n${convertToFamousSpaceships(stats['elevationGain'])}",
                      "assets/space/10.png",
                      index,

                    );
                  case 12:
                    return buildSlide(
                      "Calories Burned",
                      "You burned ${stats['totalCalories']} calories.\n\n${lightPowerComparison(stats['totalCalories'])}",
                      "assets/space/10.png",
                      index,

                    );
                  case 13:
                    return buildSlide(
                      "Stepping Up",
                      "You took an incredible ${stats['totalSteps']} steps.\n\n${spacewalkComparison(stats['totalSteps'])}",
                      "assets/space/10.png",
                      index,

                    );
                  case 14:
                    return  buildSlide("", "", "assets/space/11.png", index);

                  case 15:
                    return buildSlide("", "", "assets/space/12.png", index);
                  case 16:
                    return  buildSlide("", "", "assets/space/13.png", index

                    );
                  case 17:
                    return buildSlide(
                      "Share Your Highlights",
                      "Let the galaxy celebrate your fantastic achievements this year!",
                      "assets/space/10.png",
                      index,

                    );
                  case 18:
                    return buildSlide("I Got Mine, Get Yours!",
                        "https://github.com/HelloZebra1133",
                        "assets/space/10.png",
                  index,
                    );
                  default:
                    return const SizedBox.shrink(); // Fallback for unexpected cases
                }
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                final hasAccess = await Gal.hasAccess(toAlbum: true);
                await Gal.requestAccess(toAlbum: true);

                setState(() {
                  _showWatermark = true;
                });
                // Wait for the next frame to ensure the watermark is rendered
                await Future.delayed(const Duration(milliseconds: 100));

                try {
                  // Capture screenshot
                  Uint8List? imageBytes = await _screenshotControllers[_currentSlideIndex].capture();

                  if (imageBytes != null) {
                    // Save the image to a temporary file
                    final directory = await getTemporaryDirectory();
                    final filePath = '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
                    final file = File(filePath);
                    await file.writeAsBytes(imageBytes);

                    // Save the file to the album
                    await Gal.putImage(filePath, album: 'RunnerWrapped');
                    print("Screenshot saved to gallery");
                  } else {
                    print("Failed to capture screenshot");
                  }
                } catch (e) {
                  print("Error capturing screenshot: $e");
                } finally {
                  // do something to wait for 2 seconds
                  await Future.delayed(const Duration(seconds: 2), (){});
                  setState(() {
                    _showWatermark = false;
                  });
                }
              },
              backgroundColor: Colors.white10,
              child: const Icon(Icons.camera_alt, color: Colors.black),
            ),
          ),


          // LinearProgressBar overlay at the top of the screen
          Positioned(
            top: 36,
            left: 16,
            right: 16,
            child: LinearProgressBar(
              maxSteps: slideCount,
              progressType: LinearProgressBar.progressTypeDots, // Use Dots progress
              currentStep: _currentSlideIndex,
              progressColor: Colors.white,
              backgroundColor: Colors.grey,
              dotsActiveSize: 10.5,
              dotsSpacing: const EdgeInsets.symmetric(horizontal: 5),
            ),
          ),
        ],
      ),
    )
    );
  }




  String calculateMoonDistance(double distance) {
    const moonDistanceKm = 384400; // Average distance from Earth to the Moon
    double fraction = distance / moonDistanceKm;
    return "You're ${(fraction * 100).toStringAsFixed(5)}% of the way to the Moon!";
  }

  String formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return "${hours} hours and ${minutes} minutes";
  }

  String convertToFamousSpaceships(double elevationGain) {
    const Soyuz = 50.0; // Height in meters
    const SaturnV = 110.0; // Height in meters
    const Starship = 120.0; // Height in meters

    if (elevationGain > Starship) {
      double StarshipMultiplier = elevationGain / Starship;
      return "That's ${(StarshipMultiplier).toStringAsFixed(2)}x the height of SpaceX's Starship!";
    } else if (elevationGain > Soyuz) {
      double SoyuzMultiplier = elevationGain / Soyuz;
      return "That's ${(SoyuzMultiplier).toStringAsFixed(2)}x the height of Russia's Soyuz spaceship!";
    } else if (elevationGain > SaturnV) {
      double SaturnVMultiplier = elevationGain / SaturnV;
      return "That's ${(SaturnVMultiplier).toStringAsFixed(2)}x the height of NASA's SaturnV!";
    } else {
      double SoyuzPercent = (elevationGain / Soyuz) * 100;
      return "That's ${(SoyuzPercent).toStringAsFixed(1)}% the height of Russia's Soyuz spaceship!";
    }
  }



  String martianDaysTravel(double distance) {
    const double marsRoverDailyTravel = 0.1; // in km/day

    double longestActivity = stats['longestActivity'];

    double marsRoverDays = longestActivity / marsRoverDailyTravel;

    return
      "That would take a rover ${marsRoverDays.toStringAsFixed(0)} Martian days to match!";
  }

  String earthVelocitySpeed(double speed) {
    const double escapeVelocity = 40270.0; // in km/h

    double fastestSpeed = stats['fastestSpeed'];

    double escapeVelocityPercent = (fastestSpeed / escapeVelocity) * 100;

    return
      "That’s ${escapeVelocityPercent.toStringAsFixed(7)}% of Earth’s escape velocity!";
  }





  String convertSpeedOfLight(String time) {
    const double speedOfLight = 299792.0; // Speed of light in km/s

    double time = stats['totalSeconds'];
    double lightDistance = time * speedOfLight;

    return
      "That’s the time it takes to travel ${(lightDistance/1000000).toStringAsFixed(0)} gigameters at the speed of light!";
  }



  String spacewalkComparison(int steps) {
    const double stepLength = 0.8; // Average step length in meters
    const double spacewalkDistance = 150.0; // Average distance moved during a spacewalk in meters

    double totalDistance = steps * stepLength; // Total distance walked in meters
    double totalSpacewalks = totalDistance / spacewalkDistance; // Equivalent spacewalks

    return "You’ve walked the equivalent of ${totalSpacewalks.toStringAsFixed(1)} spacewalks around the ISS!";
  }

  String lightPowerComparison(int calories) {
    const double caloriesPerHourLight = 8.6; // Calories to power a 10W LED for 1 hour

    double hoursPowered = calories / caloriesPerHourLight; // Total hours of light powered

    return "You’ve burned enough calories to power a 10-watt LED light for ${hoursPowered.toStringAsFixed(1)} hours in space!";
  }
}




