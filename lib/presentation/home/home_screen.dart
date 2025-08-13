import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/const/size.dart';

import '../../core/domain/enum/home_menu.dart';
import '../../core/presentation/core_presentation_import.dart';

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

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: BottomNavigationBar(
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
                      color: menu.index == _currentIndex
                          ? (Theme.of(context).brightness == Brightness.light
                          ? Colors.black87
                          : Colors.white)
                          : (Theme.of(context).brightness == Brightness.light
                          ? Colors.black38
                          : Colors.white54),
                    ),
                    label: '',
                  );

                }).toList(),
          ),
        ),
      ),
    );
  }
}
