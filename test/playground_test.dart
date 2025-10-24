import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  test("Does http client throw?", () async {
    try {
      final test = await http.post(Uri.parse("https://unreachable.com"));
      print(test.body);
    } catch (e) {
      print("Error occurred: $e");
    }
  });
}
