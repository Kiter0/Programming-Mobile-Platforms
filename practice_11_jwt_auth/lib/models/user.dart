class User {
  final int? id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;

  const User({
    this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
  });

  String get fullName {
    final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return name.isEmpty ? email : name;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : null,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
    };
  }

  User copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
    );
  }
}
