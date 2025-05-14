import 'package:flutter/material.dart';

enum InsuranceCategory {
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
    InsuranceCategory.wholeLife => '종신보험',
    InsuranceCategory.termLife => '정기보험',
    InsuranceCategory.variableWholeLife => '변액종신보험',
    InsuranceCategory.variableAnnuity => '변액연금보험',
    InsuranceCategory.variableSavings => '변액저축보험',
    InsuranceCategory.annuity => '연금보험',
    InsuranceCategory.savings => '저축보험',
    InsuranceCategory.health => '건강보험',
    InsuranceCategory.cancer => '암보험',
    InsuranceCategory.criticalInsurance => '중대질병(CI)보험',
    InsuranceCategory.accidentInsurance => '상해보험',
    InsuranceCategory.autoInsurance => '자동차보험',
    InsuranceCategory.homeInsurance => '주택화재보험',
    InsuranceCategory.etc => '기타',
  };

  IconData getCategoryIcon() {
    return switch (this) {
      InsuranceCategory.wholeLife => Icons.favorite,
      InsuranceCategory.termLife => Icons.access_time,
      InsuranceCategory.variableWholeLife => Icons.swap_vert,
      InsuranceCategory.variableAnnuity => Icons.trending_up,
      InsuranceCategory.variableSavings => Icons.savings,
      InsuranceCategory.annuity => Icons.account_balance_wallet,
      InsuranceCategory.savings => Icons.savings,
      InsuranceCategory.health => Icons.health_and_safety,
      InsuranceCategory.cancer => Icons.biotech,
      InsuranceCategory.criticalInsurance => Icons.warning_amber,
      InsuranceCategory.accidentInsurance => Icons.healing,
      InsuranceCategory.autoInsurance => Icons.directions_car,
      InsuranceCategory.homeInsurance => Icons.home,
      InsuranceCategory.etc => Icons.more_horiz,
    };
  }
}
