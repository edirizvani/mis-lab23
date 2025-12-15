class User{
  final String email;
  final String password;
  final String name;
  final String phone;

  User(this.phone, this.name, {required this.email, required this.password});
}