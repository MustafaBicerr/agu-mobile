class Academic {
  String? category;
  String? event;
  String? startDate;
  String? endDate;
  String? term;

  Academic.isEmpty();
  Academic(this.category, this.event, this.startDate, this.endDate);

  Academic.fromJson(Map<String, dynamic> json) {
    category = json["category"];
    event = json["event"];
    startDate = json["startDate"];
    endDate = json["endDate"];
    term = json["term"];
  }

  Map toJson() {
    return {
      "category": category,
      "event": event,
      "startDate": startDate,
      "endDate": endDate,
      "term": term
    };
  }
}
