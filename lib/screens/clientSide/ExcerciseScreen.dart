import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/OfflineVideoModel.dart';
import 'package:gymvisa/services/AuthServices.dart';
import 'package:gymvisa/services/Database_Service.dart';
import 'package:gymvisa/widgets/CustomAppBar.dart';
import 'package:gymvisa/widgets/ManBack.dart';
import 'package:gymvisa/widgets/ManFront.dart';

Map<String, List<OfflineVideo>> cachedOffilneVideos = {};

class ExcerciseScreen extends StatefulWidget {
  const ExcerciseScreen({Key? key}) : super(key: key);

  @override
  State<ExcerciseScreen> createState() => _ExcerciseScreenState();

  static _ExcerciseScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ExcerciseScreenState>();
}


class _ExcerciseScreenState extends State<ExcerciseScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  void nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  void initState() {
    super.initState();
    getCachedVideos();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        color: Color.fromARGB(255, 29, 29, 29),
        title: 'Exercises',
        showBackButton: false,
      ),
      backgroundColor: AppColors.appBackground,
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: AppTheme.getGradientBackground(),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! > 0) {
                previousPage();
              } else if (details.primaryVelocity! < 0) {
                nextPage();
              }
            }
          },
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            children: const [
              ManFront(),
              ManBack(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}



Future<void> getCachedVideos() async {

  // isVideosCached = true;   // Remove it, just for testing purpose  

  if(isVideosCached == true){

        cachedOffilneVideos = {};

    final DefaultCacheManager cacheManager = DefaultCacheManager();
  final fileInfo = await cacheManager.getFileFromCache('videos_cache');

  if (fileInfo != null) {
    try {
      final jsonString = await fileInfo.file.readAsString();
      print('Original JSON String: $jsonString'); 

      final sanitizedString = _sanitizeJsonString(jsonString); 
      print('Sanitized JSON String: $sanitizedString'); 

      if (sanitizedString.isEmpty) {
        print('Sanitized JSON String is empty');
        return; 
      }

      final decodedData = json.decode(sanitizedString);

      if (decodedData != null && decodedData is Map<String, dynamic>) {
        cachedOffilneVideos = {};
        decodedData.forEach((key, value) {
          if (value is List) {
            cachedOffilneVideos[key] = List<OfflineVideo>.from(
              value.map((videoData) => OfflineVideo.fromJson2(videoData)),
            );
          }
        });

        if (cachedOffilneVideos.containsKey('Shoulder') && cachedOffilneVideos['Shoulder']!.isNotEmpty) {
          print('Shoulder video Path: ${cachedOffilneVideos['Shoulder']![0].videoPath}');
        } else {
          print('No videos found for Shoulder');
        }
      } else {
        print('Decoded data is not a valid Map<String, dynamic>');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  } else {
    print('No cache file found');
  }
  }
  else{

    cachedOffilneVideos = {};

    cachedOffilneVideos =
            await Database_Service.getAllCategoryVideos();


  cachedOffilneVideos.forEach((key, value) {
    cachedOffilneVideos[key] = value;
  });

  cacheVideos(cachedOffilneVideos);

  }


  
}

String _sanitizeJsonString(String jsonString) {

  return jsonString.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');


}







