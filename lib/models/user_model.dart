class UserModel {
  String name;
  String age;
  String address;

  UserModel({required this.name, required this.address, required this.age});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      age: json['age'],
      address: json['address'],
    );
  }

  // from user to storage
  Map<String, dynamic> toJson() {
    return {"name": name, "age": age, "address": address};
  }
}
