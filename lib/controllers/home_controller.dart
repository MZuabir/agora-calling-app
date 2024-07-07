import 'dart:async';

import 'package:calling_app/models/user_model.dart';
import 'package:calling_app/services/db_services.dart';
import 'package:calling_app/utils/app_secrets.dart';
import 'package:calling_app/utils/logger.dart';
import 'package:calling_app/views/app/call/call_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

class HomeController extends GetxController {
  RxList<UserModel> friends = <UserModel>[].obs;
  RxList<UserModel> makeFriends = <UserModel>[].obs;
  Rx<UserModel?>? userData = Rx(null);

  //friends page
  late Stream<QuerySnapshot<Map<String, dynamic>>> userStream;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      streamSubscription;
  //make friends page
  late Stream<QuerySnapshot> allUsers;
  late StreamSubscription<QuerySnapshot> allUsersStreamSubscription;

  onFriendsPageInit() {
    userStream = DBServices().getFriends();
    streamSubscription =
        userStream.listen((QuerySnapshot<Map<String, dynamic>> event) {
      friends.value = event.docs
          .map((doc) => UserModel.fromJson(doc.data()).copyWith(id: doc.id))
          .toList();
      if (friends.isNotEmpty) {
        friends.value = friends
            .where((e) => (e.friends
                    ?.contains(FirebaseAuth.instance.currentUser?.email) ??
                false))
            .toList();
      }
    });
  }

  onFriendPageDispose() {
    streamSubscription.cancel();
    friends.clear();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  fetchCurrentUser() async {
    try {
      DBServices().currentUserSnapshot().listen((event) async {
        userData?.value =
            UserModel.fromJson(event.data() as Map<String, dynamic>);
        if ((userData?.value?.calling?.isNotEmpty ?? false)&& hasEmail(userData?.value?.calling??"")) {
          Vibration.vibrate(repeat: 1);

          Get.bottomSheet(
            backgroundColor: Colors.cyan.withOpacity(0.7),
            barrierColor: Colors.transparent,
            enableDrag: false,
            isDismissible: false,
            persistent: false,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      "${userData?.value?.calling} is calling you",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.red),
                          child: const Text(
                            "Decline",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            Vibration.cancel();
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(userData?.value?.email)
                                .update({"calling": "declined"});
                            Get.back();
                          },
                        )),
                        const SizedBox(width: 20),
                        Expanded(
                            child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.green),
                          child: const Text(
                            "Accept",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            Get.back();
                            Vibration.cancel();
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(userData?.value?.email)
                                .update({"calling": "accepted"});
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(userData?.value?.email)
                                .update({"callingWith": token});

                            Get.to(() => CallPage(
                                username: userData?.value?.email ?? ''));
                          },
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }
      });
    } catch (error) {
      Logger.error("Error fetching current user data: $error");
    }
  }
 bool hasEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
  onMakeFriendsPageInit() {
   

    allUsers = DBServices().getAllUsers();
    allUsersStreamSubscription = allUsers.listen((QuerySnapshot event) {
      makeFriends.value = event.docs.map((doc) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id);
      }).toList();
      if (makeFriends.isNotEmpty) {
        makeFriends.removeWhere((e) {
          return e.friends
                  ?.contains(FirebaseAuth.instance.currentUser?.email) ??
              false;
        });
      }
    });
  }

  onMakeFriendsPageDispose() {
    allUsersStreamSubscription.cancel();
    makeFriends.clear();
  }
}
