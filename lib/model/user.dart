import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  int age;
  String email;
  String phone;
  String position;

  User({
    required this.name,
    required this.age,
    required this.email,
    required this.phone,
    required this.position,
  });

  // Convert a User object to a Map (used for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'phone': phone,
      'position': position,
    };
  }

  // Convert a Map to a User object (used when retrieving data from Firestore)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      position: map['position'] ?? '',
    );
  }

  // Optionally, to convert the User object to a JSON string
  String toJson() {
    return '{"name": "$name", "age": $age, "email": "$email", "phone": "$phone", "position": "$position"}';
  }

  // Optionally, to create a User object from a JSON string
  factory User.fromJson(String jsonString) {
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return User.fromMap(map);
  }
}
