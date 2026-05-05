import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyAYhkfdHSnuZ6DTTELf_kMRb12fFvJP-DQ'; 
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  
  debugPrint('Sending request...');
  final response = await http.get(url);
  
  debugPrint('Status code: ${response.statusCode}');
  debugPrint('Response body: ${response.body}');
}
