import 'package:flutter/rendering.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/Core/constants.dart';

import 'package:qr_users/services/Reports/Services/report_data.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoRecordsOfficialVacation extends StatelessWidget {
  const NoRecordsOfficialVacation({
    Key key,
    @required this.reportsData,
  }) : super(key: key);

  final ReportsData reportsData;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 20,
              child: AutoSizeText(
                getTranslated(context, "لا يوجد تسجيلات : عطلة رسمية"),
                maxLines: 1,
                style: boldStyle,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 20,
              child: AutoSizeText(reportsData.dailyReport.officialHoliday,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize:
                        ScreenUtil().setSp(17, allowFontScalingSelf: true),
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
