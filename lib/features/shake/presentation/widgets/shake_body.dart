import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';
import 'package:shakr/common/getit/injection.dart';

class ShakeBody extends StatelessWidget {
  const ShakeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(AppStrings.shakeString),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;
              final location = await sl<LocationService>().getCurrentLocation();
              final shake = ShakeEntity(
                uid: uid,
                location: location,
                status: 'waiting',
                timestamp: DateTime.now(),
              );
              sl<ShakeCubit>().recordShake(shake);
            },
            child: const Text('TEST: Salla'),
          ),
        ],
      ),
    );
  }
}
