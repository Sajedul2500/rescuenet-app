class ResourceShareHistoryItem {
  final String requestType;
  final String requestedBy;
  final String location;
  final DateTime sharedAt;

  const ResourceShareHistoryItem({
    required this.requestType,
    required this.requestedBy,
    required this.location,
    required this.sharedAt,
  });

  factory ResourceShareHistoryItem.fromJson(Map<String, dynamic> json) {
    return ResourceShareHistoryItem(
      requestType: json['requestType']?.toString() ?? 'Emergency',
      requestedBy: json['requestedBy']?.toString() ?? 'Unknown',
      location: json['location']?.toString() ?? 'Location unavailable',
      sharedAt: DateTime.tryParse(json['sharedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestType': requestType,
      'requestedBy': requestedBy,
      'location': location,
      'sharedAt': sharedAt.toIso8601String(),
    };
  }
}
