import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/enum/home_menu.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/presentation/home/customer/customer_page.dart';
import 'package:withme/presentation/home/dash_board/dash_board_page.dart';
import 'package:withme/presentation/home/pool/pool_page.dart';
import 'package:withme/presentation/home/search/search_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final _pageController = PageController();

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return HomeMenu.values.firstWhere((e) => e.index == index).toWidget;
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onPageChanged,
        showSelectedLabels: false,
        items:
            HomeMenu.values.map((menu) {
              return BottomNavigationBarItem(
                label: menu.name,
                icon: Image.asset(menu.iconPath, color: Colors.grey),
                activeIcon: Image.asset(menu.iconPath, color: Colors.black87),
              );
            }).toList(),
      ),
    );
  }
}
