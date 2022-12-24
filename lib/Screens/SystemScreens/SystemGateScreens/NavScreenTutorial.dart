// import 'dart:developer';
// // import 'package:huawei_push/huawei_push_library.dart' as hawawi;
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_users/Core/colorManager.dart';
// import 'package:qr_users/Core/constants.dart';
// import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
// import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
// import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';
// import 'package:qr_users/Screens/AdminPanel/pending_company_permessions.dart';
// import 'package:qr_users/Screens/AdminPanel/pending_company_vacations.dart';
// import 'package:qr_users/Screens/HomePage.dart';
// import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
// import 'package:qr_users/Screens/SystemScreens/ReportScreens/ReportScreen.dart';
// import 'package:qr_users/Screens/SystemScreens/SittingScreens/SettingsScreen.dart';
// import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/AttendByCard/SystemHomePage.dart';
// import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
// import 'package:qr_users/Screens/errorscreen2.dart';
// import 'package:qr_users/enums/connectivity_status.dart';
// import 'package:qr_users/services/CompanySettings/companySettings.dart';
// import 'package:qr_users/services/company.dart';
// import 'package:qr_users/services/user_data.dart';
// import 'package:qr_users/widgets/Shared/Subscribtion_end_dialog.dart';
// import 'package:qr_users/widgets/drawer.dart';
// import 'package:qr_users/widgets/headers.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'dart:ui' as ui;

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// class NavScreenTutorial extends StatefulWidget {
//   final int index;

//   const NavScreenTutorial(this.index);

//   @override
//   _NavScreenTutorialState createState() => _NavScreenTutorialState(index);
// }

// class _NavScreenTutorialState extends State<NavScreenTutorial>
//     with WidgetsBindingObserver {
//   _NavScreenTutorialState(this.getIndex);

//   final getIndex;
//   var current = 0;
//   var x = true;

//   PageController _controller = PageController();

//   List<Widget> _screens = [
//     HomePage(),
//     SystemHomePage(),
//     ReportsScreen(),
//     SettingsScreen(),
//   ];

//   _onPageChange(int indx) {
//     debugPrint("change");
//     setState(() {
//       current = indx;
//     });
//   }

//   GlobalKey keyButton = GlobalKey();
//   GlobalKey keyButton2 = GlobalKey();
//   GlobalKey keyButton3 = GlobalKey();
//   GlobalKey keyButton4 = GlobalKey();

//   TutorialCoachMark tutorialCoachMark;
//   void showTutorial() {
//     tutorialCoachMark.show(context: context);
//   }

//   @override
//   void initState() {
//     current = getIndex;

//     final notificationProv =
//         Provider.of<NotificationDataService>(context, listen: false);
//     notificationProv.firebaseMessagingConfig();
//     // if (Provider.of<UserData>(context, listen: false).user.osType == 3) {
//     //   // notificationProv.huaweiMessagingConfig(context);

//     //   notificationProv.getInitialNotification(context);
//     // }
//     checkForegroundNotification();
//     createTutorial();
//     Future.delayed(Duration.zero, showTutorial);
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   // void _onNotificationOpenedApp(RemoteMessage remoteMessage) {
//   //   debugPrint("onNotificationOpenedApp: " + remoteMessage.data.toString());
//   // }
//   NotificationDataService _notificationService = NotificationDataService();
//   checkForegroundNotification() {
//     FirebaseMessaging.onMessageOpenedApp.listen((event) async {
//       debugPrint(
//           "####Recveiving data on message tapped with category equal ${event.data['category']}####");

//       saveNotificationToCache(event);
//       // player.play("notification.mp3");
//       if (event.data["category"] == "attend") {
//         log("Opened an attend proov notification !");

//         _notificationService.showAttendanceCheckDialog(context);
//       } else {
//         // ignore: unused_element
//         handlePermessionVacOnRecieved(
//             BuildContext context, RemoteMessage notification) {
//           if (notification.data['category'] == "permessionRequest") {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const PendingCompanyPermessions(),
//                 ));
//           } else if (notification.data['category'] == "vacationRequest") {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const PendingCompanyVacations(),
//                 ));
//           }
//         }
//       }
//     });
//   }

//   saveNotificationToCache(RemoteMessage event) async {
//     if (mounted)
//       await db.insertNotification(
//           NotificationMessage(
//             category: event.data["category"],
//             dateTime: DateTime.now().toString().substring(0, 10),
//             message: event.notification.body,
//             messageSeen: 0,
//             title: event.notification.title,
//           ),
//           context);
//     // player.play("notification.mp3");
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       if (mounted) {
//         final CompanySettingsService _companyService = CompanySettingsService();
//         final userDataProvider = Provider.of<UserData>(context, listen: false);
//         _companyService
//             .isCompanySuspended(
//                 Provider.of<CompanyData>(context, listen: false).com.id,
//                 userDataProvider.user.userToken)
//             .then((value) {
//           log(value.toString());
//           if (value == true) {
//             showDialog(
//               barrierDismissible: false,
//               context: context,
//               builder: (context) {
//                 return DisplaySubscrtibitionEndDialog(
//                     companyService: _companyService);
//               },
//             );
//           }
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userData = Provider.of<UserData>(context);
//     final userDataProvider = Provider.of<UserData>(context, listen: false);
//     final connectionStatus = Provider.of<ConnectivityStatus>(context);
//     return connectionStatus == ConnectivityStatus.Offline &&
//             userData.cachedUserData.isNotEmpty
//         ? ErrorScreen2(
//             child: Container(),
//           )
//         : Scaffold(
//             backgroundColor: Colors.white,
//             drawer: DrawerI(),
//             endDrawer: NotificationItem(),
//             bottomNavigationBar: Directionality(
//               textDirection: ui.TextDirection.ltr,
//               child: CurvedNavigationBar(
//                 color: ColorManager.accentColor,
//                 index: current,
//                 backgroundColor: ColorManager.backGroundColor,
//                 onTap: (value) {
//                   setState(() {
//                     current = value;
//                     _controller.jumpToPage(value);
//                   });
//                 },
//                 items: userDataProvider.user.userType >= 2
//                     ? userDataProvider.user.userType == 4 ||
//                             userDataProvider.user.userType == 3 ||
//                             userDataProvider.user.userType == 2
//                         ? [
//                             Icon(
//                               Icons.fingerprint,
//                               size: ScreenUtil()
//                                   .setSp(30, allowFontScalingSelf: true),
//                               color: ColorManager.primary,
//                               key: keyButton,
//                             ),
//                             Icon(Icons.qr_code,
//                                 size: ScreenUtil()
//                                     .setSp(30, allowFontScalingSelf: true),
//                                 color: ColorManager.primary,
//                                 key: keyButton2),
//                             Icon(
//                               Icons.article_sharp,
//                               size: ScreenUtil()
//                                   .setSp(30, allowFontScalingSelf: true),
//                               color: ColorManager.primary,
//                               key: keyButton3,
//                             ),
//                             Icon(Icons.settings,
//                                 color: ColorManager.primary,
//                                 size: ScreenUtil()
//                                     .setSp(30, allowFontScalingSelf: true),
//                                 key: keyButton4),
//                           ]
//                         : [
//                             Icon(
//                               Icons.fingerprint,
//                               key: keyButton,
//                               size: ScreenUtil()
//                                   .setSp(30, allowFontScalingSelf: true),
//                               color: ColorManager.primary,
//                             ),
//                             Icon(Icons.qr_code,
//                                 size: ScreenUtil()
//                                     .setSp(30, allowFontScalingSelf: true),
//                                 color: ColorManager.primary,
//                                 key: keyButton2),
//                             Icon(
//                               Icons.article_sharp,
//                               size: ScreenUtil()
//                                   .setSp(30, allowFontScalingSelf: true),
//                               color: ColorManager.primary,
//                               key: keyButton3,
//                             ),
//                           ]
//                     : [
//                         Icon(
//                           Icons.fingerprint,
//                           key: keyButton,
//                           color: ColorManager.primary,
//                           size: ScreenUtil()
//                               .setSp(30, allowFontScalingSelf: true),
//                         ),
//                         Icon(Icons.qr_code,
//                             color: Colors.orange,
//                             size: ScreenUtil()
//                                 .setSp(30, allowFontScalingSelf: true),
//                             key: keyButton2),
//                       ],
//               ),
//             ),
//             body: Stack(
//               children: [
//                 Column(
//                   children: [
//                     Header(
//                       nav: true,
//                     ),
//                     Expanded(
//                       child: PageView.builder(
//                         itemBuilder: (context, index) {
//                           return _screens[current];
//                         },
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: _screens.length,
//                         scrollDirection: Axis.horizontal,
//                         controller: _controller,
//                         onPageChanged: _onPageChange,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ));
//   }

//   void createTutorial() {
//     tutorialCoachMark = TutorialCoachMark(
//       targets: _createTargets(),
//       colorShadow: ColorManager.primary,
//       textSkip: getTranslated(context, "تخطى"),
//       paddingFocus: 10,
//       opacityShadow: 0.9,
//       onFinish: () {
//         print("finish");
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => NavScreenTwo(2),
//             ));
//       },
//       onClickTarget: (target) {
//         print('onClickTarget: $target');
//         if (target.identify == "keyButton2") {
//           setState(() {
//             current = 3;
//           });
//         }
//       },
//       onClickTargetWithTapPosition: (target, tapDetails) {
//         print("target: $target");
//         print(
//             "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
//       },
//       onClickOverlay: (target) {
//         print('onClickOverlay: $target');
//       },
//       onSkip: () {
//         print("skip");
//       },
//     );
//   }

//   _createTargets() {
//     List<TargetFocus> targets = [];
//     // ignore: cascade_invocations
//     targets
//       ..add(
//         TargetFocus(
//           identify: "keyButton",
//           keyTarget: keyButton,
//           alignSkip: Alignment.topRight,
//           contents: [
//             TargetContent(
//               align: ContentAlign.top,
//               builder: (context, controller) {
//                 return Container(
//                   child: Directionality(
//                       textDirection: TextDirection.rtl,
//                       child: AutoSizeText(
//                         "طريقة التسجيل هى مسح الQR كود الخاص بالمناوبة",
//                         style: boldStyle.copyWith(color: Colors.white),
//                       )),
//                 );
//               },
//             ),
//           ],
//         ),
//       )
//       ..add(
//         TargetFocus(
//           identify: "keyButton2",
//           keyTarget: keyButton2,
//           alignSkip: Alignment.topRight,
//           contents: [
//             TargetContent(
//               align: ContentAlign.top,
//               builder: (context, controller) {
//                 return Container(
//                   child: Directionality(
//                       textDirection: TextDirection.rtl,
//                       child: AutoSizeText(
//                         "طريقة التسجيل هى مسح الQR كود الخاص بالمناوبة",
//                         style: boldStyle.copyWith(color: Colors.white),
//                       )),
//                 );
//               },
//             ),
//           ],
//         ),
//       )
//       ..add(TargetFocus(
//         identify: "keyButton4",
//         keyTarget: keyButton4,
//         alignSkip: Alignment.topRight,
//         contents: [
//           TargetContent(
//             align: ContentAlign.top,
//             builder: (context, controller) {
//               return AutoSizeText(
//                 "طريقة التسجيل هى مسح الQR كود الخاص بالمناوبة",
//                 style: boldStyle.copyWith(color: Colors.white),
//               );
//             },
//           ),
//         ],
//       ));
//     return targets;
//   }
// }
