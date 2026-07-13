import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/controllers/auth_controller.dart';
import 'package:e_mart/utils/auth_navigation.dart';
import 'package:e_mart/views/auth_screen/signup_screen.dart';
import 'package:e_mart/views/auth_screen/forget_pass_screen.dart';
import 'package:e_mart/widget_common/applogo_widget.dart';
import 'package:e_mart/widget_common/bg_widget.dart';
import 'package:e_mart/widget_common/custom_textfield.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  (context.screenHeight * 0.1).heightBox,
                  appLogoWidget(),
                  10.heightBox,
                  "Log in to $appname".text
                      .color(redColor)
                      .fontFamily(bold)
                      .size(18)
                      .make(),
                  15.heightBox,

                  Obx(
                    () =>
                        Column(
                              children: [
                                customTextField(
                                  title: email,
                                  hint: emailHint,
                                  controller: controller.emailController,
                                ),
                                customTextField(
                                  title: password,
                                  hint: passwordHint,
                                  isPass: true,
                                  controller: controller.passwordController,
                                ),
                                // forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Get.to(() => const ForgotPassScreen());
                                    },
                                    child: forgetPass.text
                                        .color(Vx.blue500)
                                        .make(),
                                  ),
                                ),
                                5.heightBox,
                                // login button
                                controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          redColor,
                                        ),
                                      )
                                    : ourButton(
                                            color: redColor,
                                            title: login,
                                            textColor: whiteColor,
                                            onPress: () async {
                                              controller.isLoading(true);

                                              final credential =
                                                  await controller.loginMethod(
                                                    context,
                                                  );
                                              if (credential?.user != null &&
                                                  mounted) {
                                                VxToast.show(
                                                  context,
                                                  msg: loggedIn,
                                                );
                                                await openLandingForUser(
                                                  credential!.user!,
                                                );
                                              } else {
                                                controller.isLoading(false);
                                              }
                                            },
                                          ).box
                                          .width(context.screenWidth - 50)
                                          .make(),
                                5.heightBox,
                                createNewAccount.text.color(fontGrey).make(),
                                // signup button
                                5.heightBox,
                                ourButton(
                                  color: lightGolden,
                                  title: signup,
                                  textColor: redColor,
                                  onPress: () {
                                    Get.to(() => const SignupScreen());
                                  },
                                ).box.width(context.screenWidth - 50).make(),
                                10.heightBox,
                                // alternative login options
                                loginWith.text.color(fontGrey).make(),
                                5.heightBox,
                                CircleAvatar(
                                  backgroundColor: lightGrey,
                                  radius: 25,
                                  child: Image.asset(googleAuthIcon, width: 30),
                                ).onTap(() async {
                                  final credential = await controller
                                      .loginWithGoogle();
                                  if (credential?.user != null && mounted) {
                                    await openLandingForUser(credential!.user!);
                                  }
                                }),
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
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 14),
                  child: Tooltip(
                    message: 'Create seller account',
                    child: IconButton(
                      onPressed: () =>
                          Get.to(() => const SignupScreen(isSeller: true)),
                      style: IconButton.styleFrom(
                        backgroundColor: whiteColor.withOpacity(0.18),
                        foregroundColor: whiteColor,
                      ),
                      icon: const Icon(
                        Icons.storefront_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
