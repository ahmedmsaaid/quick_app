import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:base_app/core/services/image_picker_service.dart';

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});
