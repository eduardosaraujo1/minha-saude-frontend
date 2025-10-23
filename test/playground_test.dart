import 'dart:convert';

import 'package:test/test.dart';

void main() {
  test("JSON parse edge cases", () {
    // Add tests for JSON parsing edge cases here
    final value = json.decode('{"key": "value"}'); // Simple case
    expect(value, isA<Map<String, dynamic>>());
    expect(value['key'], 'value');

    // Test invalid JSON
    expect(() => json.decode('invalid json'), throwsA(isA<FormatException>()));
  });
}
