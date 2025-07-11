import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/presentation/home/dash_board/dash_board_state.dart';

import '../../../core/di/setup.dart';
import '../../../core/router/router.dart';
import '../../../core/router/router_path.dart';
import '../../../core/ui/const/size.dart';
import '../../../data/data_source/remote/fbase.dart';
import '../../../domain/model/user_model.dart';
import 'enum/menu_status.dart';

class DashBoardViewModel with ChangeNotifier {
  DashBoardViewModel() {
    _init();
  }

  DashBoardState _state = DashBoardState();
  DashBoardState get state => _state;

  final _userSession = getIt<UserSession>();

  Future<void> _init() async {
    await _userSession.loadManagePeriodFromPrefs(); // 관리주기 로드
    await loadData();
  }

  Future<void> loadData() async {
    try {
      _state = state.copyWith(isLoading: true);
      notifyListeners();

      final customersAllData = await getIt<CustomerUseCase>().execute(
        usecase: GetAllDataUseCase(userKey: UserSession.userId),
      ) as List<CustomerModel>;

      final contractGrouped = <String, List<CustomerModel>>{};
      final prospectGrouped = <String, List<CustomerModel>>{};

      for (var customer in customersAllData) {
        if (customer.policies.isEmpty) {
          final regDate = customer.registeredDate;
          final regMonth = '${regDate.year}-${regDate.month.toString().padLeft(2, '0')}';
          prospectGrouped.putIfAbsent(regMonth, () => []).add(customer);
          continue;
        }

        for (var policy in customer.policies) {
          final startDate = policy.startDate;
          if (startDate == null) continue;
          final contractMonth = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}';
          contractGrouped.putIfAbsent(contractMonth, () => []).add(customer);
        }
      }

      final monthlyGrouped = <String, Map<String, List<CustomerModel>>>{};
      final allMonths = <String>{...prospectGrouped.keys, ...contractGrouped.keys}.toList()..sort();

      for (var month in allMonths) {
        monthlyGrouped[month] = {
          'prospect': prospectGrouped[month] ?? [],
          'contract': contractGrouped[month] ?? [],
        };
      }

      _state = state.copyWith(
        monthlyCustomers: monthlyGrouped,
        customers: customersAllData,
        histories: customersAllData.expand((e) => e.histories).toList(),
        policies: customersAllData.expand((e) => e.policies).toList(),
        isLoading: false,
      );

      notifyListeners();
    } catch (e, stack) {
      log('loadData error: $e\n$stack');
    }
  }

  /// 메뉴 열고 닫기
  Future<void> toggleMenu(AnimationController controller) async {
    final isOpening = state.menuStatus == MenuStatus.isClosed;

    if (isOpening) {
      // 사용자 정보가 없다면 Firestore에서 가져와서 UserSession에 저장
      if (_userSession.currentUser == null) {
        final snapshot = await getIt<FBase>().getUserInfo();
        final user = UserModel.fromSnapshot(snapshot);
        _userSession.setUserModel(user);
      }

      // 상태에 반영
      _state = state.copyWith(userInfo: _userSession.currentUser);

      // 메뉴 애니메이션 열기
      controller.forward();
      _state = state.copyWith(
        menuStatus: MenuStatus.isOpened,
        bodyXPosition: -AppSizes.myMenuWidth,
        menuXPosition: AppSizes.deviceSize.width - AppSizes.myMenuWidth,
      );
    } else {
      // 메뉴 닫기
      controller.reverse();
      _state = state.copyWith(
        menuStatus: MenuStatus.isClosed,
        bodyXPosition: 0,
        menuXPosition: AppSizes.deviceSize.width,
      );
    }

    notifyListeners();
  }

  void forceCloseMenu() {
    if (state.menuStatus == MenuStatus.isOpened) {
      _state = state.copyWith(
        menuStatus: MenuStatus.isClosed,
        bodyXPosition: 0,
        menuXPosition: AppSizes.deviceSize.width,
      );
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    getIt<UserSession>().clear(); // 상태 초기화
    getIt<AuthChangeNotifier>().setLoggedIn(false);
    if (context.mounted) context.go(RoutePath.login);
  }

  Future<void> signOut(BuildContext context, Map<String, dynamic> credentials) async {
    await getIt<FBase>().deleteUserAccountAndData(
      userId: UserSession.userId,
      email: credentials['email']!,
      password: credentials['password']!,
    );
    getIt<UserSession>().clear(); // 상태 초기화
    getIt<AuthChangeNotifier>().setLoggedIn(false);
    if (context.mounted) context.go(RoutePath.login);
  }

  void sendSMS({required String phoneNumber, required String message}) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber, queryParameters: {'body': message});
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('문자 앱을 열 수 없습니다.');
    }
  }

  void sendInquiryEmail(BuildContext context) async {
    final email = _userSession.currentUser?.email ?? 'unknown@unknown.com';

    final Uri emailUri = Uri.parse(
      'mailto:kdaehee@gmail.com?subject=${Uri.encodeComponent("유료회원 문의")}'
          '&body=${Uri.encodeComponent("안녕하세요,\n\n유저 이메일: $email\n\n유료회원 가입에 대해 문의드립니다.")}',
    );

    final bool launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('메일 앱 없음'),
          content: const Text('메일 앱이 설치되어 있지 않거나 실행할 수 없습니다.\n앱스토어에서 메일 앱을 설치해 주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'kdaehee@gmail.com'));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이메일 주소가 복사되었습니다.')),
                );
              },
              child: const Text('이메일 복사'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }
}

//
// class DashBoardViewModel with ChangeNotifier {
//   DashBoardViewModel() {
//     _init();
//   }
//
//   DashBoardState _state = DashBoardState();
//
//   DashBoardState get state => _state;
//
//   Future<void> _init() async {
//     await loadData(); // async 함수 별도로 실행
//   }
//
//   Future<void> loadData() async {
//     try {
//       _state = state.copyWith(isLoading: true);
//       notifyListeners();
//
//       final customersAllData =
//           await getIt<CustomerUseCase>().execute(
//                 usecase: GetAllDataUseCase(userKey: UserSession.userId),
//               )
//               as List<CustomerModel>;
//
//       // 월별 계약 고객 그룹 (startDate 기준)
//       final Map<String, List<CustomerModel>> contractGrouped = {};
//
//       // 월별 가망 고객 그룹 (registeredDate 기준, 계약 없는 고객)
//       final Map<String, List<CustomerModel>> prospectGrouped = {};
//
//       for (var customer in customersAllData) {
//         // 가망 고객 (계약 없는 고객)
//         if (customer.policies.isEmpty || customer.policies.isEmpty) {
//           final regDate = customer.registeredDate;
//           final regMonth =
//               '${regDate.year}-${regDate.month.toString().padLeft(2, '0')}';
//
//           prospectGrouped.putIfAbsent(regMonth, () => []);
//           prospectGrouped[regMonth]!.add(customer);
//           continue; // 계약 없으니 아래 계약 처리 건너뜀
//         }
//
//         // 계약 고객 - 계약별 startDate 기준
//         for (var policy in customer.policies) {
//           final startDate = policy.startDate;
//           if (startDate == null) continue;
//
//           final contractMonth =
//               '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}';
//
//           contractGrouped.putIfAbsent(contractMonth, () => []);
//           contractGrouped[contractMonth]!.add(customer);
//         }
//       }
//
//       // 여기서 월별로 둘 다 합쳐서 원하는 형태로 사용 가능
//       // 예: 한 map에 month별로 { 'prospect': [...], 'contract': [...] } 형태
//
//       final Map<String, Map<String, List<CustomerModel>>> monthlyGrouped = {};
//
//       final allMonths =
//           <String>{...prospectGrouped.keys, ...contractGrouped.keys}.toList()
//             ..sort();
//
//       for (var month in allMonths) {
//         monthlyGrouped[month] = {
//           'prospect': prospectGrouped[month] ?? [],
//           'contract': contractGrouped[month] ?? [],
//         };
//       }
//
//       _state = state.copyWith(
//         monthlyCustomers: monthlyGrouped,
//         customers: customersAllData,
//         histories: customersAllData.expand((e) => e.histories).toList(),
//         policies: customersAllData.expand((e) => e.policies).toList(),
//         isLoading: false,
//       );
//
//       notifyListeners();
//     } catch (e, stack) {
//       log(e.toString());
//     }
//   }
//
//   void setUserInfo(UserModel user) {
//     _state = state.copyWith(userInfo: user);
//   }
//
//   Future<void> toggleMenu(AnimationController controller) async {
//     final isOpening = state.menuStatus == MenuStatus.isClosed;
//
//     if (isOpening) {
//       // 1. 사용자 정보 로드 (필요 시)
//
//       // final snapshot = await getIt<FBase>().getUserInfo();
//       // final user = UserModel.fromSnapshot(snapshot);
//       // setUserInfo(user);
//       // Firestore에서 불러오는 대신 UserSession에서 사용자 정보 가져오기
//       final user = getIt<UserSession>().currentUserModel;
//       if (user != null) {
//         setUserInfo(user);
//       } else {
//         // UserSession에 정보가 없으면 필요 시 Firestore에서 다시 불러오기
//         final snapshot = await getIt<FBase>().getUserInfo();
//         final userFromFirestore = UserModel.fromSnapshot(snapshot);
//         setUserInfo(userFromFirestore);
//
//         // 그리고 UserSession에 저장
//         getIt<UserSession>().currentUserModel = userFromFirestore;
//       }
//
//       // 2. 메뉴 열기 애니메이션
//       controller.forward();
//       _state = state.copyWith(
//         menuStatus: MenuStatus.isOpened,
//         bodyXPosition: -AppSizes.myMenuWidth,
//         menuXPosition: AppSizes.deviceSize.width - AppSizes.myMenuWidth,
//       );
//     } else {
//       // 3. 메뉴 닫기 애니메이션
//       controller.reverse();
//       print('close');
//       _state = state.copyWith(
//         menuStatus: MenuStatus.isClosed,
//         bodyXPosition: 0,
//         menuXPosition: AppSizes.deviceSize.width,
//       );
//     }
//
//     notifyListeners(); // ✅ UI에 변경사항 알림
//   }
//
//   // 화면 이동시 sideMenu 닫음
//   void forceCloseMenu() {
//     if (state.menuStatus == MenuStatus.isOpened) {
//       _state = state.copyWith(
//         menuStatus: MenuStatus.isClosed,
//         bodyXPosition: 0,
//         menuXPosition: AppSizes.deviceSize.width,
//       );
//       notifyListeners();
//     }
//   }
//
//   Future<void> logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     final authChangeNotifier = getIt<AuthChangeNotifier>();
//     authChangeNotifier.setLoggedIn(false); // ✅ 로그인 상태 변화 알림
//     if (context.mounted) {
//       context.go(RoutePath.login); // ✅ 명시적으로 이동 (안전망 역할)
//     }
//   }
//
//   Future<void> signOut(
//     BuildContext context,
//     Map<String, dynamic> credentials,
//   ) async {
//     await getIt<FBase>().deleteUserAccountAndData(
//       userId: UserSession.userId,
//       email: credentials['email']!,
//       password: credentials['password']!,
//     );
//     final authChangeNotifier = getIt<AuthChangeNotifier>();
//     authChangeNotifier.setLoggedIn(false); // ✅ 로그인 상태 변화 알림
//     if (context.mounted) {
//       context.go(RoutePath.login); // ✅ 명시적으로 이동 (안전망 역할)
//     }
//   }
//
//   void sendSMS({required String phoneNumber, required String message}) async {
//     final Uri smsUri = Uri(
//       scheme: 'sms',
//       path: phoneNumber,
//       queryParameters: {'body': message},
//     );
//
//     if (await canLaunchUrl(smsUri)) {
//       await launchUrl(smsUri, mode: LaunchMode.externalApplication);
//     } else {
//       // 앱을 열 수 없을 때 처리
//       debugPrint('문자 앱을 열 수 없습니다.');
//     }
//   }
//
//   void sendInquiryEmail(BuildContext context) async {
//     final email = state.userInfo?.email ?? 'unknown@unknown.com';
//
//     final String subject = Uri.encodeComponent('유료회원 문의');
//     final String body = Uri.encodeComponent(
//       '안녕하세요,\n\n유저 이메일: $email\n\n유료회원 가입에 대해 문의드립니다.',
//     );
//
//     final Uri emailUri = Uri.parse(
//       'mailto:kdaehee@gmail.com?subject=$subject&body=$body',
//     );
//
//     final bool launched = await launchUrl(
//       emailUri,
//       mode: LaunchMode.externalApplication,
//     );
//
//     if (!launched && context.mounted) {
//       showDialog(
//         context: context,
//         builder:
//             (_) => AlertDialog(
//               title: const Text('메일 앱 없음'),
//               content: const Text(
//                 '메일 앱이 설치되어 있지 않거나 실행할 수 없습니다.\n앱스토어에서 메일 앱을 설치해 주세요.',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Clipboard.setData(
//                       const ClipboardData(text: 'kdaehee@gmail.com'),
//                     );
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('이메일 주소가 복사되었습니다.')),
//                     );
//                   },
//                   child: const Text('이메일 복사'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('확인'),
//                 ),
//               ],
//             ),
//       );
//     }
//   }
// }
