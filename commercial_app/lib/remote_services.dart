import 'Products.dart';
import 'package:http/http.dart' as http;

class RemoteServices {
  static var client = http.Client();

  static Future<Products?> fetchProducts() async {
    var response = await client
        .get(Uri.parse('https://dummyjson.com/products?skip=0&limit=100'));
    if (response.statusCode == 200) {
      var jsonString = response.body;
      return productsFromJson(jsonString);
    }
    return null;
  }
}
