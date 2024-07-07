import 'package:cached_network_image/cached_network_image.dart';
import 'package:calling_app/controllers/home_controller.dart';
import 'package:calling_app/models/user_model.dart';
import 'package:calling_app/services/db_services.dart';
import 'package:calling_app/views/widgets/text_widget.dart';
import 'package:calling_app/views/widgets/wave_loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MakeFriends extends StatefulWidget {
  const MakeFriends({super.key});

  @override
  State<MakeFriends> createState() => _MakeFriendsState();
}

class _MakeFriendsState extends State<MakeFriends> {
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    homeController.onMakeFriendsPageInit();
  }

  @override
  void dispose() {
    super.dispose();
    homeController.onMakeFriendsPageDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: homeController.makeFriends.length,
        itemBuilder: (context, index) {
          UserModel user = homeController.makeFriends[index]
              .copyWith(id: homeController.makeFriends[index].id);
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Colors.cyan,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl:
                            "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D",
                        placeholder: (context, val) =>
                            const WaveLoadingWidget(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: CustomTextWidget(
                            text: user.username ?? "",
                            textOverflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              DBServices().sendFriendRequest(user.id ?? "");
                            },
                            child: Text(getButtonText(user.friendRequests)))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String getButtonText(List<String>? text) {
    String mail = FirebaseAuth.instance.currentUser?.email ?? "";

    if (text?.contains(mail) ?? false) {
      return "Requested";
    }
    return "Send Request";
  }
}
