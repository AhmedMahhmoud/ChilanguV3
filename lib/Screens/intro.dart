import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import "../services/user_data.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'HomePage.dart';
import 'loginScreen.dart';
import 'package:provider/provider.dart';

class PageIntro extends StatefulWidget {
  final int userType;
  const PageIntro({this.userType});

  @override
  _PageIntroState createState() => _PageIntroState();
}

Animation<double> animation;

class _PageIntroState extends State<PageIntro> with TickerProviderStateMixin {
  int _currentIndex = 0;

  PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
  }

  _onPageChange(int indx) {
    setState(() {
      _currentIndex = indx;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const IntroContent(
        title: "",
        mainTitle: "",
        imageUrl: "resources/introStart.json",
      ),
      IntroContent(
        mainTitle: "",
        imageUrl: "resources/intro1.json",
        title: getTranslated(context, "phoneCan"),
      ),
      IntroContent(
        mainTitle: getTranslated(context, "من حسابك تستطيع"),
        title: getTranslated(context, "accountCan"),
        imageUrl: "resources/intro2.json",
      ),
      IntroContent(
        mainTitle: getTranslated(context, "مدير النظام يستطيع"),
        title: getTranslated(context, "adminCan"),
        imageUrl: "resources/intro3.json",
      ),
    ];

    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _pages[index];
                },
                scrollDirection: Axis.horizontal,
                controller: _controller,
                onPageChanged: _onPageChange),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _currentIndex < _pages.length - 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List<Widget>.generate(_pages.length - 1, (index) {
                          return AnimatedContainer(
                            margin: EdgeInsets.only(bottom: 29.h),
                            duration: const Duration(milliseconds: 100),
                            height: 12.h,
                            width: index == _currentIndex ? 30.w : 20.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: index == _currentIndex
                                    ? Colors.black
                                    : Colors.orange[700]),
                          );
                        }),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Provider.of<UserData>(
                                            context,
                                            listen: false)
                                        .loggedIn
                                    ? Provider.of<UserData>(context,
                                                    listen: false)
                                                .user
                                                .userType ==
                                            0
                                        ? HomePage()
                                        : const NavScreenTwo(0)
                                    : LoginScreen(),
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: AutoSizeText(
                              getTranslated(
                                context,
                                "ابدأ",
                              ),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          width: 150.w,
                          decoration: BoxDecoration(
                            color: Colors.orange[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                Container(
                  height: 10.h,
                )
              ],
            ),
            _currentIndex != _pages.length - 1
                ? Positioned(
                    right: 20.w,
                    top: 20.h,
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Provider.of<UserData>(context,
                                        listen: true)
                                    .loggedIn
                                ? Provider.of<UserData>(context, listen: false)
                                            .user
                                            .userType ==
                                        0
                                    ? HomePage()
                                    : const NavScreenTwo(0)
                                : LoginScreen(),
                          )),
                      child: Container(
                        height: 20.h,
                        child: AutoSizeText(
                          getTranslated(context, "تخطى"),
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorManager.primary),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class IntroContent extends StatelessWidget {
  const IntroContent({
    this.imageUrl,
    this.title,
    this.mainTitle,
    Key key,
  }) : super(key: key);

  final String imageUrl, title, mainTitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(bottom: 90.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 50.h),
              child: Stack(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        height: 10.h,
                      ),
                      Container(
                        child: Image.asset(
                          'resources/Chilangu.png',
                        ),
                        height: 70.h,
                      ),
                    ],
                  ),
                  // Positioned(
                  //   child: Center(
                  //     child: Container(
                  //       padding: const EdgeInsets.only(right: 5, top: 5),
                  //       height: 170.h,
                  //       child: Lottie.asset(
                  //         "resources/fire.json",
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
            Container(
              width: 400.w,
              height: 300.h,
              child: Lottie.asset(imageUrl),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ZoomIn(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 600.w,
                        height: title == getTranslated(context, "phoneCan")
                            ? 60.h
                            : 120.h,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: ColorManager.primary),
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          child: title == ""
                              ? FadeIn(
                                  child: Column(
                                  children: [
                                    Container(
                                      width: 400.w,
                                      child: AutoSizeText(
                                        getTranslated(
                                          context,
                                          "وداعا للروتين و التأخير",
                                        ),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                setResponsiveFontSize(13)),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: 400.w,
                                      child: AutoSizeText(
                                        getTranslated(context,
                                            "وداعا لمشاكل الصيانة و الأعطال"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                setResponsiveFontSize(13)),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: 380.w,
                                      child: AutoSizeText(
                                        getTranslated(context,
                                            "وداعا لمشاكل الحضور و الأنصراف بالطرق التقليدية"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                setResponsiveFontSize(13)),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: 380.w,
                                      child: AutoSizeText(
                                        getTranslated(context,
                                            "الحضور و الأنصراف  اسهل مع CHILANGU"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                setResponsiveFontSize(13)),
                                      ),
                                    ),
                                  ],
                                ))
                              : Container(
                                  width: 380.w,
                                  child: AutoSizeText(
                                    mainTitle,
                                    style: boldStyle.copyWith(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                          bottom: mainTitle ==
                                  getTranslated(context, "من حسابك تستطيع")
                              ? 24.h
                              : 10.h,
                          child: AutoSizeText(
                            title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: setResponsiveFontSize(13),
                                height: 1.5),
                            textAlign: TextAlign.center,
                          ))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
