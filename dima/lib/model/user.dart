class User {
  //login
  final String id;
  final String name;
  final String email;
  //profile
  final String username;
  final String profileImagePath;
  final String bio;
  final bool initialized;
  //activities
  final List<String> communityIds;
  final List<String> threadIds;
  final Map<String, String> communityRequests; // communityId: status
  final List<String> selectedCategories;
  final List<String> selectedSources;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.username,
      required this.profileImagePath,
      required this.bio,
      required this.communityIds,
      required this.threadIds,
      required this.communityRequests,
      required this.initialized,
      required this.selectedCategories,
      required this.selectedSources});

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> communityIds = [];
    if (json['communityIds'] != null) {
      var communities = json['communityIds'] as List;
      communityIds =
          communities.map((community) => community.toString()).toList();
    }

    List<String> threadIds = [];
    if (json['threadIds'] != null) {
      var threads = json['threadIds'] as List;
      threadIds = threads.map((thread) => thread.toString()).toList();
    }

    List<String> selectedCategories = [];
    if (json['selectedCategories'] != null) {
      var categories = json['selectedCategories'] as List;
      selectedCategories =
          categories.map((thread) => thread.toString()).toList();
    }

    List<String> selectedSources = [];
    if (json['selectedSources'] != null) {
      var sources = json['selectedSources'] as List;
      selectedSources = sources.map((thread) => thread.toString()).toList();
    }

    return User(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        username: json['username'] ?? '',
        profileImagePath: json['profileImagePath'] ?? '',
        bio: json['bio'] ?? '',
        communityIds: communityIds,
        threadIds: threadIds,
        communityRequests: Map<String, String>.from(json['communityRequests']),
        initialized: json['initialized'] ?? true,
        selectedCategories: selectedCategories,
        selectedSources: selectedSources);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'profileImagePath': profileImagePath,
      'bio': bio,
      'communityIds': communityIds,
      'threadIds': threadIds,
      'communityRequests': communityRequests,
      'initialized': initialized,
      'selectedCategories': selectedCategories,
      'selectedSources': selectedSources
    };
  }
}
