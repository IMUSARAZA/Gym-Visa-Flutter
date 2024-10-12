import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/const/size.dart';

import '../../models/Notifications.dart';

class NotificationScreen extends StatefulWidget {
  final Future<List<Notifications>> notifs;
  
  NotificationScreen(
    { required this.notifs,
      super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  late Future<List<Notifications>> notifs;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
    notifs = widget.notifs;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(title: Text("Notifications", style: GoogleFonts.poppins(),)),

      body: RefreshIndicator(
        onRefresh: _initialize,
        color: AppColors.appNeon,
        child: FutureBuilder<List<Notifications>>(
          future: notifs,
          builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.appNeon,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.white),
                          );
                        } else if (snapshot.hasData) {
                          List<Notifications> notifics = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: notifics.length,
                            itemBuilder: (context, index) {
                              return NotifWidget(context, notifics[index]);
                            },
                          );
                        } else {
                          return Text(
                            'Sorry, there are no notifications',
                            style: TextStyle(color: Colors.white),
                          );
                        }
          }             
        ),
      )
    );
  }
}


Widget NotifWidget(BuildContext context, Notifications notifs){
  String formattime = formatTime(notifs.time);
  String formatdate = formatDate(notifs.time);
  bool today = true;
  Color trueColor = AppColors.appNeon;
  Color falseColor = Color.fromARGB(96, 92, 92, 92);


  if(notifs.time.day != DateTime.now().day){
    today = false;
  }

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: today? trueColor: falseColor,
      ),
      child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatdate,
          style: GoogleFonts.poppins(color: today?Colors.black:Colors.white),
          ),
          Text(notifs.title,
          style: GoogleFonts.poppins(fontWeight:FontWeight.bold, color: today?Colors.black:Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: ScreenSize.getScreenWidth(context)*0.5,
                child: Text(notifs.body,
                softWrap: true,
                          style: GoogleFonts.poppins(color: today?Colors.black:Colors.white),
                
                ),
              ),
              Spacer(),
              Text("Time: " + formattime,
          style: GoogleFonts.poppins(color: today?Colors.black:Colors.white),
              
              ),
            ],
          ),
        ],
      ),
    ),
  );
}



String formatTime(DateTime dateTime) {
  return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
}
String formatDate(DateTime dateTime) {
  return '${dateTime.weekday}-${_getMonthName(dateTime.month)}-${dateTime.year}';
}


 String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
