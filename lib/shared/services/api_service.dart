import 'dart:convert';

import 'package:agu_mobile/shared/config/constants.dart';
import 'package:agu_mobile/features/menu/data/models/academic.dart';
import 'package:http/http.dart' as http;

class AcademicApi {
  Future<List<Academic>> fetchAcademicData() async {
    final url = Uri.parse(baseUrlAcademic);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Academic.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load academic data");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
