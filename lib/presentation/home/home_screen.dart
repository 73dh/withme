import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/icon/const.dart';

import '../../core/domain/enum/home_menu.dart';

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
      currentIndex = index % 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        padEnds: true,
        onPageChanged: _onPageChanged,
        itemCount: HomeMenu.values.length,
        itemBuilder: (context, index) {
          final pageIndex = index % 4;
          return HomeMenu.values
              .firstWhere((e) => e.index == pageIndex)
              .toWidget;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePath.registration),
        child: SizedBox(
          width: 24,
          height: 24,
          child: Image.asset(IconsPath.personAdd),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      bottomNavigationBar: BottomAppBar(
        notchMargin: 10,
        height: 65,
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ...HomeMenu.values.map((menu) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      menu.index,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeIn,
                    );
                    // _onPageChanged(menu.index);
                  },
                  child: Image.asset(
                    menu.iconPath,
                    color:
                        menu.index == currentIndex
                            ? Colors.black87
                            : Colors.grey,
                  ),
                );
              }),
              const SizedBox(width: 30),
            ],
          ),
        ),
      ),
    );
  }
}
