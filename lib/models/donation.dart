/// Represents a food donation on the Zuply platform.
class Donation {
  final int? id;
  final String foodItem;
  final int quantity;
  final String foodType; // 'veg' or 'non-veg'
  final int spiceLevel; // 1-5
  final String pickupAddress;
  final DateTime expiryTime;
  final bool isEmergency;
  final String status; // 'pending', 'accepted', 'in_transit', 'delivered', 'expired'
  final int? donorId;
  final double? aiScore;
  final DateTime? createdAt;

  Donation({
    this.id,
    required this.foodItem,
    required this.quantity,
    required this.foodType,
    required this.spiceLevel,
    required this.pickupAddress,
    required this.expiryTime,
    this.isEmergency = false,
    this.status = 'pending',
    this.donorId,
    this.aiScore,
    this.createdAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      foodItem: json['food_item'] ?? json['foodItem'] ?? '',
      quantity: json['quantity'] ?? 0,
      foodType: json['food_type'] ?? json['foodType'] ?? 'veg',
      spiceLevel: json['spice_level'] ?? json['spiceLevel'] ?? 1,
      pickupAddress: json['pickup_address'] ?? json['pickupAddress'] ?? '',
      expiryTime: DateTime.tryParse(json['expiry_time'] ?? json['expiryTime'] ?? '') ?? DateTime.now(),
      isEmergency: json['is_emergency'] ?? json['isEmergency'] ?? false,
      status: json['status'] ?? 'pending',
      donorId: json['donor_id'] ?? json['donorId'],
      aiScore: (json['ai_score'] ?? json['aiScore'])?.toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'food_item': foodItem,
    'quantity': quantity,
    'food_type': foodType,
    'spice_level': spiceLevel,
    'pickup_address': pickupAddress,
    'expiry_time': expiryTime.toIso8601String(),
    'is_emergency': isEmergency,
    'status': status,
  };

  /// Returns a human-readable time remaining until expiry.
  String get timeRemaining {
    final diff = expiryTime.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h left';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    return '${diff.inMinutes}m left';
  }

  /// Returns a color-coded urgency level based on expiry proximity.
  String get urgencyLevel {
    final diff = expiryTime.difference(DateTime.now());
    if (diff.isNegative) return 'expired';
    if (diff.inHours < 2) return 'critical';
    if (diff.inHours < 6) return 'urgent';
    return 'normal';
  }
}
