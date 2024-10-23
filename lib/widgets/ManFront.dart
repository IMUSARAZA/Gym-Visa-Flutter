import 'package:flutter/cupertino.dart' hide Alignment;
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/OfflineVideoModel.dart';
import 'package:gymvisa/screens/clientSide/ExcerciseScreen.dart';
import 'package:gymvisa/screens/clientSide/OfflineVideos.dart';
import 'package:gymvisa/widgets/BodyPart.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class ManFront extends StatefulWidget {
  const ManFront({super.key});

  @override
  State<ManFront> createState() => _ManFrontState();


}

class _ManFrontState extends State<ManFront> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
                'lib/assets/frontMan.png',
                height: screenHeight * 0.85,
                width: screenWidth * 0.9,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, screenHeight * 0.13, 0, 0),
              child: BodyPart(
                text: 'Shoulder',
                dividerWidth: screenWidth * 0.25,
                onTap: () async {
                  List<OfflineVideo>? videoDetailsByCatagory =
                      cachedOffilneVideos['Shoulder'];
                  debugPrint("CLICKED");
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: OfflineVideos(
                      videoCategory: 'Shoulder',
                      mainVideoURL: videoDetailsByCatagory![0].videoURL,
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
              padding: EdgeInsets.fromLTRB(0, screenHeight * 0.25, 0, 0),
              child: BodyPart(
                text: 'Chest',
                dividerWidth: screenWidth * 0.3,
                onTap: () {
                  List<OfflineVideo>? videoDetailsByCatagory =
                      cachedOffilneVideos['Chest'];


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
            //   padding: EdgeInsets.fromLTRB(0, screenHeight * 0.35, 0, 0),
            //   child: BodyPart(
            //     text: 'Forearms',
            //     dividerWidth: screenWidth * 0.2,
            //     onTap: () {},
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(0, screenHeight * 0.52, 0, 0),
            //   child: BodyPart(
            //     text: 'Quads',
            //     dividerWidth: screenWidth * 0.3,
            //     onTap: () {},
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.45, screenHeight * 0.21, 0, 0),
              child: BodyPart(
                text: 'Biceps',
                dividerWidth: screenWidth * 0.25,
                alignment: Alignment.right,
                onTap: () async {
                  List<OfflineVideo>? videoDetailsByCatagory =
                      cachedOffilneVideos['Bicep'];

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
                  screenWidth * 0.4, screenHeight * 0.28, 0, 0),
              child: BodyPart(
                text: 'Abs',
                dividerWidth: screenWidth * 0.4,
                alignment: Alignment.right,
                onTap: () async {
                  List<OfflineVideo>? videoDetailsByCatagory =
                      cachedOffilneVideos['Abs'];

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
                  screenWidth * 0.75, screenHeight * 0.7, 0, 0),
              child: GestureDetector(
                onTap: () {
                  ExcerciseScreen.of(context)?.nextPage();
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



