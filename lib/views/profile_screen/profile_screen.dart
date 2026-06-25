import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/controllers/auth_controller.dart';
import 'package:e_mart/views/auth_screen/login_screen.dart';
import 'package:e_mart/views/profile_screen/components/details_card.dart';
import 'package:e_mart/views/profile_screen/edit_profile_screen.dart';
import 'package:e_mart/widget_common/bg_widget.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // edit profile button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Align(
                      alignment: Alignment.topRight,
                      child: const Icon(Icons.edit, color: whiteColor),
                    ).onTap(() {
                      Get.to(() => const EditProfileScreen());
                    }),
              ),

              // users' detail section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    // profile picture
                    Image.asset(
                      imgProfile2,
                      width: 100,
                      fit: BoxFit.cover,
                    ).box.roundedFull.clip(Clip.antiAlias).make(),
                    // user details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          "Dummy User".text.fontFamily(semibold).white.make(),
                          5.heightBox,
                          "customer&example.com".text.white.make(),
                        ],
                      ),
                    ),
                    // logout button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: whiteColor),
                      ),
                      onPressed: () async {
                        await Get.put(AuthController()).signoutMethod(context);
                        Get.offAll(() => const LoginScreen());
                      },
                      child: logout.text.fontFamily(semibold).white.make(),
                    ),
                  ],
                ),
              ),

              20.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  detailsCard(
                    count: "00",
                    title: "in your cart",
                    width: context.screenWidth / 3.6,
                  ),
                  detailsCard(
                    count: "32",
                    title: "in your wishlist",
                    width: context.screenWidth / 3.6,
                  ),
                  detailsCard(
                    count: "675",
                    title: "your order",
                    width: context.screenWidth / 3.6,
                  ),
                ],
              ),

              // buttons section
              ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Image.asset(
                            profileButtonImages[index],
                            width: 22,
                          ),
                          title: profileButtonsList[index].text.make(),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(color: lightGrey);
                    },
                    itemCount: profileButtonsList.length,
                  ).box.white.rounded
                  .padding(const EdgeInsets.symmetric(horizontal: 16))
                  .margin(const EdgeInsets.all(12))
                  .shadowSm
                  .make()
                  .box
                  .color(redColor)
                  .make(),
            ],
          ),
        ),
      ),
    );
  }
}
