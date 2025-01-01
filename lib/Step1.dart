import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart' as FilePickerDep;
import 'package:fit_tool/fit_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Step2.dart';
import 'audio_manager.dart';


class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (AudioManager.isPlaying) {
// Stop and dispose of audio player
      AudioManager.player.stop();
      AudioManager.player.dispose();
      AudioManager.isPlaying = false;
    }
  }

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted ||
          await Permission.mediaLibrary.isGranted) {
        print("Storage permission granted.");
      } else {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.mediaLibrary,
        ].request();

        if (statuses[Permission.storage]!.isGranted ||
            statuses[Permission.mediaLibrary]!.isGranted) {
          print("Storage permission granted.");
        } else {
          print("Storage permission denied.");
        }
      }
    } else {
      print("This platform does not require storage permissions.");
    }
  }

  Future<void> pickFile(BuildContext context) async {
    await requestStoragePermission();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FilePickerDep.FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      Directory extractDir = await setupExtractionDirectory();

      // Start processing with a loading indicator
      setState(() {
        isProcessing = true;
      });

      try {
        List<List<dynamic>> data = await processZip(filePath, extractDir);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WrappedScreen(data: data),
          ),
        );
      } catch (e) {
        print("Error processing ZIP: $e");
      } finally {
        setState(() {
          isProcessing = false;
        });
      }
    } else {
      print("No file selected.");
    }
  }

  Future<List<List<dynamic>>> processZip(String filePath, Directory extractionDir) async {
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    List<List<dynamic>> parsedData = [];
    final totalFiles = archive.length;
    int processedFiles = 0;

    for (final file in archive) {
      if (file.isFile) {
        if (file.name.endsWith('.csv') && file.name.contains('activities')) {
          final extracted = file.content as List<int>;
          final csvContent = utf8.decode(extracted);
          parsedData.addAll(const CsvToListConverter(eol: "\n").convert(csvContent));
        } else if (file.isFile && file.name.endsWith('.fit.gz')) {
          final decompressedBytes = const GZipDecoder().decodeBytes(file.content as List<int>);
          final fitFilePath = '${extractionDir.path}/${file.name.replaceAll('.gz', '')}';
          await File(fitFilePath).writeAsBytes(decompressedBytes);
          await parseFitFile(fitFilePath);
        }
      }

      // Update progress
      processedFiles++;
      progressNotifier.value = processedFiles / totalFiles;
    }

    if (parsedData.isEmpty) {
      throw Exception("No valid files found in the ZIP archive.");
    }

    return parsedData;
  }

  Future<Directory> setupExtractionDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final extractionDir = Directory('${tempDir.path}');
    if (!await extractionDir.exists()) {
      await extractionDir.create(recursive: true);
    }
    return extractionDir;
  }

  Future<void> parseFitFile(String fitFilePath) async {
    final file = File(fitFilePath);
    final bytes = await file.readAsBytes();
    final fitFile = FitFile.fromBytes(bytes);

    final csvData = const ListToCsvConverter().convert(fitFile.toRows());

    final csvFilePath = fitFilePath.replaceAll('.fit', '.csv');
    await File(csvFilePath).writeAsString(csvData);

    print("Parsed FIT file saved as CSV: $csvFilePath");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, progress, child) {
                if (isProcessing) {
                  return Column(
                    children: [
                      Text("${(progress * 280).toStringAsFixed(0)}% completed", style: const TextStyle(color: Colors.white),),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            ElevatedButton(
              onPressed: isProcessing ? null : () => pickFile(context),
              child: Text(isProcessing ? "Processing..." : "Upload Strava ZIP"),
            ),
            const SizedBox(height: 200,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        const Text(
          "Made by HelloZebra1133",
          style: TextStyle(color: Colors.white
          ),
        ),
          Text(
            "🦓",
            style: GoogleFonts.notoColorEmoji(
              textStyle: const TextStyle(color: Colors.white, letterSpacing: .5),
            ),
          ),
      ]
        ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  // Opens the GitHub repo link
                  launchUrl(Uri.parse("https://github.com/HelloZebra1133"));
                },
                child: const Text(
                  "GitHub Profile",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  // Opens the GitHub repo link
                  launchUrl(Uri.parse("https://github.com/HelloZebra1133/runnerwrapped?tab=readme-ov-file#usage-instructions"));
                },
                child: const Icon(
                  Icons.question_mark,
                  color: Colors.blue,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),


    );
  }
}
