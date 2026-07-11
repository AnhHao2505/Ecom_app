import 'package:e_mart/consts/consts.dart';

Widget ourButton({
  required VoidCallback? onPress,
  Color? color = primaryColor,
  Color? textColor = whiteColor,
  required String title,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    onPressed: onPress,
    child: title.text.color(textColor).fontFamily(bold).make(),
  );
}
