import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';

import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Sites/filteredSites.dart';
import 'package:qr_users/widgets/Sites/sitesDisplay.dart';
import 'package:qr_users/widgets/headers.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

class SitesScreen extends StatefulWidget {
  @override
  _SitesScreenState createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<SiteData>(context, listen: false).pageIndex = 0;
    Provider.of<SiteData>(context, listen: false).keepRetriving = true;
    Provider.of<PermissionHan>(context, listen: false).initializeUserScroll();
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  _onChangeHandler(value) {
    search(value);
  }

  getIndexBySiteName(String name) {
    for (int i = 1;
        i < Provider.of<SiteShiftsData>(context, listen: false).sites.length;
        i++) {
      if (Provider.of<SiteShiftsData>(context, listen: false).sites[i].name ==
          name) {
        return i - 1;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  final List<Site> sites = locator.locator<SiteShiftsData>().sites;

  search(text) {
    final newFilteredList = sites
        .where((element) =>
            element.name.toLowerCase().contains(text.toString().toLowerCase()))
        .toList();
    if (newFilteredList.isEmpty) {
      setState(() {
        filteredSites.clear();
      });
    } else {
      setState(() {
        filteredSites = newFilteredList;
      });
    }
  }

  ScrollController _scrollController = ScrollController();
  List<Site> filteredSites = [];
  TextEditingController _sitesController = TextEditingController();
  final SlidableController slidableController = SlidableController();
  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays([]);
    final SiteShiftsData _siteShift =
        Provider.of<SiteShiftsData>(context, listen: true);
    return Consumer<SiteData>(builder: (context, siteData, child) {
      return WillPopScope(
          onWillPop: onWillPop,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: NotificationListener(
              onNotification: (notificationInfo) {
                if (_scrollController.hasClients) {
                  if (_scrollController.position.userScrollDirection ==
                      ScrollDirection.reverse) {
                    Provider.of<PermissionHan>(context, listen: false)
                        .setUserScrolling();
                  } else if (_scrollController.position.userScrollDirection ==
                      ScrollDirection.forward) {
                    Provider.of<PermissionHan>(context, listen: false)
                        .resetUserscrolling();
                  }
                }

                return true;
              },
              child: Scaffold(
                  endDrawer: NotificationItem(),
                  backgroundColor: Colors.white,
                  body: Container(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Header(
                                nav: false,
                                goUserHomeFromMenu: false,
                                goUserMenu: false,
                              ),
                              SmallDirectoriesHeader(
                                  Lottie.asset("resources/locaitonss.json",
                                      repeat: false),
                                  getTranslated(context, "دليل المواقع")),

                              ///List OF SITES
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 16.h),
                                child: TextField(
                                  onChanged: (value) {
                                    print("debug $value");
                                    _onChangeHandler(value);
                                  },
                                  controller: _sitesController,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: getTranslated(
                                          context, 'البحث بأسم الموقع'),
                                      focusColor: Colors.orange,
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors.orange[600])),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors.orange[600]))),
                                ),
                              ),
                              _sitesController.text != "" &&
                                      filteredSites.length >= 1
                                  ? FilteredSitesDisplay(
                                      filteredSites: filteredSites,
                                      slidableController: slidableController,
                                    )
                                  : SitesDisplay(
                                      sites: _siteShift.sites,
                                      scrollController: _scrollController,
                                    ),
                              siteData.sitesList.length != 0
                                  ? Provider.of<SiteData>(context).isLoading
                                      ? Column(
                                          children: [
                                            const Center(
                                                child:
                                                    CupertinoActivityIndicator(
                                              radius: 15,
                                            )),
                                            Container(
                                              height: 30,
                                            )
                                          ],
                                        )
                                      : Container()
                                  : Container()
                            ],
                          ),
                        ),
                        Positioned(
                          left: 5.0.w,
                          top: 5.0.h,
                          child: Container(
                            width: 50.w,
                            height: 50.h,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NavScreenTwo(3)),
                                    (Route<dynamic> route) => false);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  floatingActionButton:
                      Provider.of<UserData>(context, listen: false)
                                  .user
                                  .userType ==
                              4
                          ? MultipleFloatingButtons(
                              mainTitle: getTranslated(context, "إضافة موقع"),
                              shiftName: "",
                              comingFromShifts: false,
                              mainIconData: Icons.add_location_alt,
                            )
                          : MultipleFloatingButtonsNoADD()),
            ),
          ));
    });
  }

  Future<bool> onWillPop() {
    goAndRemoveUntill(context, const NavScreenTwo(3));

    return Future.value(false);
  }
}
