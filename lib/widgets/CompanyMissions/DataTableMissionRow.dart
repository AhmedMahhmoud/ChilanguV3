import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/UserMissions/Models/CompanyMissions.dart';

class DataTableMissionRow extends StatelessWidget {
  final CompanyMissions _holidays;

  const DataTableMissionRow(this._holidays);
  bool isExternal() {
    if (_holidays.sitename == "" || _holidays.sitename == null) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              child: Container(
            width: 60.w,
            child: AutoSizeText(
              isExternal()
                  ? getTranslated(context, "خارجية")
                  : getTranslated(context, "داخلية"),
              maxLines: 2,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(14, allowFontScalingSelf: true),
              ),
            ),
          )),
          Container(
            child: Container(
              child: AutoSizeText(
                _holidays.fromdate.toString().substring(0, 11),
                maxLines: 1,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(13, allowFontScalingSelf: true),
                ),
              ),
            ),
          ),
          _holidays.fromdate.isBefore(_holidays.toDate)
              ? Container(
                  child: AutoSizeText(
                    _holidays.toDate.toString().substring(0, 11),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize:
                          ScreenUtil().setSp(13, allowFontScalingSelf: true),
                    ),
                  ),
                )
              : Container(
                  child: AutoSizeText(
                    _holidays.fromdate.toString().substring(0, 11),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize:
                          ScreenUtil().setSp(13, allowFontScalingSelf: true),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class DataTableMissionRowForUser extends StatelessWidget {
  final CompanyMissions _holidays;

  const DataTableMissionRowForUser(this._holidays);
  bool isExternal() {
    if (_holidays.sitename == "" || _holidays.sitename == null) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              child: Container(
            width: 60.w,
            child: AutoSizeText(
              isExternal()
                  ? getTranslated(context, "خارجية")
                  : getTranslated(context, "داخلية"),
              maxLines: 2,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(14, allowFontScalingSelf: true),
              ),
            ),
          )),
          Container(
            child: Container(
              child: AutoSizeText(
                _holidays.fromdate.toString().substring(0, 11),
                maxLines: 1,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(13, allowFontScalingSelf: true),
                ),
              ),
            ),
          ),
          _holidays.fromdate.isBefore(_holidays.toDate)
              ? Container(
                  child: AutoSizeText(
                    _holidays.toDate.toString().substring(0, 11),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize:
                          ScreenUtil().setSp(13, allowFontScalingSelf: true),
                    ),
                  ),
                )
              : Container(
                  child: AutoSizeText(
                    _holidays.fromdate.toString().substring(0, 11),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize:
                          ScreenUtil().setSp(13, allowFontScalingSelf: true),
                    ),
                  ),
                ),
          SizedBox(
            width: 55.w,
            child: Center(
              child: AutoSizeText(
                _holidays.sitename ?? '-',
                maxLines: 2,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(13, allowFontScalingSelf: true),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Center(
              child: AutoSizeText(
                _holidays.shiftName ?? '-',
                maxLines: 2,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(13, allowFontScalingSelf: true),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
