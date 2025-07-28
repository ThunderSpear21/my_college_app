import 'dart:convert';

List<PublicProfile> publicProfileFromJson(String str) =>
    List<PublicProfile>.from(
      json.decode(str).map((x) => PublicProfile.fromJson(x)),
    );

class PublicProfile {
  final String id;
  final String name;
  final String email;
  final int yearOfAdmission;
  final bool isMentorEligible;
  final bool isAdmin;

  PublicProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.yearOfAdmission,
    required this.isMentorEligible,
    required this.isAdmin
  });

  factory PublicProfile.fromJson(Map<String, dynamic> json) {
    return PublicProfile(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      yearOfAdmission: json['yearOfAdmission'],
      isMentorEligible: json['isMentorEligible'] ?? false,
      isAdmin: json['isAdmin'] ?? false
    );
  }
}
