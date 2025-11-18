/// Customer model
class CustomerModel {
  final int? id;
  final String? code;
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? image;
  final double? balance;
  final String? customerType;
  final String? remarks;

  CustomerModel({
    this.id,
    this.code,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.image,
    this.balance,
    this.customerType,
    this.remarks,
  });

  /// Create CustomerModel from JSON
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['Id'] ?? json['id'],
      code: json['Code'] ?? json['code'],
      name: json['Name'] ?? json['name'],
      phone: json['Phone'] ?? json['phone'],
      email: json['Email'] ?? json['email'],
      address: json['PrimaryAddress'] ?? json['Address'] ?? json['address'],
      image: json['ImagePath'] ?? json['Image'] ?? json['image'],
      balance: _parseDouble(json['TotalDue'] ?? json['Balance'] ?? json['balance']),
      customerType: json['CustType'] ?? json['CustomerType'] ?? json['customerType'],
      remarks: json['Notes'] ?? json['Remarks'] ?? json['remarks'],
    );
  }

  /// Helper method to parse double from dynamic value
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Convert CustomerModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'image': image,
      'balance': balance,
      'customerType': customerType,
      'remarks': remarks,
    };
  }

  /// Get full image URL
  String? getImageUrl(String baseImageUrl) {
    if (image == null || image!.isEmpty) return null;
    
    // If image already contains full URL
    if (image!.startsWith('http')) return image;
    
    // Construct full URL
    return baseImageUrl + image!;
  }
}
