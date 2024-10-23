import 'package:flutter/cupertino.dart' hide Alignment;
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/OfflineVideoModel.dart';
import 'package:gymvisa/screens/clientSide/ExcerciseScreen.dart';
import 'package:gymvisa/screens/clientSide/OfflineVideos.dart';
import 'package:gymvisa/widgets/BodyPart.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class ManBack extends StatefulWidget {
  const ManBack({super.key});

  @override
  State<ManBack> createState() => _ManBackState();
}

class _ManBackState extends State<ManBack> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      child: Center(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.asset(
                'lib/assets/backMan.png',
                height: screenHeight * 0.85,
                width: screenWidth * 0.9,
                fit: BoxFit.contain,
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(0, screenHeight * 0.19, 0, 0),
            //   child: BodyPart(
            //     text: 'Traps',
            //     dividerWidth: screenWidth * 0.3,
            //     onTap: () {},
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, screenHeight * 0.17, 0, 0),
              child: BodyPart(
                text: 'Triceps',
                dividerWidth: screenWidth * 0.2,
                onTap: () async {
                  List<OfflineVideo>? videoDetailsByCatagory =
                      cachedOffilneVideos['Tricep'];

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: OfflineVideos(
                      videoCategory: videoDetailsByCatagory![0].videoCatagory,
                      mainVideoURL: videoDetailsByCatagory[0].videoURL,
                      videoPath: videoDetailsByCatagory[0].videoPath,
                      excerciseDescription: videoDetailsByCatagory[0].videoDescription,
                      relatedVideosList: videoDetailsByCatagory,
                      videoTitle: videoDetailsByCatagory[0].videoTitle,
                    ),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(0, screenHeight * 0.52, 0, 0),
            //   child: BodyPart(
            //     text: 'Hamstrings',
            //     dividerWidth: screenWidth * 0.27,
            //     onTap: () {},
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(0, screenHeight * 0.7, 0, 0),
            //   child: BodyPart(
            //     text: 'Calves',
            //     dividerWidth: screenWidth * 0.27,
            //     onTap: () {},
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.4, screenHeight * 0.17, 0, 0),
              child: BodyPart(
                text: 'Lats',
                dividerWidth: screenWidth * 0.3,
                alignment: Alignment.right,
                onTap: () async {
                  List<OfflineVideo>? videoDetailsByCatagory =
                      cachedOffilneVideos['Lats'];

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: OfflineVideos(
                      videoCategory: videoDetailsByCatagory![0].videoCatagory,
                      mainVideoURL: videoDetailsByCatagory[0].videoURL,
                      videoPath: videoDetailsByCatagory[0].videoPath,
                      excerciseDescription: videoDetailsByCatagory[0].videoDescription,
                      relatedVideosList: videoDetailsByCatagory,
                      videoTitle: videoDetailsByCatagory[0].videoTitle,
                    ),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.4, screenHeight * 0.26, 0, 0),
              child: BodyPart(
                text: 'Lower Back',
                dividerWidth: screenWidth * 0.4,
                alignment: Alignment.right,
                onTap: () async {
                  List<OfflineVideo>? videoDetailsByCatagory =
                      cachedOffilneVideos['Lower Back'];

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: OfflineVideos(
                      videoCategory: videoDetailsByCatagory![0].videoCatagory,
                      mainVideoURL: videoDetailsByCatagory[0].videoURL,
                      videoPath: videoDetailsByCatagory[0].videoPath,
                      excerciseDescription: videoDetailsByCatagory[0].videoDescription,
                      relatedVideosList: videoDetailsByCatagory,
                      videoTitle: videoDetailsByCatagory[0].videoTitle,
                    ),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(
            //       screenWidth * 0.4, screenHeight * 0.43, 0, 0),
            //   child: BodyPart(
            //     text: 'Glutes',
            //     dividerWidth: screenWidth * 0.4,
            //     alignment: Alignment.right,
            //     onTap: () {},
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.75, screenHeight * 0.7, 0, 0),
              child: GestureDetector(
                onTap: () {
                  ExcerciseScreen.of(context)?.previousPage();
                },
                child: Icon(
                  CupertinoIcons.arrow_right_arrow_left_circle_fill,
                  color: AppColors.appNeon,
                  size: screenWidth * 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
