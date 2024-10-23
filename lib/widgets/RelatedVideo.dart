import 'package:flutter/material.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/OfflineVideoModel.dart';
import 'package:gymvisa/screens/clientSide/OfflineVideos.dart';

class RelatedVideo extends StatefulWidget {
  final String videoCategory;
  final String videoTitle;
  final String videoDuration;
  final String videoDescription;
  final String videoURL;
  final String videoPath;
  final List<OfflineVideo>? relatedVideosList;
  final bool isPlaying; // New parameter

  const RelatedVideo({
    Key? key,
    required this.videoCategory,
    required this.videoTitle,
    required this.videoDuration,
    required this.videoDescription,
    required this.videoURL,
    required this.videoPath,
    required this.relatedVideosList,
    this.isPlaying = false, 
  }) : super(key: key);

  @override
  State<RelatedVideo> createState() => _RelatedVideoState();
}

class _RelatedVideoState extends State<RelatedVideo> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.92,
      height: screenHeight * 0.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color:  const Color(0xFF2A2A2A),
        border: Border.all(
          color: widget.isPlaying ? AppColors.appNeon : const Color(0xFF2A2A2A),
          width: 1,
        ), 
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                child: Container(
                  width: screenWidth * 0.09,
                  height: screenHeight * 0.05,
                  child:
                      Image.asset("lib/assets/image47.png", fit: BoxFit.cover),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      widget.videoTitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: AppColors.appTextColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      widget.videoDuration,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: AppColors.appTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Container(
                  width: screenWidth * 0.1,
                  height: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Center(
                    child: IconButton(
                      iconSize: screenWidth * 0.05, 
                      icon: Icon(Icons.play_arrow),
                      color: AppColors.appNeon, 
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfflineVideos(
                              videoCategory: widget.videoCategory,
                              mainVideoURL: widget.videoURL,
                              videoPath: widget.videoPath,
                              excerciseDescription: widget.videoDescription,
                              relatedVideosList: widget.relatedVideosList,
                              videoTitle: widget.videoTitle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

