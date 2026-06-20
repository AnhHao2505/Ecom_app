import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/profile_controller.dart';
import 'package:e_mart/widget_common/custom_textfield.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
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
                color: isDark ? Colors.transparent : Colors.black.withOpacity(0.03),
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
              customTextField(title: name, hint: nameHint),
              customTextField(
                title: password,
                hint: password,
                isPass: true,
              ),
              30.heightBox,
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ourButton(
                  color: primaryColor,
                  onPress: () {},
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
