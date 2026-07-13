import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/auth_controller.dart';
import 'package:e_mart/widget_common/applogo_widget.dart';
import 'package:e_mart/widget_common/bg_widget.dart';
import 'package:e_mart/widget_common/custom_textfield.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class ForgotPassScreen extends StatelessWidget {
  const ForgotPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              (context.screenHeight * 0.12).heightBox,
              appLogoWidget(),
              12.heightBox,
              "Forgot Password".text
                  .fontFamily(bold)
                  .color(redColor)
                  .size(20)
                  .make(),
              8.heightBox,
              "Enter your email to receive a password reset link.".text
                  .color(fontGrey)
                  .center
                  .make(),
              20.heightBox,
              Obx(
                () =>
                    Column(
                          children: [
                            customTextField(
                              title: email,
                              hint: emailHint,
                              controller: controller.emailController,
                            ),
                            10.heightBox,
                            controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      redColor,
                                    ),
                                  )
                                : Column(
                                    children: [
                                      ourButton(
                                            color: redColor,
                                            title: "Send Reset Link",
                                            textColor: whiteColor,
                                            onPress: () async {
                                              final emailText = controller
                                                  .emailController
                                                  .text
                                                  .trim();
                                              if (emailText.isEmpty) {
                                                VxToast.show(
                                                  context,
                                                  msg:
                                                      "Please enter your email",
                                                  position: VxToastPosition.top,
                                                );
                                                return;
                                              }

                                              controller.isLoading(true);
                                              final success = await controller
                                                  .resetPassword(
                                                    email: emailText,
                                                    context: context,
                                                  );
                                              controller.isLoading(false);
                                              if (success) {
                                                controller.emailController
                                                    .clear();
                                              }
                                            },
                                          ).box
                                          .width(context.screenWidth - 50)
                                          .make(),
                                      10.heightBox,
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: "Back to Login".text
                                            .color(redColor)
                                            .make(),
                                      ),
                                    ],
                                  ),
                          ],
                        ).box.white.rounded
                        .padding(const EdgeInsets.all(16))
                        .width(context.screenWidth - 70)
                        .shadowSm
                        .make(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
