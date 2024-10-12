class OfflineVideo {
  String videoCatagory;
  String videoDescription;
  String videoDuration;
  String videoTitle;
  String videoURL;
  String videoPath; 

  OfflineVideo({
    required this.videoCatagory,
    required this.videoDescription,
    required this.videoDuration,
    required this.videoTitle,
    required this.videoURL,
    required this.videoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'VideoCatagory': videoCatagory,
      'VideoDescription': videoDescription,
      'VideoDuration': videoDuration,
      'VideoTitle': videoTitle,
      'VideoURL': videoURL,
      'VideoPath': videoPath,
    };
  }

  factory OfflineVideo.fromJson(Map<String, dynamic> json) {
    return OfflineVideo(
      videoCatagory: json['VideoCatagory'],
      videoDescription: json['VideoDescription'],
      videoDuration: json['VideoDuration'],
      videoTitle: json['VideoTitle'],
      videoURL: json['VideoURL'],
      videoPath: json['videoPath'],
    );
  }

  factory OfflineVideo.fromJson2(Map<String, dynamic> json) {
  return OfflineVideo(
    videoCatagory: json['videoCategory'] ?? '',
    videoDescription: json['videoDescription'] ?? '',
    videoDuration: json['videoDuration'] ?? '',
    videoTitle: json['videoTitle'] ?? '',
    videoURL: json['videoURL'] ?? '',
    videoPath: json['videoPath'] ?? '', 
  );
}
}