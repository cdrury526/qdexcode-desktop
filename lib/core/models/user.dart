/// User, Organization, and Member models matching the Drizzle auth schema.
///
/// Maps to: packages/db/schema/auth.ts (user, organization, member tables).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// A registered user from the `user` table.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'email_verified') required bool emailVerified,
    String? image,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// An organization (team/workspace) from the `organization` table.
@freezed
abstract class Organization with _$Organization {
  const factory Organization({
    required String id,
    required String name,
    required String slug,
    String? logo,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? metadata,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
}

/// A membership linking a user to an organization, from the `member` table.
@freezed
abstract class Member with _$Member {
  const factory Member({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'user_id') required String userId,
    required String role,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) =>
      _$MemberFromJson(json);
}
