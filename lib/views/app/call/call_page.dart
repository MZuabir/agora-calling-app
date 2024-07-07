import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:calling_app/models/user_model.dart';
import 'package:calling_app/services/db_services.dart';
import 'package:calling_app/utils/app_secrets.dart';
import 'package:calling_app/utils/custom_extentions.dart';
import 'package:calling_app/utils/logger.dart';
import 'package:calling_app/views/widgets/text_widget.dart';
import 'package:calling_app/views/widgets/wave_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key, required this.username});
  final String username;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  double xPos = 0;
  double yPos = 0;
  final List remoteUids = [];
  final List<String> _infoStrings = [];
  bool mutedAudio = false;
  bool mutedVideo = false;
  late RtcEngine _engine;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> userStream;
  List<UserModel> friends = [];
  @override
  void dispose() {
    // destroy sdk
    _engine.leaveChannel();
    _infoStrings.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    userStream = DBServices().getFriends().listen((event) {
      friends = event.docs
          .map((doc) => UserModel.fromJson(doc.data()).copyWith(id: doc.id))
          .toList();
      if (friends.isNotEmpty) {
        friends = friends
            .where((e) =>
                (e.friends
                        ?.contains(FirebaseAuth.instance.currentUser?.email) ??
                    false) &&
                (e.callingWith?.isEmpty ?? true))
            .toList();
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future<void> initialize() async {
    if (appId.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();

    await _engine.joinChannel(
        token: token,
        channelId: channel,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ));
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      logConfig: LogConfig(fileSizeInKB: 2048, level: LogLevel.logLevelWarn),
    ));
    await _engine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    VideoEncoderConfiguration videoConfig = const VideoEncoderConfiguration(
        mirrorMode: VideoMirrorModeType.videoMirrorModeAuto,
        frameRate: 10,
        bitrate: standardBitrate,
        dimensions: VideoDimensions(width: 640, height: 360),
        orientationMode: OrientationMode.orientationModeAdaptive,
        degradationPreference: DegradationPreference.maintainBalanced);
    if (remoteUids.isNotEmpty) {
      for (int i = 0; i <= remoteUids.length; i++) {
        _engine.setRemoteVideoStreamType(
            uid: remoteUids[i + 1], streamType: VideoStreamType.videoStreamLow);
      }
    }

    _engine.setVideoEncoderConfiguration(videoConfig);
    startProbeTest();
    await _engine.enableVideo();
  }

  void startProbeTest() {
    // Configure the probe test
    LastmileProbeConfig config = const LastmileProbeConfig(
      probeUplink: true,
      probeDownlink: true,
      expectedUplinkBitrate: 100000,
      expectedDownlinkBitrate: 100000,
    );
    _engine.startLastmileProbeTest(config);
   
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
         
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
         
          remoteUids.add(remoteUid);
          if (mounted) setState(() {});
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          remoteUids.remove(remoteUid);
          if (mounted) setState(() {});
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );
  }

  muteAudio() {
    if (mutedAudio) {
      mutedAudio = false;
      _engine.muteLocalAudioStream(false);
    } else {
      mutedAudio = true;
      _engine.muteLocalAudioStream(true);
    }
  }

  muteVideo() {
    if (mutedVideo) {
      mutedVideo = false;
      setState(() {});
      _engine.muteLocalVideoStream(false);
    } else {
      setState(() {});
      mutedVideo = true;
      _engine.muteLocalVideoStream(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger.info(remoteUids.length);
    return GestureDetector(
      onTap: () async {
        showBottomSheet();
        await Future.delayed(const Duration(seconds: 2), () {
          Get.back();
        });
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light),
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBody: true,
          body: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Positioned.fill(
                child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    primary: true,
                    padding: EdgeInsets.zero,
                    itemCount: remoteUids.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: 0.5,
                      
                    ),
                    itemBuilder: (context, index) {
                      return AgoraVideoView(
                          controller: VideoViewController(
                        useFlutterTexture: false,
                        rtcEngine: _engine,
                        canvas: VideoCanvas(uid: remoteUids[index]),
                        
                      ));
                    }),
              ),
              remoteUids.isNotEmpty
                  ? Positioned(
                      left: xPos.clamp(0, context.w - 150),
                      top: yPos.clamp(0, context.h - 200),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanUpdate: (val) {
                       
                          setState(() {
                            xPos =
                                (xPos + val.delta.dx).clamp(0, context.w - 150);
                            yPos =
                                (yPos + val.delta.dy).clamp(0, context.h - 200);
                          });
                        },
                        child: Container(
                          height: 200,
                          width: 150,
                          color:
                              mutedVideo ? Colors.cyan.withOpacity(0.7) : null,
                          child: mutedVideo
                              ? const Center(
                                  child: Icon(
                                  Icons.video_camera_front,
                                  color: Colors.white,
                                ))
                              : AgoraVideoView(
                                  controller: VideoViewController(
                                      rtcEngine: _engine,
                                      canvas: const VideoCanvas(uid: 0))),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> showBottomSheet() {
    return Get.bottomSheet(
        barrierColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        persistent: false,
        backgroundColor: Colors.cyan.withOpacity(0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    muteVideo();
                  },
                  color: Colors.white,
                  icon: const Icon(
                    Icons.video_call_rounded,
                  )),
              IconButton(
                  onPressed: () {
                    muteAudio();
                  },
                  icon: const Icon(
                    Icons.mic_outlined,
                    color: Colors.white,
                  )),
              IconButton(
                  onPressed: () {
                    Get.bottomSheet(
                        barrierColor: Colors.transparent,
                        ListView.builder(
                            itemCount: friends.length,
                            itemBuilder: (context, index) {
                              UserModel user = friends[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D",
                                            placeholder: (context, val) =>
                                                const WaveLoadingWidget(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: CustomTextWidget(
                                                text: user.username ?? "",
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                maxLines: 1,
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  if (user.callingWith
                                                          ?.isEmpty ??
                                                      true) {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(user.email)
                                                        .update({
                                                      "calling": FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          ?.email
                                                    });
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            ?.email)
                                                        .update({
                                                      "callingWith": token
                                                    });
                                                  } else if (user.calling
                                                          ?.isNotEmpty ??
                                                      true) {
                                                    context.showSnackBar(
                                                        "${user.username} is on another call");
                                                  }
                                                },
                                                child: Text((user.callingWith
                                                            ?.isEmpty ??
                                                        true)
                                                    ? "Call"
                                                    : "In Call"))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }));
                  },
                  icon: const Icon(
                    Icons.people_alt_sharp,
                    color: Colors.white,
                  )),
              IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    _engine.leaveChannel();
                    _infoStrings.clear();
                    Get.back();
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser?.email)
                        .update({"callingWith": null});
                  },
                  color: Colors.white,
                  icon: const Icon(
                    Icons.call_end_rounded,
                  ))
            ],
          ),
        ));
  }
}

