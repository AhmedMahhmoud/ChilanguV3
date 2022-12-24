import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/Reports/DailyReport/attend_details_camera.dart';
import 'package:qr_users/widgets/Reports/DailyReport/userDetailsInReport.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

class DataTableRow extends StatefulWidget {
  final DailyReportUnit attendUnit;
  final int siteId;
  final DateTime todayDate;
  const DataTableRow(this.attendUnit, this.siteId, this.todayDate);

  @override
  _DataTableRowState createState() => _DataTableRowState();
}

class _DataTableRowState extends State<DataTableRow> {
  bool isTodayDate() {
    return DateTime.now().difference(widget.todayDate).inDays == 0;
  }

  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  var now = DateTime.now();

  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            InkWell(
              onLongPress: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                await Provider.of<MemberData>(context, listen: false)
                    .getUserById(
                  widget.attendUnit.userId,
                );
                Navigator.pop(context);
                final userData = Provider.of<MemberData>(context, listen: false)
                    .singleMember;
                showDialog(
                  context: context,
                  builder: (context) {
                    return UserDetailsInReport(userData: userData);
                  },
                );
              },
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                final now = DateTime.now();
                final int legalDay =
                    Provider.of<CompanyData>(context, listen: false)
                        .com
                        .legalComDate;
                final toDate = DateTime(now.year, now.month, now.day - 1);
                var fromDate = DateTime(now.year, now.month, legalDay);
                final userProvider =
                    Provider.of<UserData>(context, listen: false).user;

                // getMembersData();
                final DateTime companyDate =
                    Provider.of<CompanyData>(context, listen: false)
                        .com
                        .createdOn;
                if (fromDate.isBefore(companyDate)) {
                  fromDate = companyDate;
                }
                if (toDate.isBefore(fromDate)) {
                  fromDate = DateTime(
                      now.year,
                      now.month - 1,
                      Provider.of<CompanyData>(context, listen: false)
                          .com
                          .legalComDate);
                }
                // Navigator.pop(context);
                await Navigator.of(context).push(
                  new MaterialPageRoute(
                    builder: (context) => UserAttendanceReportScreen(
                      name: widget.attendUnit.userName,
                      reportName: "daily report",
                      userFromDate: fromDate,
                      userToDate: toDate,
                      id: widget.attendUnit.userId,
                      siteId: widget.siteId,
                      // siteIndex:
                    ),
                  ),
                );
                Navigator.pop(context);
                // Navigator.maybePop(context);
              },
              //USERNAME IN LISTVIEW//
              child: widget.attendUnit.timeOut == null
                  ? Container()
                  : Container(
                      width: 160.w,
                      child: Container(
                        child: AutoSizeText(
                          widget.attendUnit.userName,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(14, allowFontScalingSelf: false),
                              color: Colors.black),
                        ),
                      ),
                    ),
            ),
            widget.attendUnit.timeOut == null
                ? Container()
                : Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                              height: 50.h,
                              child: Center(
                                  child: widget.attendUnit.lateTime == "-"
                                      ? Container(
                                          height: 20,
                                          child: AutoSizeText(
                                            "-",
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: ScreenUtil().setSp(16,
                                                    allowFontScalingSelf:
                                                        false),
                                                color: Colors.black),
                                          ),
                                        )
                                      : Container(
                                          child: AutoSizeText(
                                            widget.attendUnit.lateTime,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: ScreenUtil().setSp(13,
                                                    allowFontScalingSelf:
                                                        false),
                                                color: Colors.red),
                                          ),
                                        ))),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                              child: Center(
                                  child: widget.attendUnit.timeIn == "-"
                                      ? Container(
                                          child: AutoSizeText(
                                            getTranslated(context, "غياب"),
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: ScreenUtil().setSp(14,
                                                    allowFontScalingSelf:
                                                        false),
                                                color: Colors.red),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            !widget.attendUnit.timeIn
                                                    .contains(":")
                                                ? Container()
                                                : Icon(
                                                    widget.attendUnit
                                                                .timeInIcon ==
                                                            "am"
                                                        ? Icons.wb_sunny
                                                        : Icons
                                                            .nightlight_round,
                                                    size: ScreenUtil().setSp(11,
                                                        allowFontScalingSelf:
                                                            false),
                                                  ),
                                            Container(
                                              width: getTranslated(
                                                          context,
                                                          widget.attendUnit
                                                              .timeIn) ==
                                                      null
                                                  ? 35.w
                                                  : 50.w,
                                              child: AutoSizeText(
                                                getTranslated(
                                                        context,
                                                        widget.attendUnit
                                                            .timeIn) ??
                                                    widget.attendUnit.timeIn,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: ScreenUtil().setSp(
                                                        13,
                                                        allowFontScalingSelf:
                                                            false),
                                                    color: Colors.black),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ))),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                              height: 50.h,
                              child: Center(
                                  child: widget.attendUnit.timeOut == "-"
                                      ? widget.attendUnit.timeIn == "-" ||
                                              widget.attendUnit.timeIn ==
                                                  getTranslated(
                                                      context, "عارضة") ||
                                              widget.attendUnit.timeIn ==
                                                  getTranslated(
                                                      context, "مرضى") ||
                                              widget.attendUnit.timeIn ==
                                                  getTranslated(
                                                      context, "رصيد اجازات") ||
                                              widget.attendUnit.timeIn ==
                                                  getTranslated(context,
                                                      "مأمورية خارجية") ||
                                              widget.attendUnit.timeIn ==
                                                  getTranslated(
                                                      context, "غير مقيد بعد")
                                          ? Container(
                                              height: 20,
                                              child: AutoSizeText(
                                                "",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(
                                                        16,
                                                        allowFontScalingSelf:
                                                            false),
                                                    color: Colors.red),
                                              ),
                                            )
                                          : Container(
                                              height: 20,
                                              child: AutoSizeText(
                                                isTodayDate()
                                                    ? "-"
                                                    : getTranslated(
                                                        context, "غياب"),
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(
                                                        16,
                                                        allowFontScalingSelf:
                                                            false),
                                                    color: isTodayDate()
                                                        ? Colors.black
                                                        : Colors.red),
                                              ),
                                            )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              widget.attendUnit.timeOutIcon ==
                                                      "am"
                                                  ? Icons.wb_sunny
                                                  : Icons.nightlight_round,
                                              size: ScreenUtil().setSp(12,
                                                  allowFontScalingSelf: false),
                                            ),
                                            Container(
                                              child: AutoSizeText(
                                                widget.attendUnit.timeOut ?? "",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(
                                                        13,
                                                        allowFontScalingSelf:
                                                            true),
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ))),
                        ),
                        // !widget.attendUnit.timeIn.contains(":")
                        //     ? Padding(
                        //         padding: EdgeInsets.only(left: 20.w),
                        //         child: Container(),
                        //       )
                        //     :
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              if (widget.attendUnit.attendType == 1) {
                                final AttendDetails attendDetails =
                                    AttendDetails();
                                // ignore: cascade_invocations
                                attendDetails.showAttendByCameraDetails(
                                  todayDate: widget.todayDate,
                                  normalizedName:
                                      widget.attendUnit.normalizedName,
                                  context: context,
                                  timeIn: widget.attendUnit.timeIn,
                                  timeOut: widget.attendUnit.timeOut,
                                );
                              } else {}
                            },
                            child: ((widget.attendUnit.timeOut != "-" ||
                                        widget.attendUnit.timeIn != "-")) &&
                                    (widget.attendUnit.timeIn.contains(":") ||
                                        widget.attendUnit.timeOut.contains(":"))
                                ? Icon(
                                    widget.attendUnit.attendType == 0
                                        ? Icons.phone_android
                                        : Icons.image,
                                    color: Colors.orange,
                                    size: ScreenUtil()
                                        .setSp(28, allowFontScalingSelf: false),
                                  )
                                : Container(),
                          ),
                        )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
