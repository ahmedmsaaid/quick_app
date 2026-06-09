class LoginRequest {
  final String phone;
  final String password;
  final String role; // customer, driver, vendor

  LoginRequest({
    required this.phone,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'password': password,
    'role': role,
  };
}
