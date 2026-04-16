import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/capture_screen.dart';
import '../viewmodel/capture_viewmodel.dart';


class CaptureButton extends ConsumerWidget {
  const CaptureButton({super.key});

  double rs(BuildContext context, double v) {
    final w = MediaQuery.of(context).size.width;
    return v * (w / 375);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final vm = ref.read(captureProvider.notifier);
    // final isBusy = state.initializing;
    final isBusy = state.initializing || state.processing;

    final outerSize = rs(context, 70);
    final stopSize = rs(context, 25);
    final gap = rs(context, 6);
    final border = rs(context, 4);
    final font = rs(context, 12);

    Widget child;

    /// LOADING
    // if (isBusy) {
    //   child = SizedBox(
    //     width: outerSize,
    //     height: outerSize,
    //     child: CircularProgressIndicator(
    //       color: Colors.white,
    //       strokeWidth: rs(context, 3),
    //     ),
    //   );
    // }

    if (isBusy) {
      child = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: outerSize,
            height: outerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: border),
            ),
          ),
          SizedBox(
            width: outerSize * 0.55,
            height: outerSize * 0.55,
            child: CircularProgressIndicator(
              strokeWidth: rs(context, 3),
              color: Colors.white,
            ),
          ),
        ],
      );
    }


    /// RECORDING
    else if (state.recording) {
      child = Container(
        width: outerSize,
        height: outerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: stopSize,
              height: stopSize,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(rs(context, 6)),
              ),
            ),
            SizedBox(height: gap),
            Text(
              "${state.recordingDuration.inMinutes.toString().padLeft(2, '0')}:${(state.recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: font,
              ),
            ),
          ],
        ),
      );
    }

    /// IDLE
    else {
      child = Container(
        width: outerSize,
        height: outerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: border),
        ),
      );
    }

    return GestureDetector(
      // onTap: isBusy ? null : vm.onCapturePressed,
      onTap: isBusy ? null : () {
        final side = ref.read(captureScreenSideProvider); // ya direct parameter
        vm.onCapturePressed(side); // UI rotation pass kar diya
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
    );
  }
}
