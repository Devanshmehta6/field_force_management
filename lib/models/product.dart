class Product {
  // String id;
  String name;
  int quantity;
  double manufacturingCost;
  String photoUrl;

  Product({
    // required this.id,
    required this.name,
    required this.quantity,
    required this.manufacturingCost,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
      'quantity': quantity,
      'manufacturingCost': manufacturingCost,
      'photoUrl': photoUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      // id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      manufacturingCost: map['manufacturingCost'],
      photoUrl: map['photoUrl'],
    );
  }
}
