import 'dart:async';

import '../presentation/core_presentation_import.dart';

/// 🛠️ 유저 입력 없을 때 일정시간 지나면 종료/백그라운드 처리하는 Wrapper
class AutoExitWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback onTimeout;

  const AutoExitWrapper({
    super.key,
    required this.child,
    required this.duration,
    required this.onTimeout,
  });

  @override
  State<AutoExitWrapper> createState() => _AutoExitWrapperState();
}

class _AutoExitWrapperState extends State<AutoExitWrapper>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _isInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 이동
      _isInBackground = true;
      _startTimer();
    } else if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아옴
      _isInBackground = false;
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, () {
      if (_isInBackground) {
        widget.onTimeout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _isInBackground ? _startTimer : null,
      onPanDown: _isInBackground ? (_) => _startTimer() : null,
      child: widget.child,
    );
  }
}

