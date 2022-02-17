class User {
  final String username, password;
  final String? email;

  const User(
      {required this.username, required this.password, this.email = null});

  Map<String, Object?> toJson() => {
        'username': username,
        'password': password,
        'email': email,
      };

  static User fromJson(Map<String, Object?> json) => User(
      username: json['username'] as String,
      password: json['password'] as String,
      email: json['email'] as String?);
}

final List<String> UserColumns = ['username', 'password', 'email'];
final UserTableName = "USERS";
