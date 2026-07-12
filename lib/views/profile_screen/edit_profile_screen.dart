import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/profile_controller.dart';
import 'package:e_mart/widget_common/custom_textfield.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  late ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController());
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleSaveProfile() {
    FocusScope.of(context).unfocus();
    // Implementation for save profile goes here
    VxToast.show(context, msg: "Profile saved");
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? darkDivider : lightDivider.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 2),
                    image: const DecorationImage(
                      image: AssetImage(imgProfile2),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                10.heightBox,
                ourButton(
                  color: primaryColor,
                  onPress: () {
                    controller.changeImage(context);
                  },
                  title: "Change Picture",
                ),
                const Divider().paddingSymmetric(vertical: 20),
                customTextField(
                  title: name,
                  hint: nameHint,
                  focusNode: _nameFocus,
                  textInputAction: TextInputAction.next,
                ),
                customTextField(
                  title: password,
                  hint: password,
                  isPass: true,
                  focusNode: _passwordFocus,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSaveProfile(),
                ),
                30.heightBox,
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ourButton(
                    color: primaryColor,
                    onPress: _handleSaveProfile,
                    title: "Save",
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
