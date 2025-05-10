import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:irl_inventory/utils/formatters/formatter.dart';

class UserModel {
  /// Keep those values final which you do not want to update
  final String id;
  String firstName;
  String lastName;
  String username;
  final String email;
  String phoneNumber;
  String profilePicture;

  /// Constructor for UserModel
  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
  });

  /// Helper function to get the full name
  String get fullName => '$firstName $lastName';

  /// Helper function to format phone number
  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);

  /// Static function to split full name into first and last name
  static List<String> nameParts(String fullName) => fullName.split(' ');

  /// Static function to create an empty user model
  static UserModel empty() => UserModel(
        id: '',
        firstName: '',
        lastName: '',
        username: '',
        email: '',
        phoneNumber: '',
        profilePicture: '',
      );

  /// Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
    };
  }

  /// Factory method to create a UserModel from a Firestore document snapshot
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() == null) return UserModel.empty();
    
    final data = doc.data()!;
    return UserModel(
      id: data['id'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
    );
  }

  /// Factory method to create a UserModel from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
    );
  }
}