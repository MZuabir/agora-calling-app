import 'package:calling_app/models/user_model.dart';
import 'package:calling_app/services/db_services.dart';
import 'package:calling_app/utils/logger.dart';
import 'package:calling_app/views/widgets/text_widget.dart';
import 'package:calling_app/views/widgets/wave_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendRequestScree extends StatelessWidget {
  const FriendRequestScree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Friend Requests",
        ),
      ),
      body: StreamBuilder(
          stream: DBServices().currentUserSnapshot(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                var data = snapshot.data?.data();
                UserModel user =
                    UserModel.fromJson(data as Map<String, dynamic>);
                if (user.friendRequests?.isNotEmpty ?? true) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: user.friendRequests?.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.cyan,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: CustomTextWidget(
                                  text: user.friendRequests?[index],
                                  color: Colors.white,
                                  textOverflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(),
                                    onPressed: () async {
                                      Logger.info(user.email);
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(FirebaseAuth
                                              .instance.currentUser?.email)
                                          .update({
                                        "friends": FieldValue.arrayUnion(
                                            [user.friendRequests?[index]]),
                                      });
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(user.friendRequests?[index])
                                          .update({
                                        "friends": FieldValue.arrayUnion([
                                          FirebaseAuth
                                              .instance.currentUser?.email
                                        ]),
                                      });

                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(FirebaseAuth
                                              .instance.currentUser?.email)
                                          .update({
                                        "friendRequests":
                                            FieldValue.arrayRemove(
                                                [user.friendRequests?[index]]),
                                      });
                                    },
                                    child: const Text("Accept")),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: Text("No Friend Requests"),
                );
              }
            }
            return const WaveLoadingWidget();
          }),
    );
  }
}
