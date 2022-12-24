import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';

import '../../DirectoriesHeader.dart';

class OutsideVacHeader extends StatelessWidget {
  final String memberName;
  const OutsideVacHeader({this.memberName, key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SmallDirectoriesHeader(
              Lottie.asset("resources/calender.json", repeat: false),
              getTranslated(context, "الأجازات و المأموريات"),
            ),
          ],
        ),
        VacationCardHeader(
          header:
              "${getTranslated(context, "تسجيل طلب للمستخدم:")} $memberName",
        ),
        VacationCardHeader(
          header: getTranslated(context, "نوع الطلب"),
        ),
      ],
    );
  }
}
