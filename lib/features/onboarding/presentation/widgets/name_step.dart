import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';

class NameStep extends StatelessWidget {
  const NameStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.hello,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            AppStrings.whatToCall,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: cubit.nameController,
            decoration: const InputDecoration(hintText: AppStrings.yourName),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(cubit),
          ),
          const SizedBox(height: AppSpacing.xl),
          ValueListenableBuilder(
            valueListenable: cubit.nameController,
            builder: (context, value, _) => ElevatedButton(
              onPressed: value.text.trim().isEmpty ? null : () => _submit(cubit),
              child: const Text(AppStrings.continueButton),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(OnboardingCubit cubit) {
    final name = cubit.nameController.text.trim();
    if (name.isEmpty) return;
    cubit.setName(name);
  }
}
