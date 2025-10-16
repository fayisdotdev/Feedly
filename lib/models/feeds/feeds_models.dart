/// Consolidated feed models to use as a single import when convenient.
/// This file intentionally avoids redefining class names that already exist
/// elsewhere to prevent import conflicts. Use these models going forward or
/// keep using the existing per-file models. This is additive only.

class CategoryModelUnified {
  final String id;
  final String name;
  final String? image;

  CategoryModelUnified({required this.id, required this.name, this.image});

  factory CategoryModelUnified.fromJson(Map<String, dynamic> json) {
    return CategoryModelUnified(
      id: json['id'].toString(),
      name: json['title'] ?? json['name'] ?? '',
      image: json['image'],
    );
  }

  static List<CategoryModelUnified> listFromJson(List<dynamic> list) =>
      list.map((e) => CategoryModelUnified.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'image': image};
}

class FeedModelUnified {
  final String id;
  final String thumbnailUrl;
  final String videoUrl;
  final String description;
  final String userName;
  final String userAvatar;

  FeedModelUnified({
    required this.id,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.description,
    required this.userName,
    required this.userAvatar,
  });

  factory FeedModelUnified.fromJson(Map<String, dynamic> json) {
    return FeedModelUnified(
      id: json['id'].toString(),
      thumbnailUrl: json['image'] ?? '',
      videoUrl: json['video'] ?? '',
      description: json['description'] ?? '',
      userName: (json['user'] != null)
          ? (json['user']['name'] ?? 'Unknown')
          : 'Unknown',
      userAvatar: (json['user'] != null && json['user']['image'] != null)
          ? json['user']['image']
          : 'assets/images/avatar_placeholder.png',
    );
  }

  static List<FeedModelUnified> listFromJson(List<dynamic> list) =>
      list.map((e) => FeedModelUnified.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'thumbnailUrl': thumbnailUrl,
    'videoUrl': videoUrl,
    'description': description,
    'userName': userName,
    'userAvatar': userAvatar,
  };
}

class FeedUploadModelUnified {
  String desc;
  List<String> categoryIds;
  String? videoPath;
  String? imagePath;

  FeedUploadModelUnified({
    required this.desc,
    required this.categoryIds,
    this.videoPath,
    this.imagePath,
  });

  Map<String, dynamic> toFormData() {
    return {'desc': desc, 'category': categoryIds};
  }
}

class UserFeedModelUnified {
  final int id;
  final String description;
  final String? video;
  final String? image;
  final String createdAt;

  UserFeedModelUnified({
    required this.id,
    required this.description,
    this.video,
    this.image,
    required this.createdAt,
  });

  factory UserFeedModelUnified.fromJson(Map<String, dynamic> json) {
    return UserFeedModelUnified(
      id: json['id'],
      description: json['description'] ?? '',
      video: json['video'],
      image: json['image'],
      createdAt: json['created_at'] ?? '',
    );
  }

  static List<UserFeedModelUnified> listFromJson(List<dynamic> list) {
    return list.map((e) => UserFeedModelUnified.fromJson(e)).toList();
  }
}
