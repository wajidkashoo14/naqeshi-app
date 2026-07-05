class UserModel {
  final String id;
  final String? name;
  final String email;
  final String? image;
  final String? phone;
  final String role;

  const UserModel({
    required this.id,
    this.name,
    required this.email,
    this.image,
    this.phone,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String?,
        email: json['email'] as String,
        image: json['image'] as String?,
        phone: json['phone'] as String?,
        role: json['role'] as String? ?? 'USER',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'image': image,
        'phone': phone,
        'role': role,
      };

  UserModel copyWith({String? name, String? image, String? phone}) => UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        image: image ?? this.image,
        phone: phone ?? this.phone,
        role: role,
      );
}
