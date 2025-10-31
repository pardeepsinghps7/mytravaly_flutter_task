class Hotel {
  final String id;
  final String name;
  final String? imageUrl;
  final String code;
  final String city;
  final String state;
  final String country;
  final String propertyUrl;

  Hotel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.code,
    required this.city,
    required this.state,
    required this.country,
    required this.propertyUrl,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    // Extract image URL
    final imageData = json['propertyImage'];
    String? imageUrl;

    if (imageData != null) {
      if (imageData is Map && imageData['fullUrl'] != null) {
        imageUrl = imageData['fullUrl'];
      } else if (imageData['location'] != null && imageData['imageName'] != null) {
        imageUrl = '${imageData['location']}${imageData['imageName']}';
      }
    }

    // Extract address
    final address = json['propertyAddress'] as Map<String, dynamic>? ?? {};

    return Hotel(
      id: json['propertyCode'] ?? '',
      name: json['propertyName'] ?? 'Unknown',
      imageUrl: imageUrl,
      code: json['propertyCode'] ?? '',
      city: address['city'] ?? '',
      state: address['state'] ?? '',
      country: address['country'] ?? '',
      propertyUrl: json['propertyUrl'] ?? '',
    );
  }
}
