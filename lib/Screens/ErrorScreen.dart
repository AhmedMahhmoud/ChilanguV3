import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SuperAdmin/Screen/super_admin.dart';
import 'package:qr_users/Screens/SuperAdmin/Screen/super_company_pie_chart.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Screens/loginScreen.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Core/constants.dart';

class ErrorScreen extends StatefulWidget {
  final message;
  final rep;
  ErrorScreen(this.message, this.rep);

  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  var message;
  var isLoading = false;

  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    message = widget.message;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(builder: (context, userData, child) {
      return Scaffold(
        body: Column(
          children: [
            NewHeader(userData.cachedUserData),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(),
                    SizedBox(
                      height: 10.h,
                    ),
                    Lottie.asset(
                        message.toString().contains("خادم")
                            ? "resources/maintenance.json"
                            : "resources/noNetwork.json",
                        width: 300.w,
                        height: 300.h,
                        repeat: true),
                    Container(
                      height: 100.h,
                      child: AutoSizeText(
                        message,
                        style: TextStyle(
                          height: 1.5,
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(20, allowFontScalingSelf: true),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              ColorManager.primary)),
                    )
                  : InkWell(
                      onTap: () {
                        widget.rep ? login() : Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        // height: 100,
                        width: 260.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.orange),
                        child: Center(
                          child: AutoSizeText(
                            getTranslated(context, "اضغط للمحاولة مره اخرى"),
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil()
                                    .setSp(18, allowFontScalingSelf: true),
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  login() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> userData = (prefs.getStringList('userData') ?? null);

    if (userData == null || userData.isEmpty) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      await Provider.of<UserData>(context, listen: false)
          .loginPost(userData[0], userData[1], context, true)
          .catchError(((e) {
        print(e);
      })).then((value) {
        if (value == USER_INVALID_RESPONSE || value == null) {
          setState(() {
            isLoading = false;
            message = getTranslated(context,
                "تعذر الوصول الى الخادم \n  برجاء اعادة المحاولة فى وقت لاحق");
            // message = getTranslated(context,
            //     "التطبيق تحت الصيانة\nنجرى حاليا تحسينات و صيانة للموقع \nلن تؤثر هذه الصيانة على بيانات حسابك \n نعتذر عن أي إزعاج");
          });
        } else if (value == NO_INTERNET) {
          setState(() {
            isLoading = false;
            message = getTranslated(context,
                "لا يوجد اتصال بالأنترنت \n  برجاء اعادة المحاولة مرة اخرى");
          });
        } else if (value == 6) {
          goPageReplacment(
            context,
            SuperAdminScreen(),
          );
        } else if (value == 4 || value == 3) {
          goPageReplacment(
            context,
            const SuperCompanyPieChart(false),
          );
        } else if (value > 0) {
          goPageReplacment(
            context,
            const NavScreenTwo(0),
          );
        } else if (value == 0) {
          goPageReplacment(
            context,
            HomePage(),
          );
        } else if (value == -2) {
          goPageReplacment(
            context,
            LoginScreen(),
          );
        } else {
          goPageReplacment(
            context,
            LoginScreen(),
          );
        }
      });
    }
  }
}
