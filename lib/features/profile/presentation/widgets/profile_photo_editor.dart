import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_cubit.dart';
import 'profile_avatar.dart';

/// Edit modunda: fotoğraf + sağ altta kamera / yükleme göstergesi.
class ProfilePhotoEditor extends StatelessWidget {
  const ProfilePhotoEditor({
    super.key,
    required this.photoUrl,
    required this.isUploading,
  });

  final String? photoUrl;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          ProfileAvatar(photoUrl: photoUrl),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        LucideIcons.camera,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () =>
                          context.read<ProfileCubit>().pickAndUploadPhoto(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
