import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/profile_controller.dart';
import 'package:e_mart/widget_common/bg_widget.dart';
import 'package:e_mart/widget_common/custom_textfield.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return bgWidget(
      child: Scaffold(
        appBar: AppBar(),
        body:
            Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      imgProfile2,
                      width: 100,
                      fit: BoxFit.cover,
                    ).box.roundedFull.clip(Clip.antiAlias).make(),
                    10.heightBox,
                    ourButton(onPress: () {
                      controller.changeImage(context);
                    }, title: "Change"),
                    const Divider(),
                    20.heightBox,
                    customTextField(title: name, hint: nameHint),
                    customTextField(
                      title: password,
                      hint: password,
                      isPass: true,
                    ),
                    20.heightBox,
                    SizedBox(
                      width: context.screenWidth - 60,
                      child: ourButton(onPress: () {}, title: "Save"),
                    ),
                  ],
                ).box.white.shadowSm
                .padding(const EdgeInsets.all(16))
                .margin(const EdgeInsets.only(top: 50, left: 12, right: 12))
                .rounded
                .make(),
                
      ),
    );
  }
}
