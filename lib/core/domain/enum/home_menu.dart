import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/dash_board_page.dart';

import '../../../presentation/home/customer_list/screen/customer_list_page.dart';
import '../../../presentation/home/prospect_list/screen/prospect_list_page.dart';
import '../../../presentation/home/search/screen/search_page.dart';
import '../../ui/icon/const.dart';

enum HomeMenu {
  prospect(name: 'Prospect', iconPath: IconsPath.prospectPerson),
  customer(name: 'Customer', iconPath: IconsPath.customerPerson),
  search(name: 'Search', iconPath: IconsPath.searchPerson),
  dashBoard(name: 'DashBoard', iconPath: IconsPath.dashBoard);

  final String name;
  final String iconPath;

  const HomeMenu({required this.name, required this.iconPath});

  Widget get toWidget => switch (this) {
    HomeMenu.prospect =>  ProspectListPage(),
    HomeMenu.customer => const CustomerListPage(),
    HomeMenu.search =>  SearchPage(),
    HomeMenu.dashBoard => const DashBoardPage(),
  };
}
