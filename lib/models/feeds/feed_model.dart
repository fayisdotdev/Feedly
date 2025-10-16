
class CategoryModel {
  final String id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
    );
  }

  static List<CategoryModel> listFromJson(List<dynamic> list) =>
      list.map((e) => CategoryModel.fromJson(e)).toList();
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
      thumbnailUrl: json['image'] ?? '',
      videoUrl: json['video'] ?? '',
      description: json['description'] ?? '',
      userName: json['user']['name'] ?? 'Unknown',
      userAvatar: json['user']['image'] ??
          'https://via.placeholder.com/150', // fallback avatar
    );
  }

  static List<FeedModel> listFromJson(List<dynamic> list) =>
      list.map((e) => FeedModel.fromJson(e)).toList();
}

