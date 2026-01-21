import 'package:equatable/equatable.dart';

/// Entity đại diện cho User
class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    avatarUrl,
    createdAt,
    updatedAt,
  ];
}
