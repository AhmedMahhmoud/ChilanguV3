import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/AddVacationScreen.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/user_data.dart';

import '../roundedAlert.dart';

class DataTableVacationRow extends StatelessWidget {
  final Vacation vacation;
  final DateTime filterToDate, filterFromDate;
  final Function clearTextFieldCallback;
  const DataTableVacationRow(
      {this.vacation,
      this.filterFromDate,
      this.filterToDate,
      this.clearTextFieldCallback});
  @override
  Widget build(BuildContext context) {
    final SlidableController slidableController = SlidableController();
    final vactionProv = Provider.of<VacationData>(context, listen: false);
    return isDateBetweenTheRange(vacation, filterFromDate, filterToDate)
        ? Slidable(
            enabled: vacation.vacationDate.isAfter(DateTime.now()),
            secondaryActions: [
              ZoomIn(
                  child: InkWell(
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddVacationScreen(
                          edit: true,
                          vacation: vacation,
                        ),
                      ));
                },
              )),
              vacation.vacationDate.isBefore(DateTime.now())
                  ? Container()
                  : ZoomIn(
                      child: InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        return showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return vactionProv.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.orange,
                                      ),
                                    )
                                  : RoundedAlert(
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        final String msg = await vactionProv
                                            .deleteVacationById(
                                                Provider.of<UserData>(context,
                                                        listen: false)
                                                    .user
                                                    .userToken,
                                                vacation.vacationId,
                                                vactionProv
                                                    .getVacationIndexByID(
                                                        vacation.vacationId));
                                        if (msg == "Success") {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(
                                                  context, "تم الحذف بنجاح"),
                                              backgroundColor: Colors.green);
                                          clearTextFieldCallback();
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(
                                                  context, "خطأ في حذف العطلة"),
                                              backgroundColor: Colors.red);
                                        }
                                      },
                                      content:
                                          "${getTranslated(context, "هل تريد حذف")}  : ${vacation.vacationName}؟",
                                      onCancel: () {},
                                      title:
                                          getTranslated(context, "حذف العطلة"),
                                    );
                            });
                      },
                    )),
            ],
            actionExtentRatio: 0.10,
            closeOnScroll: true,
            controller: slidableController,
            actionPane: const SlidableDrawerActionPane(),
            child: Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 160.w,
                      height: 40.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            child: AutoSizeText(
                              vacation.vacationName,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(14, allowFontScalingSelf: true),
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 20.h,
                      child: AutoSizeText(
                        vacation.vacationDate.toString().substring(0, 11),
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: ScreenUtil()
                                .setSp(14, allowFontScalingSelf: true),
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }
}
