import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickPhoto() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }
}
