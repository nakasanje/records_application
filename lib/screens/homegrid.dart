import 'package:flutter/material.dart';

import '../pages/patientrecords.dart';
import '../pages/receiverecords.dart';
import '../pages/sharerecords.dart';
import '../pages/uploadrecords.dart';

class HomeGrid extends StatefulWidget {
  const HomeGrid({Key? key}) : super(key: key);

  @override
  State<HomeGrid> createState() => _HomeGridState();
}

class _HomeGridState extends State<HomeGrid> {
  //storing for the selected language

//list containing gridView items and the pages to which they route
  final List<Map<String, dynamic>> gridMap = [
    {
      "title": "PATIENT RECORDS",
      "image": "assets/images/medical.jpeg",
      "route": PatientRecords.routeName,
    },
    {
      "title": "UPLOAD RECORDS",
      "image": "assets/images/upload.png",
      "route": UploadRecords.routeName,
    },
    {
      "title": "SHARE RECORDS",
      "image": "assets/images/records.png",
      "route": ShareRecords.routeName,
    },
    {
      "title": "RECEIVED RECORDS",
      "image": "assets/images/receive.jpeg",
      "route": ReceivingDoctorPage.routeName,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 125,
        ),
        itemCount: gridMap.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to the desired screen based on the tapped item
              final String route = gridMap[index]['route'];
              switch (route) {
                case ShareRecords.routeName:
                  Navigator.pushNamed(context, ShareRecords.routeName);
                  break;
                case PatientRecords.routeName:
                  Navigator.pushNamed(context, PatientRecords.routeName);
                  break;
                case UploadRecords.routeName:
                  Navigator.pushNamed(context, UploadRecords.routeName);
                  break;
                case ReceivingDoctorPage.routeName:
                  Navigator.pushNamed(context, ReceivingDoctorPage.routeName);
                  break;

                //case ChatBot.routeName:
                // Navigator.pushNamed(context, ChatBot.routeName);
                // break;
                // default:
                //   // Handle the default case or any other custom logic
                //   break;
              }
            },

            //the container carrying our gridview items
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color.fromARGB(255, 192, 248, 207),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),

                      //the image item goes here
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "${gridMap.elementAt(index)['image']}",
                          fit: BoxFit.fill,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),

                    //the text item goes here
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${gridMap.elementAt(index)['title']}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      //getLanguageDropDown()
    );
  }
}

class TappableWidget extends StatefulWidget {
  final Widget child;

  const TappableWidget({super.key, required this.child});

  @override
  _TappableWidgetState createState() => _TappableWidgetState();
}

class _TappableWidgetState extends State<TappableWidget> {
  bool isTapped = false;
  double offsetX = 0;
  double offsetY = 0;

  void _handleTap(BuildContext context, TapDownDetails details) {
    setState(() {
      isTapped = true;
      offsetX = details.globalPosition.dx;
      offsetY = details.globalPosition.dy;
    });

    // Wait for a moment and then reset the isTapped state to false
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        isTapped = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _handleTap(context, details),
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (isTapped)
            Positioned(
              top: offsetY - 20,
              left: offsetX - 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
