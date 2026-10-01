class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String gender;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.gender,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final userData = json['user'] ?? json;
    return UserModel(
      id: userData['_id'] ?? userData['id'] ?? '',
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      mobile: userData['mobile'] ?? '',
      gender: userData['gender'] ?? userData['gender'] ?? 'male',
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'gender': gender,
      'token': token,
    };
  }
}
