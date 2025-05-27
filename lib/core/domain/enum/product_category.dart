import 'package:flutter/material.dart';

enum ProductCategory {
  all,
  wholeLife,
  termLife,
  variableWholeLife,
  variableAnnuity,
  variableSavings,
  annuity,
  savings,
  health,
  cancer,
  criticalInsurance,
  accidentInsurance,
  autoInsurance,
  homeInsurance,
  etc;

  @override
  String toString() => switch (this) {
    ProductCategory.all=>'전체상품',
    ProductCategory.wholeLife => '종신보험',
    ProductCategory.termLife => '정기보험',
    ProductCategory.variableWholeLife => '변액종신보험',
    ProductCategory.variableAnnuity => '변액연금보험',
    ProductCategory.variableSavings => '변액저축보험',
    ProductCategory.annuity => '연금보험',
    ProductCategory.savings => '저축보험',
    ProductCategory.health => '건강보험',
    ProductCategory.cancer => '암보험',
    ProductCategory.criticalInsurance => '중대질병(CI)보험',
    ProductCategory.accidentInsurance => '상해보험',
    ProductCategory.autoInsurance => '자동차보험',
    ProductCategory.homeInsurance => '주택화재보험',
    ProductCategory.etc => '기타',
  };

  IconData getCategoryIcon() {
    return switch (this) {
      ProductCategory.all=>Icons.info,
      ProductCategory.wholeLife => Icons.favorite,
      ProductCategory.termLife => Icons.access_time,
      ProductCategory.variableWholeLife => Icons.swap_vert,
      ProductCategory.variableAnnuity => Icons.trending_up,
      ProductCategory.variableSavings => Icons.savings,
      ProductCategory.annuity => Icons.account_balance_wallet,
      ProductCategory.savings => Icons.savings,
      ProductCategory.health => Icons.health_and_safety,
      ProductCategory.cancer => Icons.biotech,
      ProductCategory.criticalInsurance => Icons.warning_amber,
      ProductCategory.accidentInsurance => Icons.healing,
      ProductCategory.autoInsurance => Icons.directions_car,
      ProductCategory.homeInsurance => Icons.home,
      ProductCategory.etc => Icons.more_horiz,
    };
  }
}
