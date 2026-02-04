/// Domain model for offline emergency request
class OfflineRequest {
  final int? id;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final String? locationName;
  final DateTime createdAt;
  final SyncStatus syncStatus;
  final int retryCount;
  final String? errorMessage;

  OfflineRequest({
    this.id,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.locationName,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
    this.retryCount = 0,
    this.errorMessage,
  });

  OfflineRequest copyWith({
    int? id,
    String? type,
    String? description,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? createdAt,
    SyncStatus? syncStatus,
    int? retryCount,
    String? errorMessage,
  }) {
    return OfflineRequest(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus.name,
      'retry_count': retryCount,
      'error_message': errorMessage,
    };
  }

  factory OfflineRequest.fromJson(Map<String, dynamic> json) {
    return OfflineRequest(
      id: json['id'] as int?,
      type: json['type'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['location_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['sync_status'],
        orElse: () => SyncStatus.pending,
      ),
      retryCount: json['retry_count'] as int? ?? 0,
      errorMessage: json['error_message'] as String?,
    );
  }
}

/// Sync status enum
enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
}
