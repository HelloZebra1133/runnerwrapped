// Screen 2: Wrapped Highlights
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:runnerwrapped/slide_exporter.dart';

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
  final SlideExportService slideExportService = SlideExportService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    stats = calculateStats(widget.data); // Initialize stats
    _pageController = PageController(); // Initialize the PageController
    _audioPlayer = AudioPlayer(); // Initialize the AudioPlayer
    _startAudio(); // Start the audio when the widget is created
    _startTimer(); // Start the timer for the slides
    // Create GlobalKeys for all slides
    for (int i = 0; i < slideCount; i++) {
      slideExportService.addSlideKey(GlobalKey());  // Dynamically add a new GlobalKey for each slide
    }


  }
  // Add GlobalKeys for slides 7 to 13
  final Map<int, GlobalKey> _captureKeys = {
    for (int i = 7; i <= 13; i++) i: GlobalKey(),
  };

  void _startAudio() async {
    await _audioPlayer.setSource(AssetSource('space/bg_music.mp3'));
    Source audioSource;
    _audioPlayer.resume();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel the existing timer if any
    _timer = Timer.periodic(Duration(seconds: 6), (_) {
      if (_currentSlideIndex < slideCount - 1) {
        _currentSlideIndex++;
        _pageController?.animateToPage(
          _currentSlideIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _timer?.cancel();
      }
    });
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

  // Initialize slideKeys with the required number of GlobalKeys
  List<GlobalKey<State<StatefulWidget>>> slideKeys = List.generate(18, (index) => GlobalKey<State<StatefulWidget>>());




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The PageView fills the entire screen
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
                    return RepaintBoundary(
                      key: slideKeys[index], // Use index instead of i
                      child: buildSlide("", "", "assets/space/1.png", index),
                    );
                  case 1:
                    return RepaintBoundary(
                        key: slideKeys[index], // Use index instead of i
                        child: buildSlide("", "", "assets/space/2.png", index)
                    );
                  case 2:
                    return RepaintBoundary(
                  key: slideKeys[index], // Use index instead of i
                        child: buildSlide("", "", "assets/space/3.png", index)
                    );
                  case 3:
                    return RepaintBoundary(
                  key: slideKeys[index], // Use index instead of i
                        child: buildSlide("", "", "assets/space/4.png", index)
                    );
                  case 4:
                    return RepaintBoundary(
                  key: slideKeys[index], // Use index instead of i
                        child: buildSlide("", "", "assets/space/5.png", index)
                    );
                  case 5:
                    return RepaintBoundary(
                  key: slideKeys[index], // Use index instead of i
                        child: buildSlide("", "", "assets/space/6.png", index)
                    );
                  case 6:
                    return RepaintBoundary(
                  key: slideKeys[index], // Use index instead of i
                      child: buildSlide("", "", "assets/space/7.png", index)
                    );
                  case 7:
                    return RepaintBoundary(
                  key: slideKeys[index], // Use index instead of i
                      child: slideExportService.buildSlide(
                      "Your 2024 Journey",
                      "You covered ${stats['totalDistance'].toStringAsFixed(2)} km this year.\n\n${calculateMoonDistance(stats['totalDistance'])}",
                      "assets/space/8.png",
                      index,
                    )
                    );
                  case 8:
                    return RepaintBoundary(
                  key: slideKeys[index], // Use index instead of i
                      child: slideExportService.buildSlide(
                      "Time Well Spent",
                      "You spent approximately ${stats['totalTime']} hours moving.\n\n${convertSpeedOfLight(stats['totalSeconds'].toStringAsFixed(0))}",
                      "assets/space/9.png",
                      index,
                    )
                    );
                  case 9:
                    return RepaintBoundary(
                        key: slideKeys[index], // Use index instead of i
                        child: slideExportService.buildSlide(
                      "Longest Activity",
                      "Your longest single activity was ${stats['longestActivity'].toStringAsFixed(2)} km.\n\n${martianDaysTravel(stats['longestActivity'])}",
                      "assets/space/10.png",
                      index,
                )
                    );
                  case 10:
                    return RepaintBoundary(
                      key: slideKeys[index], // Use index instead of i
                      child: slideExportService.buildSlide(
                      "Speeding Through",
                      "At your fastest, you reached ${stats['fastestSpeed'].toStringAsFixed(2)} km/h.\n\n${earthVelocitySpeed(stats['fastestSpeed'])}",
                      "assets/space/10.png",
                      index,
                      )
                    );
                  case 11:
                    return RepaintBoundary(
                      key: slideKeys[index], // Use index instead of i
                      child: slideExportService.buildSlide(
                      "Rising High",
                      "You climbed ${stats['elevationGain'].toStringAsFixed(2)} m.\n\n${convertToFamousSpaceships(stats['elevationGain'])}",
                      "assets/space/10.png",
                      index,
                      )
                    );
                  case 12:
                    return RepaintBoundary(
                      key: slideKeys[index], // Use index instead of i
                      child: slideExportService.buildSlide(
                      "Calories Burned",
                      "You burned ${stats['totalCalories']} calories.\n\n${lightPowerComparison(stats['totalCalories'])}",
                      "assets/space/10.png",
                      index,
                      )
                    );
                  case 13:
                    return RepaintBoundary(
                        key: slideKeys[index], // Use index instead of i
                        child: slideExportService.buildSlide(
                      "Stepping Up",
                      "You took an incredible ${stats['totalSteps']} steps.\n\n${spacewalkComparison(stats['totalSteps'])}",
                      "assets/space/10.png",
                      index,
                        )
                    );
                  case 14:
                    return RepaintBoundary(
                        key: slideKeys[index], // Use index instead of i
                        child: buildSlide("", "", "assets/space/11.png", index)
                    );
                  case 15:
                    return RepaintBoundary(
                        key: slideKeys[index], // Use index instead of i
                        child: buildSlide("", "", "assets/space/12.png", index)
                    );
                  case 16:
                    return RepaintBoundary(
                      key: slideKeys[index], // Use index instead of i
                      child: buildSlide("", "", "assets/space/13.png", index
                      )
                    );
                  case 17:
                    return RepaintBoundary(
                      key: slideKeys[index], // Use index instead of i
                      child: buildSlide(
                      "Share Your Highlights",
                      "Let the galaxy celebrate your fantastic achievements this year!",
                      "assets/space/10.png",
                      index,
                      )
                    );
                  case 18:
                    return RepaintBoundary(
                        key: slideKeys[index], // Use index instead of i
                        child: slideExportService.buildSlide("I Got Mine, Get Yours!",
                        "https://github.com/HelloZebra1133",
                        "assets/space/10.png",
                  index,
                        )
                    );
                  default:
                    return SizedBox.shrink(); // Fallback for unexpected cases
                }
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                await slideExportService.captureSlidesAndExport();
              },
              child: Icon(Icons.share),
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
              dotsSpacing: EdgeInsets.symmetric(horizontal: 5),
            ),
          ),
        ],
      ),
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



  Widget buildSlide(String title, String subtitle, String imagePath, int i) {
    GlobalKey _key = GlobalKey();
      return RepaintBoundary(
          key: _key,  // Ensure GlobalKey is assigned here
          child:  Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath), // Use AssetImage for local assets
          fit: BoxFit.cover, // Adjusts how the image is displayed
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            title,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Ensure text is visible on the background
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 20, color: Colors.grey[300]), // Adjust text color for visibility
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ));
  }


}




