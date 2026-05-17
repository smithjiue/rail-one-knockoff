import 'package:equatable/equatable.dart';

/// Cached user profile stored in Hive.
class LocalUserProfile extends Equatable {
  const LocalUserProfile({
    required this.id,
    required this.displayName,
    this.email,
    this.mobile,
    this.updatedAt,
  });

  factory LocalUserProfile.fromJson(Map<String, dynamic> json) {
    return LocalUserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String displayName;
  final String? email;
  final String? mobile;
  final String? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        if (email != null) 'email': email,
        if (mobile != null) 'mobile': mobile,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };

  @override
  List<Object?> get props => [id, displayName, email, mobile, updatedAt];
}
