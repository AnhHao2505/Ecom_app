import 'package:e_mart/consts/consts.dart';

Widget customTextField({
  required String title,
  String? hint,
  TextEditingController? controller,
  bool? isPass,
  FocusNode? focusNode,
  TextInputAction? textInputAction,
  ValueChanged<String>? onFieldSubmitted,
  TextInputType? keyboardType,
  bool autofocus = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      title.text.color(redColor).fontFamily(semibold).size(16).make(),
      5.heightBox,
      TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        keyboardType: keyboardType,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: semibold, color: fontGrey),
          isDense: true,
          fillColor: lightGrey,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: redColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        obscureText: isPass ?? false,
      ),
      5.heightBox,
    ],
  );
}
