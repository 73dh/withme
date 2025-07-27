import 'package:lottie/lottie.dart';

import '../core_presentation_import.dart';

class RunningAnimationIcon extends StatelessWidget {
  final double size;

  const RunningAnimationIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/lottie/running_man.json', // 다운로드한 json 파일 경로
        repeat: true,
        fit: BoxFit.contain,
      ),
    );
  }
}
