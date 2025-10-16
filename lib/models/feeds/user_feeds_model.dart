class UserFeedModel {
  final int id;
  final String description;
  final String? video;
  final String? image;
  final String createdAt;

  UserFeedModel({
    required this.id,
    required this.description,
    this.video,
    this.image,
    required this.createdAt,
  });

  factory UserFeedModel.fromJson(Map<String, dynamic> json) {
    return UserFeedModel(
      id: json['id'],
      description: json['description'] ?? '',
      video: json['video'],
      image: json['image'],
      createdAt: json['created_at'] ?? '',
    );
  }

  static List<UserFeedModel> listFromJson(List<dynamic> list) {
    return list.map((e) => UserFeedModel.fromJson(e)).toList();
  }
}
