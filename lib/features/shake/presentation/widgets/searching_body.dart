import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_strings.dart';

class SearchingBody extends StatelessWidget {
  const SearchingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 50),
          Text(AppStrings.searchingText),
        ],
      ),
    );
  }
}
