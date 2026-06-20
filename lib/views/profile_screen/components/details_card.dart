import 'package:e_mart/consts/consts.dart';

Widget detailsCard({required BuildContext context, required double width, required String count, required String title}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    width: width,
    height: 80,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? darkDivider : lightDivider.withOpacity(0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.transparent : Colors.black.withOpacity(0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: bold,
            fontSize: 16,
          ),
        ),
        4.heightBox,
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
