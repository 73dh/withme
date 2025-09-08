import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/screen/dash_board_root.dart';

import '../../../presentation/home/customer_list/screen/customer_list_page.dart';
import '../../../presentation/home/prospect_list/screen/prospect_list_page.dart';
import '../../../presentation/home/search/screen/search_page.dart';
import '../../ui/icon/const.dart';

enum HomeMenu {
  prospect(label: '가망고객', iconPath: IconsPath.prospectPerson),
  customer(label: '계약고객', iconPath: IconsPath.folderIcon),
  search(label: '검색', iconPath: IconsPath.searchPerson),
  dashBoard(label: '대시보드', iconPath: IconsPath.dashBoard);

  final String label; // ✅ 사용자에게 보일 라벨 (Analytics screenName, UI)
  final String iconPath;

  const HomeMenu({required this.label, required this.iconPath});

  Widget get toWidget => switch (this) {
    HomeMenu.prospect => const ProspectListPage(),
    HomeMenu.customer => const CustomerListPage(),
    HomeMenu.search => const SearchPage(),
    HomeMenu.dashBoard => const DashBoardRoot(),
  };

  String get toAnalyticsName => label; // ✅ Analytics에서 쓸 이름
}
//
// enum HomeMenu {
//   prospect(name: 'Prospect', iconPath: IconsPath.prospectPerson),
//   customer(name: 'Customer', iconPath: IconsPath.folderIcon),
//   search(name: 'Search', iconPath: IconsPath.searchPerson),
//   dashBoard(name: 'DashBoard', iconPath: IconsPath.dashBoard);
//
//   final String name;
//   final String iconPath;
//
//   const HomeMenu({required this.name, required this.iconPath});
//
//   Widget get toWidget => switch (this) {
//     HomeMenu.prospect => const ProspectListPage(),
//     HomeMenu.customer => const CustomerListPage(),
//     HomeMenu.search => const SearchPage(),
//     HomeMenu.dashBoard => const DashBoardRoot(),
//   };
// }
