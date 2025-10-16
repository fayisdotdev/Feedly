class FeedUploadModel {
  String desc;
  List<String> categoryIds;
  String? videoPath;
  String? imagePath;

  FeedUploadModel({
    required this.desc,
    required this.categoryIds,
    this.videoPath,
    this.imagePath,
  });

  Map<String, dynamic> toFormData() {
    return {
      'desc': desc,
      'category': categoryIds,
    };
  }
}


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
      name: json['name'], 
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
      };

  static List<CategoryModel> listFromJson(List<dynamic> list) {
    return list.map((e) => CategoryModel.fromJson(e)).toList();
  }
}
