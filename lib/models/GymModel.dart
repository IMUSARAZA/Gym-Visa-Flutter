class Gym {
  late String id;
  late String name;
  late String subscription;
  late String phoneNo;
  late String email;
  late String description;
  late String city;
  late String country;
  late String address;
  late String googleMapsLink;
  late String imageUrl1;
  late String imageUrl2;
  late String? qrCodeUrl;
  late String gymID;

  Gym({
    required this.name,
    required this.subscription,
    required this.phoneNo,
    required this.email,
    required this.description,
    required this.city,
    required this.country,
    required this.address,
    required this.googleMapsLink,
    required this.imageUrl1,
    required this.imageUrl2,
    required this.gymID,
    this.qrCodeUrl,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      name: json['name'] ?? '',
      subscription: json['subscription'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      email: json['email'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      address: json['address'] ?? '',
      googleMapsLink: json['googleMapsLink'] ?? '',
      imageUrl1: json['imageUrl1'] ?? '',
      imageUrl2: json['imageUrl2'] ?? '',
      gymID: json['gymID'] ?? '',
      qrCodeUrl: json['qrCodeUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subscription': subscription,
      'phoneNo': phoneNo,
      'email': email,
      'description': description,
      'city': city,
      'country': country,
      'address': address,
      'googleMapsLink': googleMapsLink,
      'imageUrl1': imageUrl1,
      'imageUrl2': imageUrl2,
      'qrCodeUrl': qrCodeUrl,
      'gymID' : gymID,
    };
  }

  

  Gym copyWith({
    String? name,
    String? subscription,
    String? phoneNo,
    String? email,
    String? description,
    String? city,
    String? country,
    String? address,
    String? googleMapsLink,
    String? imageUrl1,
    String? imageUrl2,
    String? gymID,
    String? qrCodeUrl, required String gymName,
  }) {
    return Gym(
      name: name ?? this.name,
      subscription: subscription ?? this.subscription,
      phoneNo: phoneNo ?? this.phoneNo,
      email: email ?? this.email,
      description: description ?? this.description,
      city: city ?? this.city,
      country: country ?? this.country,
      address: address ?? this.address,
      googleMapsLink: googleMapsLink ?? this.googleMapsLink,
      imageUrl1: imageUrl1 ?? this.imageUrl1,
      imageUrl2: imageUrl2 ?? this.imageUrl2,
      gymID: gymID ?? this.gymID,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
    );
  }
}
