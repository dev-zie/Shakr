import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  Future<String?> pickFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    return image?.path;
  }
}
