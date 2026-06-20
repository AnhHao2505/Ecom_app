import 'package:e_mart/consts/consts.dart';

class HomeButton extends StatelessWidget {
  final double width;
  final double height;
  final String icon;
  final String title;
  final VoidCallback? onPress;

  const HomeButton({
    super.key,
    required this.width,
    required this.height,
    required this.icon,
    required this.title,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 26),
            10.heightBox,
            Text(
              title,
              style: TextStyle(
                fontFamily: semibold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
