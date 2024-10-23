import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/OfflineVideoModel.dart';
import 'package:gymvisa/screens/clientSide/ExcerciseScreen.dart';
import 'package:gymvisa/widgets/CustomAppBar.dart';
import 'package:gymvisa/widgets/RelatedVideo.dart';
import 'package:gymvisa/widgets/VideoPlayer.dart';

class OfflineVideos extends StatefulWidget {
  final String videoCategory;
  final String mainVideoURL;
  final String videoPath;
  final String excerciseDescription;
  final List<OfflineVideo>? relatedVideosList;
  final String videoTitle;

  const OfflineVideos({
    Key? key,
    required this.videoCategory,
    required this.mainVideoURL,
    required this.videoPath,
    required this.excerciseDescription,
    required this.relatedVideosList,
    required this.videoTitle,
  }) : super(key: key);

  @override
  State<OfflineVideos> createState() => _OfflineVideosState();
}

class _OfflineVideosState extends State<OfflineVideos> {
  String excerciseDescriptionFormatted = '';

  @override
  void initState() {
    excerciseDescriptionFormatted =
        formatDescription(widget.excerciseDescription);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ExcerciseScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          color: Colors.black,
          title: '${widget.videoCategory} Exercise',
          showBackButton: true,
          onBackPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ExcerciseScreen()),
              (route) => false,
            );
          },
        ),
        backgroundColor: AppColors.appBackground,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height + 200,
            decoration: AppTheme.getGradientBackground(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, screenHeight * 0.05, 0, 0),
                    child: VideoPlayerWidget(
                        videoUrl: widget.mainVideoURL,
                        videoPath: widget.videoPath),
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                //       screenHeight * 0.04, screenWidth * 0.05, 0),
                //   child: Text(
                //     '${widget.videoCategory} Training',
                //     style: GoogleFonts.poppins(
                //       color: Colors.white,
                //       fontSize: 22,
                //       fontWeight: FontWeight.w400,
                //     ),
                //     overflow: TextOverflow.ellipsis,
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                      screenHeight * 0.04, screenWidth * 0.05, 0),
                  child: Text(
                    '${widget.videoTitle}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                      screenHeight * 0.02, screenWidth * 0.05, 0),
                  child: Text(
                    excerciseDescriptionFormatted,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w200,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                      screenHeight * 0.05, screenWidth * 0.05, 0),
                  child: Text(
                    'Related Videos:',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 20)),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.relatedVideosList?.length ?? 0,
                    itemBuilder: (context, index) {
                      final video = widget.relatedVideosList?[index];
                      if (video != null) {
                        bool isPlaying = video.videoURL == widget.mainVideoURL;

                        return Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.01,
                              screenHeight * 0.02, 0, screenHeight * 0.01),
                          child: RelatedVideo(
                            videoCategory: video.videoCatagory,
                            videoTitle: video.videoTitle,
                            videoDuration: video.videoDuration,
                            videoURL: video.videoURL,
                            videoPath: video.videoPath,
                            videoDescription: video.videoDescription,
                            relatedVideosList: widget.relatedVideosList,
                            isPlaying: isPlaying, 
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String formatDescription(String description) {
  List<String> parts = description.split('Steps:');

  if (parts.length != 2) {
    return description;
  }

  String intro = parts[0].trim();
  String steps = parts[1].trim();

  steps = steps.replaceAllMapped(
    RegExp(r'([^\.]+)\.\s*'),
    (match) {
      return '- ${match[1]?.trim()}.\n\n';
    },
  ).trim();

  return '$intro\n\nSteps:\n\n$steps';
}
