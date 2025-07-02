import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/const/size.dart';
import 'package:withme/core/ui/icon/const.dart';
import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';

import '../../core/di/di_setup_import.dart';
import '../../core/di/setup.dart';
import '../../core/domain/enum/home_menu.dart';
import '../../core/presentation/core_presentation_import.dart';
import '../../core/router/router_import.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _pageController = PageController();

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index % 4;

    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: AppDurations.duration100,
      curve: Curves.easeIn,
    );
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        items:
            HomeMenu.values.map((menu) {
              return BottomNavigationBarItem(
                icon: Image.asset(
                  menu.iconPath,
                  width: AppSizes.bottomNavIconSize,
                  height: AppSizes.bottomNavIconSize,
                  color:
                      menu.index == _currentIndex ? Colors.black87 : Colors.grey,
                ),
                label: '',
              );
            }).toList(),
      ),
    );
  }
}
