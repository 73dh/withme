import 'package:flutter/services.dart';

import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/const/size.dart';

class PolicyPart extends StatelessWidget {
  final String productCategory;
  final String insuranceCompany;
  final void Function(String) onCategoryTap;
  final void Function(String) onCompanyTap;
  final void Function(String) onPremiumMonthTap;
  final void Function(String) onPremiumSingleTap;
  final void Function(String) onProductNameTap;
  final void Function(String) onInputPremiumTap;
  final void Function(String)? onInputPaymentPeriodTap; // PolicyPart에 추가
  final TextEditingController productNameController;
  final String paymentMethod;
  final TextEditingController premiumController;
  final TextEditingController paymentPeriodController;

  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime) onStartDateChanged;
  final void Function(DateTime) onEndDateChanged;

  const PolicyPart({
    super.key,
    required this.productCategory,
    required this.insuranceCompany,
    required this.onCategoryTap,
    required this.onCompanyTap,
    required this.productNameController,
    required this.paymentMethod,
    required this.premiumController,
    required this.paymentPeriodController,
    required this.onPremiumMonthTap,
    required this.onPremiumSingleTap,
    required this.onProductNameTap,
    required this.onInputPremiumTap,
    required this.onInputPaymentPeriodTap,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final companyPopupItems =
        InsuranceCompany.values.skip(1).toList()
          ..sort((a, b) => a.toString().compareTo(b.toString()));

    return ItemContainer(
      height: 220,
      backgroundColor: colorScheme.surfaceContainerHighest, // theme 적용
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 카테고리, 보험사, 상품명
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPopupButton(
                    context,
                    icon: Icons.dehaze_outlined,
                    label: productCategory,
                    onSelected: onCategoryTap,
                    items:
                        ProductCategory.values
                            .skip(1)
                            .map<PopupMenuEntry<ProductCategory>>(
                              (e) => PopupMenuItem<ProductCategory>(
                                value: e,
                                child: Text(
                                  e.toString(),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  width(12),
                  _buildPopupButton(
                    context,
                    icon: Icons.holiday_village_outlined,
                    label: insuranceCompany,
                    onSelected: onCompanyTap,
                    items:
                        companyPopupItems
                            .map<PopupMenuEntry<InsuranceCompany>>(
                              (e) => PopupMenuItem<InsuranceCompany>(
                                value: e,

                                child: Text(
                                  e.toString(),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  width(12),
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: productNameController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: '상품명 입력',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      onChanged: onProductNameTap,
                    ),
                  ),
                ],
              ),
              height(10),

              // 하단: 납입방식, 보험료, 납입기간
              Row(
                children: [
                  // 납입방식 Toggle
                  ToggleButtons(
                    isSelected: [paymentMethod == '월납', paymentMethod == '일시납'],
                    constraints: BoxConstraints(
                      minWidth: AppSizes.toggleMinWidth,
                      minHeight: 38,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    onPressed: (index) {
                      if (index == 0) {
                        onPremiumMonthTap('월납');
                        paymentPeriodController.text = '';
                      } else {
                        onPremiumSingleTap('일시납');
                        paymentPeriodController.text = '일시납';
                      }
                    },
                    selectedColor: colorScheme.onPrimary,
                    fillColor: colorScheme.primary,
                    color: colorScheme.onSurface,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('월납'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('일시납'),
                      ),
                    ],
                  ),
                  width(12),

                  // 납입기간 입력
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: paymentPeriodController,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        FilteringTextInputFormatter.deny(RegExp(r'^0+$')),
                        // 0 입력 방지
                      ],
                      decoration: InputDecoration(
                        hintText:
                            paymentMethod == '월납' ? '납입기간 입력(예: 5)' : '일시납',
                        suffixText: paymentMethod == '월납' ? ' 년' : null,
                        suffixStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      enabled: paymentMethod == '월납',
                      onChanged: onInputPaymentPeriodTap,
                    ),
                  ),

                  // 보험료 입력
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: premiumController,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: '보험료',
                        suffixText: ' 원',
                        suffixStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      onChanged: onInputPremiumTap,
                    ),
                  ),
                ],
              ),

              height(20),

              // 계약일 / 만기일
              Row(
                children: [
                  Expanded(
                    child: RenderFilledButton(
                      borderRadius: 5,
                      backgroundColor:
                          startDate == null
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                      foregroundColor:
                          startDate == null
                              ? colorScheme.onPrimary
                              : colorScheme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                      onPressed: () async {
                        DateTime? selected = await selectDate(
                          context,
                          initial: startDate,
                        );
                        if (selected != null) {
                          onStartDateChanged(selected);
                        }
                      },
                      text:
                          startDate == null
                              ? '계약일'
                              : '개시일: ${startDate!.toLocal().toIso8601String().split('T')[0]}',
                    ),
                  ),
                  width(16),
                  Expanded(
                    child: RenderFilledButton(
                      borderRadius: 5,
                      backgroundColor:
                          endDate == null
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                      foregroundColor:
                          endDate == null
                              ? colorScheme.onPrimary
                              : colorScheme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                      onPressed: () async {
                        DateTime? selected = await selectDate(
                          context,
                          initial: endDate,
                        );
                        if (selected != null) {
                          onEndDateChanged(selected);
                        }
                      },
                      text:
                          endDate == null
                              ? '만기일'
                              : '만기일: ${endDate!.toLocal().toIso8601String().split('T')[0]}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildPopupButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required void Function(String) onSelected,
  required List<PopupMenuEntry> items,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return Column(
    children: [
      PopupMenuButton(
        icon: Icon(icon, color: colorScheme.primary),
        onSelected: (value) => onSelected(value.toString()),
        itemBuilder: (context) => items,
      ),
      Text(
        label,
        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
