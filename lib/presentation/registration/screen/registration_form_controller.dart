import 'package:withme/core/utils/core_utils_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_overlay_snack_bar.dart';
import '../../../domain/domain_import.dart';

class RegistrationFormController {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final recommended = TextEditingController();
  final history = TextEditingController(text: '신규등록');
  final birthCtrl = TextEditingController();
  final memo = TextEditingController();
  final registeredDate = TextEditingController();

  DateTime? birth;
  String? sex;

  void initialize(CustomerModel? customer) {
    registeredDate.text =
        customer?.registeredDate.formattedBirth ??
        DateTime.now().formattedBirth;
    if (customer != null) {
      name.text = customer.name;
      sex = customer.sex;
      birth = customer.birth;
      birthCtrl.text = customer.birth?.toString() ?? '';
      memo.text = customer.memo;
      if (customer.recommended.isNotEmpty) {
        recommended.text = customer.recommended;
      }
    }
  }

  void setSex(String? val) => sex = val;

  void clearBirth() {
    birth = null;
    birthCtrl.clear();
  }

  void setBirth(DateTime date) {
    birth = date;
    birthCtrl.text = date.toString();
  }

  void setRegisteredDate(DateTime date) {
    registeredDate.text = date.formattedBirth;
  }

  bool validate(BuildContext context, {required bool isRecommended}) {
    final isValid = formKey.currentState?.validate() ?? false;
    final nameRegex = RegExp(r'^[a-zA-Z가-힣]+$');

    if (name.text.trim().isEmpty) {
      showOverlaySnackBar(context, '고객 이름을 입력하세요');
      return false;
    }
    if (!nameRegex.hasMatch(name.text.trim())) {
      showOverlaySnackBar(context, '이름은 한글 또는 영문만 입력 가능합니다');
      return false;
    }
    if (sex == null) {
      showOverlaySnackBar(context, '성별을 선택 하세요');
      return false;
    }
    if (isRecommended && recommended.text.trim().isEmpty) {
      showOverlaySnackBar(context, '소개자 이름을 입력 하세요');
      return false;
    }
    if (isRecommended && !nameRegex.hasMatch(recommended.text.trim())) {
      showOverlaySnackBar(context, '이름은 한글 또는 영문만 입력 가능합니다');
      return false;
    }
    if (isValid) formKey.currentState!.save();
    return isValid;
  }

  void dispose() {
    name.dispose();
    recommended.dispose();
    history.dispose();
    birthCtrl.dispose();
    memo.dispose();
    registeredDate.dispose();
  }
}
