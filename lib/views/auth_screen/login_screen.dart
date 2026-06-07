import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/controllers/auth_controller.dart';
import 'package:e_mart/views/auth_screen/signup_screen.dart';
import 'package:e_mart/views/home_screen/home.dart';
import 'package:e_mart/widget_common/applogo_widget.dart';
import 'package:e_mart/widget_common/bg_widget.dart';
import 'package:e_mart/widget_common/custom_textfield.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              (context.screenHeight * 0.1).heightBox,
              appLogoWidget(),
              10.heightBox,
              "Log in to $appname".text.fontFamily(bold).white.size(18).make(),
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
                                onPressed: () {},
                                child: forgetPass.text.color(Vx.blue500).make(),
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

                                      await controller
                                          .loginMethod(context)
                                          .then((value) {
                                            if (value != null) {
                                              VxToast.show(
                                                context,
                                                msg: loggedIn,
                                              );
                                              Get.offAll(() => const Home());
                                            } else {
                                              controller.isLoading(false);
                                            }
                                          });
                                    },
                                  ).box.width(context.screenWidth - 50).make(),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    backgroundColor: lightGrey,
                                    radius: 25,
                                    child: Image.asset(
                                      socialIconList[index],
                                      width: 30,
                                    ),
                                  ),
                                ),
                              ),
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
