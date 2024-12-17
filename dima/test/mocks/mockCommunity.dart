import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/model/community.dart';

Community community1 = Community(
      id: '1',
      name: 'Test Community',
      categories: ['Sport'],
      bio: 'Community bio',
      backgroundImagePath: '',
      profileImagePath: '',
      type: 'public',
      threadIds: ['1'],
      memberIds: ['1'],
      adminId: '1',
      requestStatus: {'2': 'pending'},
      createdAt: Timestamp.now(),
      coordinates: "45.464664,9.188540",
);

Community community2 = Community(
      id: '2',
      name: 'Test Community',
      categories: ['Sport'],
      bio: 'Community bio',
      backgroundImagePath: '',
      profileImagePath: '',
      type: 'public',
      threadIds: [],
      memberIds: ['2','1'],
      adminId: '2',
      requestStatus: {},
      createdAt: Timestamp.now(),
      coordinates: "45.464664,9.188540",
);