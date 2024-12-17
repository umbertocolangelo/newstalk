import 'package:dima/model/user.dart';

User user1 = User(
  id: '1',
  username: 'user1',
  profileImagePath: '',
  name: 'User One',
  email: '',
  bio: '',
  communityIds: ['1','2'],
  threadIds: [],
  communityRequests: {},
  initialized: true,
  selectedCategories: [],
  selectedSources: [],
);

User user2 = User(
  id: '2',
  username: 'user1',
  profileImagePath: '',
  name: 'User One',
  email: '',
  bio: '',
  communityIds: ['2'],
  threadIds: [],
  communityRequests: {'1': 'pending'},
  initialized: true,
  selectedCategories: [],
  selectedSources: [],
);