import 'package:calling_app/controllers/home_controller.dart';
import 'package:calling_app/views/app/friend_request/friend_request_page.dart';
import 'package:calling_app/views/app/home/friends.dart';
import 'package:calling_app/views/app/home/make_friends.dart';
import 'package:calling_app/views/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final HomeController homeController = Get.put(HomeController());

  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Welcome"),
          actions: [
            Obx(
              () => IconButton(
                  onPressed: () {
                    Get.to(() => const FriendRequestScree());
                  },
                  icon: Badge(
                      isLabelVisible: homeController
                              .userData?.value?.friendRequests?.isNotEmpty ??
                          true,
                      label: Text(homeController
                              .userData?.value?.friendRequests?.length
                              .toString() ??
                          ""),
                      child: const Icon(Icons.supervised_user_circle_sharp))),
            ),
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Get.offAll(() => const LoginScreen());
                  Get.delete<HomeController>();
                },
                icon: const Icon(Icons.logout_rounded))
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Container(
                alignment: Alignment.center,
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "${homeController.userData?.value?.username} welcome to app",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            DefaultTabController(
              length: 2,
              child: TabBar(
                controller: tabController,
                indicatorColor: Colors.cyan,
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: Colors.grey,
                dividerColor: Colors.orange,
                overlayColor:
                    const MaterialStatePropertyAll(Colors.transparent),
                labelPadding: const EdgeInsets.only(bottom: 10),
                labelStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: Colors.cyan),
                tabs: const [
                  Tab(text: "Make Friends"),
                  Tab(text: "Friends"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                viewportFraction: 1,
                children: const [MakeFriends(), Friends()],
              ),
            ),
          ],
        ));
  }
}
