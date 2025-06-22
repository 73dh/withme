import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:withme/core/presentation/widget/custom_fitted_box.dart';

import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';

class PolicyPart extends StatelessWidget {
  final String productCategory;
  final String insuranceCompany;
  final void Function(String) onCategoryTap;
  final void Function(String) onCompanyTap;
  final void Function(String) onPremiumMonthTap;
  final void Function(String) onPremiumSingleTap;
  final void Function(String) onProductNameTap;
  final void Function(String) onInputPremiumTap;
  final TextEditingController productNameController;
  final String paymentMethod;
  final TextEditingController premiumController;

  const PolicyPart({
    super.key,
    required this.productCategory,
    required this.insuranceCompany,
    required this.onCategoryTap,
    required this.onCompanyTap,
    required this.productNameController,
    required this.paymentMethod,
    required this.premiumController,
    required this.onPremiumMonthTap,
    required this.onPremiumSingleTap,
    required this.onProductNameTap, required this.onInputPremiumTap,
  });

  @override
  Widget build(BuildContext context) {
    return PartBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  _selectProductCategory(),
                  CustomFittedBox(text: productCategory),
                ],
              ),
              Row(
                children: [
                  _selectInsuranceCompany(),
                  CustomFittedBox(text: insuranceCompany),
                ],
              ),
            ],
          ),
          _inputProductName(),
          height(5),
          Row(
            children: [
              _selectPaymentMethod(),
              const Icon(Icons.more_vert),
              _inputPremium(),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuButton<dynamic> _selectProductCategory() {
    return PopupMenuButton(
      icon: const Icon(Icons.dehaze_outlined),
      onSelected: (value) => onCategoryTap(value.toString()),
      itemBuilder: (context) {
        return ProductCategory.values
            .map(
              (e) => PopupMenuItem(
           value: e,
                child: Row(
                  children: [
                    Icon(e.getCategoryIcon()),
                    width(10),
                    Text(e.toString()),
                  ],
                ),
              ),
            )
            .toList();
      },
    );
  }

  PopupMenuButton<dynamic> _selectInsuranceCompany() {
    return PopupMenuButton(
      icon: const Icon(Icons.warehouse_outlined),
      onSelected: (value)=> onCompanyTap(value.toString()),
      itemBuilder: (context) {
        return InsuranceCompany.values
            .map(
              (e) => PopupMenuItem(
                value: e,
                child: Text(e.toString()),
              ),
            )
            .toList();
      },
    );
  }

  CustomTextFormField _inputProductName() {
    return CustomTextFormField(
      controller: productNameController,
      hintText: '보험 상품명',
      textAlign: TextAlign.center,
      onChanged: onProductNameTap,
      validator: (value) => value.isEmpty ? '상품명을 입력하세요' : null,
      onSaved: (value) => productNameController.text = value,
    );
  }

  Row _selectPaymentMethod() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioMenuButton<String>(
          value: '월납',
          groupValue: paymentMethod,
          onChanged: (value) =>onPremiumMonthTap(value!),
          child: const Text('월납'),
        ),
        RadioMenuButton<String>(
          value: '일시납',
          groupValue: paymentMethod,

          onChanged: (value)=>onPremiumSingleTap(value!),
          child: const Text('일시납'),
        ),
      ],
    );
  }

  Expanded _inputPremium() {
    return Expanded(
      child: CustomTextFormField(
        controller: premiumController,
        hintText: '보험료 (예) 100,000',
        inputType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value)=>onInputPremiumTap(value),
        validator: (value) => value.isEmpty ? '보험료를 입력하세요' : null,
        onSaved: (value) => premiumController.text = value,
      ),
    );
  }
}
