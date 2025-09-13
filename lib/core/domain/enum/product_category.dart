enum ProductCategory {
  all,
  wholeLife,
  termLife,
  child,
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
    ProductCategory.all => '전상품',
    ProductCategory.wholeLife => '종신보험',
    ProductCategory.termLife => '정기보험',
    ProductCategory.child => '어린이보험',
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
}
