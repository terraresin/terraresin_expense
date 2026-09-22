import 'package:flutter/widgets.dart';

abstract final class TerraResinBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

abstract final class TerraResinResponsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < TerraResinBreakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return width >= TerraResinBreakpoints.mobile &&
        width < TerraResinBreakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= TerraResinBreakpoints.desktop;
  }

  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= TerraResinBreakpoints.mobile;
  }
}
