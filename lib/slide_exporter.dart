import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:share_plus/share_plus.dart';

class SlideExportService {
  final List<GlobalKey> slideKeys = [];

  void addSlideKey(GlobalKey key) {
    slideKeys.add(key);
  }

  Future<Uint8List> captureSlide(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception("RenderRepaintBoundary not found for key: $key");
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw Exception("Error capturing slide: $e");
    }
  }

  Future<void> captureSlidesAndExport() async {
    try {
      List<Uint8List> capturedFrames = [];

      // Ensure that all slides are captured
      for (int i = 7; i <= 13; i++) {
        if (i < slideKeys.length) {
          Uint8List frame = await captureSlide(slideKeys[i]);
          capturedFrames.add(frame);
        } else {
          print("No key for slide index $i");
        }
      }

      final tempDir = await getTemporaryDirectory();
      for (int i = 0; i < capturedFrames.length; i++) {
        File('${tempDir.path}/frame_$i.png').writeAsBytesSync(capturedFrames[i]);
      }

      final outputVideoPath = '${tempDir.path}/slides_video.mp4';
      final framePattern = '${tempDir.path}/frame_%d.png';

      // Run FFmpeg to create a video from the frames
      final ffmpegResult = await FFmpegKit.execute(
          '-framerate 1 -i $framePattern -c:v libx264 -r 30 -pix_fmt yuv420p $outputVideoPath');

      // Check if the FFmpeg execution was successful
      final returnCode = await ffmpegResult.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        // If the video is successfully created, share it
        if (File(outputVideoPath).existsSync()) {
          await Share.shareXFiles([XFile(outputVideoPath)], text: 'Check out my 2024 highlights!');
        } else {
          print("Video file not created: $outputVideoPath");
        }
      } else {
        // Handle error if FFmpeg execution failed
        final output = await ffmpegResult.getOutput();
        print("FFmpeg execution failed with return code: $returnCode");
        print("FFmpeg error: $output");
      }

      // Cleanup temporary files
      for (int i = 0; i < capturedFrames.length; i++) {
        File('${tempDir.path}/frame_$i.png').deleteSync();
      }

    } catch (e) {
      print('Error during slide capture/export: $e');
    }
  }



  Widget buildSlide(String title, String subtitle, String imagePath, int index) {
    if (index >= slideKeys.length) {
      throw Exception("No GlobalKey found for slide index $index");
    }

    return RepaintBoundary(
      key: slideKeys[index],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
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
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 20, color: Colors.grey[300]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
