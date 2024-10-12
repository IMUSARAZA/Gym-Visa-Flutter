class Subscription {
  final String name;
  final String price;

  Subscription({
    required this.name,
    required this.price,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      name: json['name'] ?? '',
      price: json['price'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "price": price,
    };
  }
}
