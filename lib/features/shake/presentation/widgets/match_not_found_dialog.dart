import 'package:flutter/cupertino.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';
import 'package:shakr/common/getit/injection.dart';

class MatchNotFoundDialog extends StatelessWidget {
  const MatchNotFoundDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text(AppStrings.matchNotFound),
      content: const Text(AppStrings.noBodyFound),
      actions: [
        CupertinoDialogAction(
          child: const Text(AppStrings.okay),
          onPressed: () {
            sl<ShakeCubit>().disposeScreen();
            sl<ShakeCubit>().init();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
