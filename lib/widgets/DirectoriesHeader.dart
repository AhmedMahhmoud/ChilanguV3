import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/constants.dart';

class DirectoriesHeader extends StatelessWidget {
  final lottie;
  final String title;

  const DirectoriesHeader(this.lottie, this.title);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 2,
              color: Colors.orange,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 40.w,
            child: Container(
              // width: 100,
              decoration: const BoxDecoration(
                // image: DecorationImage(
                //   image: headerImage,
                //   fit: BoxFit.fill,
                // ),
                shape: BoxShape.circle,
              ),
              child: lottie,
            ),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Container(
          child: AutoSizeText(title,
              maxLines: 1,
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: setResponsiveFontSize(20),
              )),
        ),
      ],
    );
  }
}

class SmallDirectoriesHeader extends StatelessWidget {
  final lottie;
  final String title;

  const SmallDirectoriesHeader(this.lottie, this.title);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 40.w,
            height: 35.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: lottie,
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          height: 30.h,
          child: AutoSizeText(title,
              style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: ScreenUtil().setSp(
                    19,
                  ))),
        ),
      ],
    );
  }
}
