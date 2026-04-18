extension GenderExtension on String {
  String toGenderLabel() {
    switch (this) {
      case 'erkek':
      case 'male':
        return 'Erkek';
      case 'kadin':
      case 'female':
        return 'Kadın';
      default:
        return this;
    }
  }
}
