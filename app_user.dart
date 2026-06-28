import 'package:equatable/equatable.dart';

/// A minimal local user profile.
///
/// This intentionally mirrors the *shape* of a future Firebase
/// [User]-like object (id, displayName, email) without depending on
/// Firebase at all — so when real Firebase Auth is added later, the
/// rest of the app (anything that reads "the current user") shouldn't
/// need to change, only [AuthRepository]'s implementation does.
class AppUser extends Equatable {
  final String id;
  final String displayName;
  final String? email;
  final bool pinEnabled;

  const AppUser({
    required this.id,
    required this.displayName,
    this.email,
    this.pinEnabled = false,
  });

  AppUser copyWith({
    String? displayName,
    String? email,
    bool? pinEnabled,
  }) {
    return AppUser(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      pinEnabled: pinEnabled ?? this.pinEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'pinEnabled': pinEnabled,
      };

  factory AppUser.fromMap(Map<dynamic, dynamic> map) => AppUser(
        id: map['id'] as String,
        displayName: map['displayName'] as String,
        email: map['email'] as String?,
        pinEnabled: map['pinEnabled'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, displayName, email, pinEnabled];
}
