import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calling_app/controllers/home_controller.dart';
import 'package:calling_app/models/user_model.dart';
import 'package:calling_app/utils/app_secrets.dart';
import 'package:calling_app/utils/custom_extentions.dart';
import 'package:calling_app/views/app/call/call_page.dart';
import 'package:calling_app/views/widgets/text_widget.dart';
import 'package:calling_app/views/widgets/wave_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final HomeController homeController = Get.find<HomeController>();
  late UserModel? userData;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> userStream;
  bool streamSub = false;

  @override
  void initState() {
    super.initState();
    homeController.onFriendsPageInit();
  }

  @override
  void dispose() {
    super.dispose();
    homeController.onFriendPageDispose();
    if (streamSub) {
      userStream.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: homeController.friends.length,
        itemBuilder: (context, index) {
          UserModel user = homeController.friends[index]
              .copyWith(id: homeController.friends[index].id);
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
                            onPressed: () async {
                              if (user.callingWith?.isEmpty ?? true) {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(user.email)
                                    .update({
                                  "calling":
                                      FirebaseAuth.instance.currentUser?.email
                                });
                                userStreamFunc(user);
                              } else {
                                context.showSnackBar(
                                    "${user.username} is on another call");
                              }
                            
                            },
                            child: Text(((user.callingWith?.isEmpty ?? true))
                                ? "Call"
                                : "In Call"))
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

  userStreamFunc(UserModel user) {
    userStream = FirebaseFirestore.instance
        .collection("users")
        .doc(user.id)
        .snapshots()
        .listen((event) async {
      userData = UserModel.fromJson(event.data() ?? {});
      streamSub = true;
      if ((userData?.calling?.isNotEmpty ?? true) &&
          userData?.calling == 'declined') {
        context.showSnackBar("${userData?.username} declined the call");
      } else if ((userData?.calling?.isNotEmpty ?? true) &&
          hasEmail(userData?.calling ?? "")) {
        context.showSnackBar("Calling to ${userData?.username}...");
      } else if ((userData?.calling?.isNotEmpty ?? true) &&
          userData?.calling == 'accepted') {
        log("Current user${FirebaseAuth.instance.currentUser?.email}");
        log("other user${user.email}");

        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.email)
            .update({"callingWith": token});
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.email)
            .update({"calling": null});

        Get.to(() =>
            CallPage(username: FirebaseAuth.instance.currentUser?.email ?? ""));
      }
    });

    
  }

  bool hasEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
