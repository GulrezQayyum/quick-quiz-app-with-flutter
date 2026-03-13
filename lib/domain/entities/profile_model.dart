// lib/domain/entities/profile_model.dart

class UserProfile {
  final String id;
  final String name;
  final String bio;
  final String avatarUrl;
  final String avatarSeed;
  final String location;
  final List<String> favoriteCategories;
  final int totalXP;
  final int quizzesPlayed;

  UserProfile({
    required this.id,
    this.name = '',
    this.bio = '',
    this.avatarUrl = '',
    this.avatarSeed = '',
    this.location = '',
    this.favoriteCategories = const [],
    this.totalXP = 0,
    this.quizzesPlayed = 0,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id:                 map['id'] ?? '',
      name:               map['name'] ?? '',
      bio:                map['bio'] ?? '',
      avatarUrl:          map['avatarUrl'] ?? '',
      avatarSeed:         map['avatarSeed'] ?? '',
      location:           map['location'] ?? '',
      favoriteCategories: List<String>.from(map['favoriteCategories'] ?? []),
      totalXP:            (map['totalXP'] ?? 0) as int,
      quizzesPlayed:      (map['quizzesPlayed'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':                 id,
      'name':               name,
      'bio':                bio,
      'avatarUrl':          avatarUrl,
      'avatarSeed':         avatarSeed,
      'location':           location,
      'favoriteCategories': favoriteCategories,
      'totalXP':            totalXP,
      'quizzesPlayed':      quizzesPlayed,
    };
  }

  UserProfile copyWith({
    String? name,
    String? bio,
    String? avatarUrl,
    String? avatarSeed,
    String? location,
    List<String>? favoriteCategories,
    int? totalXP,
    int? quizzesPlayed,
  }) {
    return UserProfile(
      id:                 id,
      name:               name               ?? this.name,
      bio:                bio                ?? this.bio,
      avatarUrl:          avatarUrl          ?? this.avatarUrl,
      avatarSeed:         avatarSeed         ?? this.avatarSeed,
      location:           location           ?? this.location,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      totalXP:            totalXP            ?? this.totalXP,
      quizzesPlayed:      quizzesPlayed      ?? this.quizzesPlayed,
    );
  }
}