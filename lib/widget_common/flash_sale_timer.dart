import 'dart:async';
import 'package:e_mart/consts/consts.dart';

class FlashSaleTimer extends StatefulWidget {
  final Duration initialDuration;

  const FlashSaleTimer({super.key, required this.initialDuration});

  @override
  State<FlashSaleTimer> createState() => _FlashSaleTimerState();
}

class _FlashSaleTimerState extends State<FlashSaleTimer> {
  late Duration duration;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    duration = widget.initialDuration;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (duration.inSeconds > 0) {
        setState(() => duration = duration - const Duration(seconds: 1));
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    Widget timeBox(String time) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: redColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: redColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          time,
          style: const TextStyle(
            color: whiteColor,
            fontFamily: bold,
            fontSize: 14,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        timeBox(hours),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(':', style: TextStyle(color: redColor, fontFamily: bold, fontSize: 16)),
        ),
        timeBox(minutes),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(':', style: TextStyle(color: redColor, fontFamily: bold, fontSize: 16)),
        ),
        timeBox(seconds),
      ],
    );
  }
}
