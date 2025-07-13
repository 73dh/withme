import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../core/domain/sort_status.dart';

import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../core/domain/sort_status.dart';
import 'package:flutter/material.dart'; // 필수 import 확인

import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/core_ui_import.dart'; // ColorStyles, AppDurations 등이 정의된 경로
import 'package:withme/core/domain/sort_status.dart'; // SortType, SortStatus 등이 정의된 경로

import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/core_ui_import.dart'; // ColorStyles가 정의된 경로
import 'package:withme/core/domain/sort_status.dart'; // SortType, SortStatus가 정의된 경로

import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/duration.dart'; // AppDurations 임포트 경로 확인
import 'package:withme/core/ui/core_ui_import.dart'; // ColorStyles 임포트 경로 확인
import 'package:withme/core/domain/sort_status.dart'; // SortType, SortStatus 임포트 경로 확인

class SmallFab extends StatefulWidget {
  final bool fabVisibleLocal;
  final bool fabExpanded;
  final void Function(void Function())? overlaySetState;
  final void Function()? onSortByName;
  final void Function()? onSortByBirth;
  final void Function()? onSortByInsuredDate;
  final void Function()? onSortByManage;
  final SortStatus? selectedSortStatus; // ViewModel로부터 받은 현재 정렬 상태

  const SmallFab({
    super.key,
    required this.fabVisibleLocal,
    required this.fabExpanded,
    this.overlaySetState,
    this.onSortByName,
    this.onSortByBirth,
    this.onSortByInsuredDate,
    this.onSortByManage,
    this.selectedSortStatus,
  });

  @override
  State<SmallFab> createState() => _SmallFabState();
}

class _SmallFabState extends State<SmallFab> with TickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  late final AnimationController _visibilityController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      vsync: this,
      duration: AppDurations.duration300,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    _visibilityController = AnimationController(
      vsync: this,
      duration: AppDurations.duration100,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeInOut,
    );

    // 초기 상태에 따라 애니메이션 컨트롤러 설정
    if (widget.fabVisibleLocal) {
      _visibilityController.forward();
    }
    if (widget.fabExpanded) {
      _expandController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SmallFab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // fabExpanded 상태 변경 감지 및 애니메이션 실행
    if (widget.fabExpanded != oldWidget.fabExpanded) {
      widget.fabExpanded ? _expandController.forward() : _expandController.reverse();
    }

    // fabVisibleLocal 상태 변경 감지 및 애니메이션 실행
    if (widget.fabVisibleLocal != oldWidget.fabVisibleLocal) {
      if (widget.fabVisibleLocal) {
        _visibilityController.forward();
      } else {
        _visibilityController.reverse();
      }
    }
    // selectedSortStatus는 자동으로 rebuild될 때 _buildMiniAction에서 반영됩니다.
    // 여기에 별도의 setState 호출은 필요하지 않습니다.
  }

  @override
  void dispose() {
    _expandController.dispose();
    _visibilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 정렬 옵션 그룹
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_expandAnimation),
                  child: _buildSortActions(),
                ),
              ),
            ),
            // 정렬 옵션과 메인 FAB 사이 간격
            if (widget.fabExpanded) const SizedBox(height: 4),

            // 메인 FAB 버튼
            FloatingActionButton.small(
              key: const ValueKey('mainSmallFab'),
              heroTag: 'mainSmallFab',
              backgroundColor: ColorStyles.fabColor,
              onPressed: () {
                // 이 콜백은 FabOverlayManagerMixin의 _toggleFabExpanded를 호출합니다.
                // _toggleFabExpanded 내부에서 _overlaySetState가 호출되어
                // 오버레이 전체(SmallFab 포함)를 다시 빌드하게 됩니다.
                widget.overlaySetState?.call(() {});
              },
              child: AnimatedSwitcher( // 아이콘 전환 애니메이션
                duration: AppDurations.duration300,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  widget.fabExpanded ? Icons.close : Icons.sort_outlined,
                  key: ValueKey(widget.fabExpanded), // 키를 변경하여 애니메이션 트리거
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortActions() {
    final status = widget.selectedSortStatus; // ViewModel에서 전달받은 현재 정렬 상태
    final actions = <Map<String, dynamic>>[];

    if (widget.onSortByName != null) {
      actions.add({'label': '이름순', 'onTap': widget.onSortByName, 'type': SortType.name});
    }
    if (widget.onSortByBirth != null) {
      actions.add({'label': '생일순', 'onTap': widget.onSortByBirth, 'type': SortType.birth});
    }
    if (widget.onSortByInsuredDate != null) {
      actions.add({'label': '상령일순', 'onTap': widget.onSortByInsuredDate, 'type': SortType.insuredDate});
    }
    if (widget.onSortByManage != null) {
      actions.add({'label': '관리순', 'onTap': widget.onSortByManage, 'type': SortType.manage});
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var action in actions)
          GestureDetector(
            onTap: action['onTap'] as void Function()?, // 정렬 액션 실행
            child: _buildMiniAction(
              action['label'] as String,
              isSelected: status?.type == action['type'], // 현재 정렬 타입과 일치하는지 확인
              isAscending: status?.type == action['type'] ? status?.isAscending : null, // 일치하면 정렬 방향 전달
            ),
          ),
      ],
    );
  }

  Widget _buildMiniAction(
      String label, {
        required bool isSelected,
        bool? isAscending,
      }) {
    IconData? icon;
    // 선택된 상태이고, 정렬 방향 정보가 있을 때만 화살표 아이콘 설정
    if (isSelected && isAscending != null) {
      icon = isAscending ? Icons.arrow_downward : Icons.arrow_upward;
    }

    return Container(
      width: 90,
      height: 32,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        // 선택 여부에 따라 배경색 변경
        color: isSelected ? ColorStyles.selectedFabColor : ColorStyles.fabColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              // 선택 여부에 따라 텍스트 색상 변경 (명암비 개선)
              color: isSelected ? Colors.black87 : Colors.black54,
              fontSize: 13,
            ),
          ),
          if (icon != null) ...[ // 화살표 아이콘이 있을 때만 표시
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: Colors.black54), // 화살표 아이콘 색상
          ],
        ],
      ),
    );
  }
}

// Dummy ColorStyles, AppDurations, SortType, SortStatus (실제 앱에서는 해당 경로에서 임포트됩니다.)
// 만약 이 클래스들이 정의되어 있지 않다면, 이 코드를 임시로 추가하여 컴파일 오류를 방지하세요.
/*
class ColorStyles {
  static const Color fabColor = Colors.blueGrey;
  static const Color selectedFabColor = Colors.lightBlue;
}

class AppDurations {
  static const Duration duration100 = Duration(milliseconds: 100);
  static const Duration duration300 = Duration(milliseconds: 300);
}

enum SortType { name, birth, insuredDate, manage }

class SortStatus {
  final SortType type;
  final bool isAscending;
  SortStatus({required this.type, this.isAscending = true});
}
*/
//
// class SmallFab extends StatefulWidget {
//   final bool fabVisibleLocal;
//   final bool fabExpanded;
//   final void Function(void Function())? overlaySetState;
//   final void Function(void Function())? overlaySetStateFold;
//   final void Function()? onSortByName;
//   final void Function()? onSortByBirth;
//   final void Function()? onSortByInsuredDate;
//   final void Function()? onSortByManage;
//   final SortStatus? selectedSortStatus; // 정렬 상태 및 방향 정보
//
//   const SmallFab({
//     super.key,
//     required this.fabVisibleLocal,
//     required this.fabExpanded,
//     this.overlaySetState,
//     this.overlaySetStateFold,
//     this.onSortByName,
//     this.onSortByBirth,
//     this.onSortByInsuredDate,
//     this.onSortByManage,
//     this.selectedSortStatus,
//   });
//
//   @override
//   State<SmallFab> createState() => _SmallFabState();
// }
//
// class _SmallFabState extends State<SmallFab> with TickerProviderStateMixin {
//   late final AnimationController _expandController;
//   late final Animation<double> _expandAnimation;
//
//   late final AnimationController _visibilityController;
//   late final Animation<double> _scaleAnimation;
//   late final Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Expansion animation (fabExpanded)
//     _expandController = AnimationController(
//       vsync: this,
//       duration: AppDurations.duration300,
//     );
//     _expandAnimation = CurvedAnimation(
//       parent: _expandController,
//       curve: Curves.easeInOut,
//     );
//
//     // Visibility animation (fabVisibleLocal)
//     _visibilityController = AnimationController(
//       vsync: this,
//       duration: AppDurations.duration100,
//     );
//     _scaleAnimation = CurvedAnimation(
//       parent: _visibilityController,
//       curve: Curves.easeOutBack,
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _visibilityController,
//       curve: Curves.easeInOut,
//     );
//
//     if (widget.fabVisibleLocal) {
//       _visibilityController.forward();
//     }
//   }
//
//   @override
//   void didUpdateWidget(covariant SmallFab oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     // Animate expand/collapse
//     widget.fabExpanded
//         ? _expandController.forward()
//         : _expandController.reverse();
//
//     // Animate show/hide
//     if (widget.fabVisibleLocal) {
//       _visibilityController.forward();
//     } else {
//       _visibilityController.reverse();
//     }
//   }
//
//   @override
//   void dispose() {
//     _expandController.dispose();
//     _visibilityController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             SizeTransition(
//               sizeFactor: _expandAnimation,
//               child: FadeTransition(
//                 opacity: _expandAnimation,
//                 child: SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(0, 0.2),
//                     end: Offset.zero,
//                   ).animate(_expandAnimation),
//                   child: _buildSortActions(),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             if (!widget.fabExpanded)
//               FloatingActionButton.small(
//                 key: const ValueKey('smallFab'),
//                 heroTag: 'smallFab',
//                 backgroundColor: ColorStyles.fabColor,
//                 onPressed: () => widget.overlaySetState?.call(() {}),
//                 child: const Icon(Icons.sort_outlined, color: Colors.black87),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSortActions() {
//     final status = widget.selectedSortStatus;
//     final actions = <Map<String, dynamic>>[];
//
//     if (widget.onSortByName != null) {
//       actions.add({
//         'label': '이름순',
//         'onTap': widget.onSortByName,
//         'type': SortType.name,
//       });
//     }
//     if (widget.onSortByBirth != null) {
//       actions.add({
//         'label': '생일순',
//         'onTap': widget.onSortByBirth,
//         'type': SortType.birth,
//       });
//     }
//     if (widget.onSortByInsuredDate != null) {
//       actions.add({
//         'label': '상령일순',
//         'onTap': widget.onSortByInsuredDate,
//         'type': SortType.insuredDate,
//       });
//     }
//     if (widget.onSortByManage != null) {
//       actions.add({
//         'label': '관리순',
//         'onTap': widget.onSortByManage,
//         'type': SortType.manage,
//       });
//     }
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         for (var action in actions)
//           GestureDetector(
//             onTap: action['onTap'] as void Function()?,
//             child: _buildMiniAction(
//               action['label'] as String,
//               isSelected: status?.type == action['type'],
//               isAscending:
//                   status?.type == action['type'] ? status?.isAscending : null,
//             ),
//           ),
//         const SizedBox(height: 8),
//         FloatingActionButton.small(
//           heroTag: 'fabClose',
//           backgroundColor: ColorStyles.fabColor,
//           onPressed: () => widget.overlaySetStateFold?.call(() {}),
//           child: const Icon(Icons.close, color: Colors.black87),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMiniAction(
//     String label, {
//     required bool isSelected,
//     bool? isAscending,
//   }) {
//     IconData? icon;
//     if (isSelected && isAscending != null) {
//       icon = isAscending ? Icons.arrow_downward : Icons.arrow_upward;
//     }
//
//     return Container(
//       width: 90,
//       height: 32,
//       margin: const EdgeInsets.symmetric(vertical: 2),
//       decoration: BoxDecoration(
//         color: isSelected ? ColorStyles.selectedFabColor : ColorStyles.fabColor,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? Colors.black87 : Colors.black38,
//               fontSize: 13,
//             ),
//           ),
//           if (icon != null) ...[
//             const SizedBox(width: 4),
//             Icon(icon, size: 14, color: Colors.black54),
//           ],
//         ],
//       ),
//     );
//   }
// }
