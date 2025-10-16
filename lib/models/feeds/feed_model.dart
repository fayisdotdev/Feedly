class CategoryModel {
  final String id;
  final String name;
  final String? image;

  CategoryModel({
    required this.id,
    required this.name,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      name: json['title'] ?? '',
      image: json['image'],
    );
  }

  static List<CategoryModel> listFromJson(List<dynamic> list) =>
      list.map((e) => CategoryModel.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
      };
}

class FeedModel {
  final String id;
  final String thumbnailUrl;
  final String videoUrl;
  final String description;
  final String userName;
  final String userAvatar;

  FeedModel({
    required this.id,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.description,
    required this.userName,
    required this.userAvatar,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      id: json['id'].toString(),
      thumbnailUrl: json['image'] ?? '', // fallback handled in UI
      videoUrl: json['video'] ?? '',
      description: json['description'] ?? '',
      userName: (json['user'] != null) ? (json['user']['name'] ?? 'Unknown') : 'Unknown',
      userAvatar: (json['user'] != null && json['user']['image'] != null)
          ? json['user']['image']
          : 'assets/images/avatar_placeholder.png', // local asset fallback
    );
  }

  static List<FeedModel> listFromJson(List<dynamic> list) =>
      list.map((e) => FeedModel.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'thumbnailUrl': thumbnailUrl,
        'videoUrl': videoUrl,
        'description': description,
        'userName': userName,
        'userAvatar': userAvatar,
      };
}
