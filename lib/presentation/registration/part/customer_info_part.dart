import 'package:intl/intl.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../components/birth_selector.dart';
import '../components/name_field.dart';
import '../components/registered_date_selector.dart';
import '../components/sex_selector.dart';

class CustomerInfoPart extends StatefulWidget {
  final bool isReadOnly;
  final TextEditingController nameController;
  final TextEditingController registeredDateController;
  final TextEditingController birthController;
  final TextEditingController memoController;
  final String? sex;
  final DateTime? birth;
  final void Function(String) onSexChanged;
  final void Function() onBirthInitPressed;
  final void Function(DateTime) onBirthSetPressed;
  final void Function(DateTime) onRegisteredDatePressed;

  final bool isRecommended;
  final TextEditingController recommendedController;
  final void Function(bool) onRecommendedChanged;

  // 🔹 M3 테마 속성 추가
  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;

  const CustomerInfoPart({
    super.key,
    required this.isReadOnly,
    required this.nameController,
    required this.registeredDateController,
    required this.sex,
    this.birth,
    required this.onSexChanged,
    required this.birthController,
    required this.onBirthInitPressed,
    required this.onBirthSetPressed,
    required this.onRegisteredDatePressed,
    required this.isRecommended,
    required this.recommendedController,
    required this.onRecommendedChanged,
    required this.memoController,
    this.backgroundColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
  });

  @override
  State<CustomerInfoPart> createState() => _CustomerInfoPartState();
}

class _CustomerInfoPartState extends State<CustomerInfoPart> {
  late String? _sex;
  late DateTime? _birth;
  late bool _isRecommended;

  @override
  void initState() {
    super.initState();
    _sex = widget.sex;
    _birth = widget.birth;
    _isRecommended = widget.isRecommended;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ItemContainer(
      height: 352,
      backgroundColor: colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름 + 성별
            Row(
              children: [
                Expanded(
                  child: NameField(
                    isReadOnly: widget.isReadOnly,
                    nameController: widget.nameController,
                  ),
                ),
                const SizedBox(width: 20),
                SexSelector(
                  sex: _sex,
                  isReadOnly: widget.isReadOnly,
                  onChanged: widget.isReadOnly
                      ? null
                      : (val) {
                    setState(() => _sex = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 생년월일
            BirthSelector(
              birth: _birth,
              isReadOnly: widget.isReadOnly,
              onInitPressed: widget.isReadOnly
                  ? null
                  : () {
                setState(() {
                  _birth = null;
                  widget.birthController.clear();
                  widget.onBirthInitPressed();
                });
              },
              onSetPressed: widget.isReadOnly
                  ? null
                  : () async {
                final date = await selectDate(context);
                if (date != null) {
                  setState(() {
                    _birth = date;
                    widget.birthController.text = date.toString();
                    widget.onBirthSetPressed(date);
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            // 등록일
            RegisteredDateSelector(
              isReadOnly: widget.isReadOnly,
              registeredDate: DateFormat('yy/MM/dd')
                  .parseStrict(widget.registeredDateController.text),
              onPressed: widget.isReadOnly
                  ? null
                  : () async {
                final date = await selectDate(context);
                if (date != null) {
                  widget.onRegisteredDatePressed(date);
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 8),
            // 메모
            TextFormField(
              controller: widget.memoController,
              enabled: !widget.isReadOnly,
            ),
            const SizedBox(height: 8),
            // 소개 여부 + 소개자
            Row(
              children: [
                const Text('소개 여부'),
                Switch(
                  value: _isRecommended,
                  onChanged: widget.isReadOnly
                      ? null
                      : (val) {
                    setState(() {
                      _isRecommended = val;
                      if (!val) widget.recommendedController.clear();
                    });
                  },
                ),
                if (_isRecommended)
                  Expanded(
                    child: TextFormField(
                      controller: widget.recommendedController,
                      enabled: !widget.isReadOnly,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? get sex => _sex;
  DateTime? get birth => _birth;
  bool get isRecommended => _isRecommended;
}


// class CustomerInfoPart extends StatelessWidget {
//   final bool isReadOnly;
//   final TextEditingController nameController;
//   final TextEditingController registeredDateController;
//   final TextEditingController birthController;
//   final TextEditingController memoController;
//   final String? sex;
//   final DateTime? birth;
//   final void Function(String) onSexChanged;
//   final void Function() onBirthInitPressed;
//   final void Function(DateTime) onBirthSetPressed;
//   final void Function(DateTime) onRegisteredDatePressed;
//
//   final bool isRecommended;
//   final TextEditingController recommendedController;
//   final void Function(bool) onRecommendedChanged;
//
//   // 🔹 M3 테마 속성 추가
//   final Color? backgroundColor;
//   final TextStyle? titleTextStyle;
//   final TextStyle? subtitleTextStyle;
//
//   const CustomerInfoPart({
//     super.key,
//     required this.isReadOnly,
//     required this.nameController,
//     required this.registeredDateController,
//     required this.sex,
//     this.birth,
//     required this.onSexChanged,
//     required this.birthController,
//     required this.onBirthInitPressed,
//     required this.onBirthSetPressed,
//     required this.onRegisteredDatePressed,
//     required this.isRecommended,
//     required this.recommendedController,
//     required this.onRecommendedChanged,
//     required this.memoController,
//     this.backgroundColor,
//     this.titleTextStyle,
//     this.subtitleTextStyle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return ItemContainer(
//       height: 352,
//       backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHighest,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             /// 이름 & 성별
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: NameField(
//                     isReadOnly: isReadOnly,
//                     nameController: nameController,
//                     textStyle: titleTextStyle ??
//                         theme.textTheme.titleMedium?.copyWith(
//                           color: colorScheme.onSurface,
//                         ),
//                   ),
//                 ),
//                 width(20),
//                 SexSelector(
//                   sex: sex,
//                   isReadOnly: isReadOnly,
//                   onChanged: isReadOnly ? null : onSexChanged,
//                 ),
//               ],
//             ),
//             height(3),
//
//             /// 생년월일 선택
//             BirthSelector(
//               birth: birth,
//               isReadOnly: isReadOnly,
//               onInitPressed: isReadOnly ? null : onBirthInitPressed,
//               onSetPressed: isReadOnly
//                   ? null
//                   : () async {
//                 final date = await selectDate(context);
//                 if (date != null) onBirthSetPressed(date);
//               },
//             ),
//             height(3),
//
//             /// 등록일 선택
//             RegisteredDateSelector(
//               isReadOnly: isReadOnly,
//               registeredDate: DateFormat('yy/MM/dd')
//                   .parseStrict(registeredDateController.text),
//               onPressed: isReadOnly
//                   ? null
//                   : () async {
//                 final date = await selectDate(context);
//                 if (date != null) onRegisteredDatePressed(date);
//               },
//             ),
//             height(3),
//
//             /// 메모 입력란
//             SizedBox(
//               height: 60,
//               child: TextFormField(
//                 controller: memoController,
//                 enabled: !isReadOnly,
//                 minLines: 2,
//                 maxLines: null,
//                 scrollPhysics: const BouncingScrollPhysics(),
//                 style: subtitleTextStyle ??
//                     theme.textTheme.bodyMedium?.copyWith(
//                       color: colorScheme.onSurface,
//                     ),
//                 decoration: InputDecoration(
//                   labelText: '메모',
//                   labelStyle: titleTextStyle ??
//                       theme.textTheme.titleMedium?.copyWith(
//                         color: colorScheme.onSurface,
//                       ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: colorScheme.outline),
//                   ),
//                   isDense: true,
//                   contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: colorScheme.outline),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(
//                       color: colorScheme.primary,
//                       width: 1.5,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             height(3),
//
//             /// 소개 여부 & 소개자 이름
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '소개 여부',
//                   style: titleTextStyle ??
//                       theme.textTheme.titleMedium?.copyWith(
//                         color: colorScheme.onSurface,
//                       ),
//                 ),
//                 Switch(
//                   value: isRecommended,
//                   onChanged: isReadOnly ? null : onRecommendedChanged,
//                   activeColor: colorScheme.primary,
//                 ),
//                 const Spacer(),
//                 if (isRecommended)
//                   Expanded(
//                     child: TextFormField(
//                       controller: recommendedController,
//                       textAlign: TextAlign.end,
//                       style: subtitleTextStyle ??
//                           theme.textTheme.bodyMedium?.copyWith(
//                             color: colorScheme.onSurface,
//                           ),
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         errorText: isRecommended &&
//                             recommendedController.text.trim().isEmpty
//                             ? '소개자 이름을 입력하세요'
//                             : null,
//                         errorStyle: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.red,
//                         ),
//                         isDense: true,
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                       enabled: !isReadOnly,
//                       onChanged: (value) {},
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
