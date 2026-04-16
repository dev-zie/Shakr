import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_state.dart';
import 'package:shakr/features/profile/presentation/widgets/profile_edit_form.dart';
import 'package:shakr/features/profile/presentation/widgets/profile_view_body.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = context.read<AuthCubit>().currentUid;

    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..loadProfile(uid ?? ''),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.profileUpdated)),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppStrings.errorPrefix}: ${state.message}'),
              ),
            );
          } else if (state is ProfilePhotoUploadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppStrings.photoUploadError}: ${state.message}',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppStrings.myProfile),
              actions: [
                if (state is ProfileLoaded)
                  IconButton(
                    icon: Icon(state.isEditing ? Icons.close : Icons.edit),
                    onPressed: () =>
                        context.read<ProfileCubit>().toggleEditMode(),
                  ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state is ProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ProfileLoaded) {
      return state.isEditing
          ? ProfileEditForm(state: state)
          : ProfileViewBody(user: state.user);
    }
    return const Center(child: Text(AppStrings.profileNotFound));
  }
}
