// vigilant_device.dart - Model for cameras, phones, locks, sensors
enum DeviceType { camera, phone, tablet, smart_lock, sensor, computer }

enum DeviceStatus { online, offline, low_battery, updating }

class VigilantDevice {
  final String id;
  final String name;
  final DeviceType type;
  final DeviceStatus status;
  final String? location; // e.g., "Front Door", "Living Room"
  final DateTime lastSeen;
  final Map<String, dynamic>? capabilities; // e.g., hasPTZ, nightVision, motionAI
  final double? batteryLevel; // 0.0 to 1.0 (only for mobile/battery devices)

  VigilantDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.location,
    required this.lastSeen,
    this.capabilities,
    this.batteryLevel,
  });

  factory VigilantDevice.fromJson(Map<String, dynamic> json) {
    return VigilantDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseDeviceType(json['type'] as String),
      status: _parseStatus(json['status'] as String),
      location: json['location'] as String?,
      lastSeen: DateTime.parse(json['last_seen'] as String),
      capabilities: json['capabilities'] as Map<String, dynamic>?,
      batteryLevel: json['battery_level'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'status': status.name,
      'location': location,
      'last_seen': lastSeen.toIso8601String(),
      'capabilities': capabilities,
      'battery_level': batteryLevel,
    };
  }

  static DeviceType _parseDeviceType(String value) {
    return DeviceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeviceType.sensor,
    );
  }

  static DeviceStatus _parseStatus(String value) {
    return DeviceStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeviceStatus.offline,
    );
  }

  // UI helpers
  Color get statusColor {
    switch (status) {
      case DeviceStatus.online:
        return Colors.green;
      case DeviceStatus.low_battery:
        return Colors.orange;
      case DeviceStatus.updating:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (type) {
      case DeviceType.camera:
        return Icons.videocam;
      case DeviceType.phone:
      case DeviceType.tablet:
        return Icons.smartphone;
      case DeviceType.smart_lock:
        return Icons.lock;
      case DeviceType.computer:
        return Icons.computer;
      default:
        return Icons.sensors;
    }
  }
}
