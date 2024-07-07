import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? username;
  String email;
  String? id;
  String? profile;
  List<String>? friends;
  List<String>? friendRequests;
  String? calling;
  String? callingWith;

  UserModel({
    this.username,
    required this.email,
    this.id,
    this.profile,
    this.friends,
    this.friendRequests,
    this.calling,
    this.callingWith,
  });

  UserModel copyWith({
    String? username,
    String? email,
    String? id,
    String? profile,
    List<String>? friends,
    List<String>? friendRequests,
    String? calling,
    String? callingWith,
  }) =>
      UserModel(
        username: username ?? this.username,
        email: email ?? this.email,
        id: id ?? this.id,
        profile: profile ?? this.profile,
        friends: friends ?? this.friends,
        friendRequests: friendRequests ?? this.friendRequests,
        calling: calling ?? this.calling,
        callingWith: callingWith ?? this.callingWith,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        username: json["username"] ?? '',
        email: json["email"],
        id: json["id"],
        profile: json["profile"] ?? '',
        friends: List<String>.from(json["friends"] ?? []),
        friendRequests: List<String>.from(json["friendRequests"] ?? []),
        calling: json["calling"],
        callingWith: json["callingWith"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "profile": profile,
        "id": id,
        "friends": friends,
        "friendRequests": friendRequests,
        "calling": calling,
        "callingWith": callingWith,
      };
}
