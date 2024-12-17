import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Community {
  final String id;
  final String name;
  final List<String> categories;
  String coordinates;
  String bio;
  String backgroundImagePath;
  String profileImagePath;
  String type; //public or private
  List<String> threadIds;
  List<String> memberIds;
  String adminId;
  Map<String, String>
      requestStatus; // userId: status (pending, approved, rejected)
  Timestamp createdAt;

  Community(
      {required this.id,
      required this.name,
      required this.categories,
      required this.bio,
      required this.backgroundImagePath,
      required this.profileImagePath,
      required this.type,
      required this.threadIds,
      required this.memberIds,
      required this.adminId,
      required this.requestStatus,
      required this.createdAt,
      required this.coordinates});

  factory Community.fromJson(Map<String, dynamic> json) {
    var coords = json['coordinates']?.split(',') ?? ['0', '0'];
    LatLng coordinates =
        LatLng(double.parse(coords[0]), double.parse(coords[1]));

    List<String> threadIds = [];
    if (json['threadIds'] != null) {
      var threads = json['threadIds'] as List;
      threadIds = threads.map((thread) => thread.toString()).toList();
    }

    List<String> memberIds = [];
    if (json['memberIds'] != null) {
      var members = json['memberIds'] as List;
      memberIds = members.map((member) => member.toString()).toList();
    }

    List<String> categories = [];
    if (json['categories'] != null) {
      var cats = json['categories'] as List;
      categories = cats.map((cat) => cat.toString()).toList();
    }

    return Community(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categories: categories,
      bio: json['bio'] ?? '',
      backgroundImagePath: json['backgroundImagePath'] ?? '',
      profileImagePath: json['profileImagePath'] ?? '',
      type: json['type'] ?? '',
      threadIds: threadIds,
      memberIds: memberIds,
      adminId: json['adminId'] ?? '',
      coordinates: json['coordinates'] ?? '45.478200,9.228430', // default coordinates in milan
      requestStatus: json['requestStatus'] != null
          ? Map<String, String>.from(json['requestStatus'])
          : {},
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categories': categories,
      'bio': bio,
      'backgroundImagePath': backgroundImagePath,
      'profileImagePath': profileImagePath,
      'type': type,
      'threadIds': threadIds,
      'memberIds': memberIds,
      'adminId': adminId,
      'requestStatus': requestStatus,
      'createdAt': createdAt,
      'coordinates': coordinates
    };
  }

  String generateRandomId({int length = 8}) {
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    String randomId = '';

    for (int i = 0; i < length; i++) {
      randomId += characters[random.nextInt(characters.length)];
    }
    return randomId;
  }
}
