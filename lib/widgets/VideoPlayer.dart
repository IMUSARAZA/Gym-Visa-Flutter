import 'dart:io';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvisa/widgets/GlobalVideoControllerManager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? videoPath;

  const VideoPlayerWidget({Key? key, required this.videoUrl, this.videoPath}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  CachedVideoPlayerController? _videoPlayerController;
  CustomVideoPlayerController? _customVideoPlayerController;
  CustomVideoPlayerWebController? _customVideoPlayerWebController;

  final CustomVideoPlayerSettings _customVideoPlayerSettings =
      const CustomVideoPlayerSettings(showSeekButtons: true, showFullscreenButton: false);

  bool _isLoading = true;
  bool _hasError = false;
  bool _isDisposed = false;


  @override
  void initState() {
    super.initState();
    initializePlayer().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> initializePlayer() async {

      _isDisposed = false;

    _disposePreviousVideoPlayer();

    if (kIsWeb) {
      _customVideoPlayerWebController = CustomVideoPlayerWebController(
        webVideoPlayerSettings: CustomVideoPlayerWebSettings(
          src: widget.videoUrl,
        ),
      );
    } else {
      try {
        String? videoPath = widget.videoPath;

        if (videoPath != null && videoPath.isNotEmpty) {
          File videoFile = File(videoPath);

          if (await videoFile.exists()) {
            print('Playing video from local path: $videoPath');
            _videoPlayerController = CachedVideoPlayerController.file(videoFile)
              ..initialize().then((_) {
                setState(() {});
              }).catchError((error) {
                print('Error initializing local video: $error');
                playVideoFromNetwork();
              });
          } else {
            print('Local video file does not exist, falling back to URL: ${widget.videoUrl}');
            playVideoFromNetwork();
          }
        } else {
          print('No local video path provided, playing from URL: ${widget.videoUrl}');
          playVideoFromNetwork();
        }

        GlobalVideoControllerManager.setActiveVideoController(_videoPlayerController);

        _customVideoPlayerController = CustomVideoPlayerController(
          context: context,
          videoPlayerController: _videoPlayerController!,
          customVideoPlayerSettings: _customVideoPlayerSettings,
        );
      } catch (e, stackTrace) {
        print('Error initializing video player: $e');
        print('Stack trace: $stackTrace');
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void playVideoFromNetwork() {
    _videoPlayerController = CachedVideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      }).catchError((error) {
        print('Error initializing network video: $error');
        setState(() {
          _hasError = true;
        });
      });
  }

  void _disposePreviousVideoPlayer() {
  if (_videoPlayerController != null && !_isDisposed) {
    _videoPlayerController!.pause();
    _videoPlayerController!.dispose();
    _videoPlayerController = null; 
    _isDisposed = true; 
  }

  if (_customVideoPlayerController != null) {
    _customVideoPlayerController!.dispose();
    _customVideoPlayerController = null;
  }

  if (_customVideoPlayerWebController != null) {
    _customVideoPlayerWebController = null;
  }
}


  @override
  void dispose() {
    _disposePreviousVideoPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 158, 158, 158),
        ),
      );
    }

    if (_hasError) {
      return const Center(
        child: Text(
          'Error loading video. Please try again later.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return kIsWeb
        ? Container(
            width: screenWidth * 0.8,
            height: screenHeight * 0.26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomVideoPlayerWeb(
              customVideoPlayerWebController: _customVideoPlayerWebController!,
            ),
          )
        : Container(
            width: screenWidth * 0.8,
            height: screenHeight * 0.26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomVideoPlayer(
              customVideoPlayerController: _customVideoPlayerController!,
            ),
          );
  }
}
