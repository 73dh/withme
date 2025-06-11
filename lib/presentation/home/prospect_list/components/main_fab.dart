import 'package:go_router/go_router.dart';

import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/router/router_path.dart';
import '../../../../core/ui/core_ui_import.dart';

class MainFab extends StatelessWidget {
  final bool fabVisibleLocal;
  final VoidCallback? onPressed;

  const MainFab({
    super.key,
    required this.fabVisibleLocal,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: fabVisibleLocal ? 1.0 : 0.0,
      duration: AppDurations.duration500,
      child: FloatingActionButton(
        heroTag: 'fabMain',
        onPressed: onPressed,
        child: SizedBox(
          width: 24,
          height: 24,
          child: Image.asset(IconsPath.personAdd),
        ),
      ),
    );
  }
}