class User {
  final String id;
  final String name;
  final String email;
  final int yearOfAdmission;
  final bool isSuperAdmin;
  final bool isAdmin;
  final bool isMentorEligible;
  final String? menteeToMentorId;
  final List<String> mentorToMenteeIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.yearOfAdmission,
    required this.isSuperAdmin,
    required this.isAdmin,
    required this.isMentorEligible,
    required this.menteeToMentorId,
    required this.mentorToMenteeIds,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      yearOfAdmission: json['yearOfAdmission'],
      isSuperAdmin: json['isSuperAdmin'],
      isAdmin: json['isAdmin'],
      isMentorEligible: json['isMentorEligible'],
      menteeToMentorId: json['menteeToMentorId'],
      mentorToMenteeIds: List<String>.from(json['mentorToMenteeIds']),
    );
  }
}
