import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/auth_controller.dart';
import 'package:e_mart/views/home_screen/home.dart';
import 'package:e_mart/widget_common/applogo_widget.dart';
import 'package:e_mart/widget_common/bg_widget.dart';
import 'package:e_mart/widget_common/custom_textfield.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool? isCheck = false;
  final controller = Get.put(AuthController());
  // text field controllers
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final retypePasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              (context.screenHeight * 0.1).heightBox,
              appLogoWidget(),
              10.heightBox,
              "Join the $appname".text.fontFamily(bold).white.size(18).make(),
              15.heightBox,

              Obx(
                () =>
                    Column(
                          children: [
                            // name
                            customTextField(
                              title: name,
                              hint: nameHint,
                              controller: nameController,
                            ),
                            // email
                            customTextField(
                              title: email,
                              hint: emailHint,
                              controller: emailController,
                            ),
                            // password
                            customTextField(
                              title: password,
                              hint: passwordHint,
                              controller: passwordController,
                              isPass: true,
                            ),
                            // retype password
                            customTextField(
                              title: retypePassword,
                              hint: passwordHint,
                              controller: retypePasswordController,
                              isPass: true,
                            ),
                            // forget pass
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: forgetPass.text.color(Vx.blue500).make(),
                              ),
                            ),
                            // check policy
                            Row(
                              children: [
                                Checkbox(
                                  checkColor: whiteColor,
                                  activeColor: redColor,
                                  value: isCheck,
                                  onChanged: (newValue) {
                                    setState(() {
                                      isCheck = newValue;
                                    });
                                  },
                                ),
                                10.widthBox,
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "I agree to the ",
                                          style: TextStyle(
                                            color: fontGrey,
                                            fontFamily: regular,
                                          ),
                                        ),
                                        TextSpan(
                                          text: termAndConditions,
                                          style: TextStyle(
                                            color: redColor,
                                            fontFamily: regular,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " & ",
                                          style: TextStyle(
                                            color: fontGrey,
                                            fontFamily: regular,
                                          ),
                                        ),
                                        TextSpan(
                                          text: privacyPolicy,
                                          style: TextStyle(
                                            color: redColor,
                                            fontFamily: regular,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            5.heightBox,
                            // signup button
                            controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      redColor,
                                    ),
                                  )
                                : ourButton(
                                    color: isCheck == true
                                        ? redColor
                                        : lightGrey,
                                    title: signup,
                                    textColor: whiteColor,
                                    onPress: () async {
                                      if (isCheck != false) {
                                        controller.isLoading(true);
                                        try {
                                          await controller
                                              .signupMethod(
                                                context: context,
                                                email: emailController.text,
                                                password:
                                                    passwordController.text,
                                              )
                                              .then((value) {
                                                return controller.storeUserData(
                                                  email: emailController.text,
                                                  password:
                                                      passwordController.text,
                                                  name: nameController.text,
                                                );
                                              })
                                              .then((value) {
                                                VxToast.show(
                                                  context,
                                                  msg: loggedIn,
                                                );
                                                Get.offAll(() => const Home());
                                              });
                                        } catch (e) {
                                          auth.signOut();
                                          VxToast.show(
                                            context,
                                            msg: e.toString(),
                                          );
                                          controller.isLoading(false);
                                        }
                                      }
                                    },
                                  ).box.width(context.screenWidth - 50).make(),
                            10.heightBox,
                            // return to log in
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: alreadyHaveAccount,
                                    style: TextStyle(
                                      color: fontGrey,
                                      fontFamily: bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: login,
                                    style: TextStyle(
                                      color: redColor,
                                      fontFamily: bold,
                                    ),
                                  ),
                                ],
                              ),
                            ).onTap(() {
                              Get.back();
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
      ),
    );
  }
}
