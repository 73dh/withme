import 'package:withme/core/ui/const/duration.dart';

import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';

class SmallFab extends StatefulWidget {
  final bool fabVisibleLocal;
  final bool fabExpanded;
  final void Function(void Function())? overlaySetStateFold;
  final void Function(void Function())? overlaySetState;

  const SmallFab({
    super.key,
    required this.fabExpanded,
    this.overlaySetState,
    this.overlaySetStateFold, required this.fabVisibleLocal,
  });

  @override
  State<SmallFab> createState() => _SmallFabState();
}

class _SmallFabState extends State<SmallFab> with SingleTickerProviderStateMixin
{

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sizeAnimation;


  @override
  void initState() {
    super.initState();
  _controller=AnimationController(duration: AppDurations.duration300, vsync: this);
  _fadeAnimation=CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  _sizeAnimation=Tween<double>(begin: 0.0,end:1.0).animate(_fadeAnimation);
  }

  @override
  void didUpdateWidget(covariant SmallFab oldWidget) {
    super.didUpdateWidget(oldWidget);
  if(!widget.fabExpanded){
    _controller.forward();
  }else{
    _controller.reverse();
  }


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildExpandedColumn(){
    return SizeTransition(sizeFactor: _sizeAnimation,axis: Axis.vertical,child: FadeTransition(opacity: _fadeAnimation,child: Column(mainAxisSize: MainAxisSize.min,children: [
      Text('a'),
      Text('b'),
      Text('c'),
    ],),),);
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.fabVisibleLocal ? 1.0 : 0.0,
      duration: AppDurations.duration300,
      child:
          AnimatedContainer(
                key:  ValueKey(widget.fabExpanded),
                duration: AppDurations.duration300,
                width: widget.fabExpanded?40:80,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:widget.fabExpanded? ColorStyles.fabOpenColor:ColorStyles.fabColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FloatingActionButton.small(
                  heroTag: 'fabSecondary',
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () {
                    if(widget.fabExpanded){

                    widget.overlaySetStateFold?.call(() {
                    });}else{
    widget.overlaySetState?.call((){});
    }},child: widget.fabExpanded?Icon(Icons.sort_outlined):_buildExpandedColumn(),
                ),
              )
              // : AnimatedContainer(
              //   key: const ValueKey('collapseText'),
              //   duration: AppDurations.duration300,
              //   width: 80,
              //   // height: 40,
              //   decoration: BoxDecoration(
              //     color: Colors.blue,
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: FloatingActionButton.small(
              //     heroTag: 'fabSecondary',
              //     backgroundColor: Colors.transparent,
              //     elevation: 0,
              //     onPressed: () {
              //       widget.overlaySetState?.call(() {
              //         // 상태 전환
              //       });
              //     },
              //     child:  Container(child: Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Column(
              //         children: [
              //           Text('a'),
              //           Text('b'),
              //           Text('c'),
              //         ],
              //       ),
              //     ),),
              //   ),
              // ),
    );
  }
}
