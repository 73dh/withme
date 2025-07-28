import '../../../../core/presentation/core_presentation_import.dart';

class PolicyListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int count;

  const PolicyListAppBar({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('전체 계약 $count건'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
