import 'package:flutter/material.dart';

/// Hem view hem edit modunda kullanılan profil fotoğrafı widget'ı.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.photoUrl, this.radius = 60});

  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Icon(
              Icons.person,
              size: radius,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}
