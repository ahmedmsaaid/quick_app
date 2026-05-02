import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SizeBoxExtension on num {
  Widget get verticalSliverSpace =>
      SliverToBoxAdapter(child: ScreenUtil().setVerticalSpacing(this));
  Widget get horizontalSliverSpace =>
      SliverToBoxAdapter(child: ScreenUtil().setHorizontalSpacing(this));
}
