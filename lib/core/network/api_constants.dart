abstract class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com/';
  static const String products = 'products';
  static String categories(String name) => 'products/categories/$name';
  static const String search = 'products/search';
}
