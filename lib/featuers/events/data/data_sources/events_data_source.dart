import 'dart:convert';

import 'package:home_page/core/constants/constants.dart';
import 'package:home_page/featuers/events/data/models/events.dart';
import 'package:http/http.dart' as http;

class EventsApi {
  Future<List<Events>> fetchEventsData() async {
    final url = Uri.parse(baseUrlEvents);

    try {
      final response = await http.get(url);
      print(
        "Full API Response: ${response.body}",
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Events.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load events data");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }

  Future<List<Speaker>> fetchSpeakersData() async {
    final url = Uri.parse(baseUrlSpeakers);

    try {
      final response = await http.get(url);
      print(
        "Full API Response for speakers: ${response.body}",
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Speaker.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load events data");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }

  Future<List<Trip>> fetchTripData() async {
    final url = Uri.parse(baseUrlTrip);

    try {
      final response = await http.get(url);
      print(
        "Full API Response for Trips: ${response.body}",
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Trip.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load events data");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
