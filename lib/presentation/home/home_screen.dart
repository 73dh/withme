import 'package:withme/analytics/ayalytics_page_view_observer.dart';

import '../../core/const/duration.dart';
import '../../core/const/size.dart';
import '../../core/domain/enum/home_menu.dart';
import '../../core/presentation/core_presentation_import.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AnalyticsPageViewObserver {
  int _currentIndex = 0;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final menu = HomeMenu.values[_currentIndex];
    logTabChange(menu.toString(), 'HomeScreen'); // 첫 화면도 기록
  }

  void _onPageChanged(int index) {
    final newIndex = index % HomeMenu.values.length;
    if (newIndex == _currentIndex) return;

    setState(() => _currentIndex = newIndex);

    final menu = HomeMenu.values[_currentIndex];

    // ✅ Firebase Analytics 조회수 기록
    logTabChange(menu.name, 'HomeScreen');
  }

  void _onItemTapped(int index) {
    if(index==_currentIndex) return;
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
                      color:
                          menu.index == _currentIndex
                              ? (Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black87
                                  : Colors.white)
                              : (Theme.of(context).brightness ==
                                      Brightness.light
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
