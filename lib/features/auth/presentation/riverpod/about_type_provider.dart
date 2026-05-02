// lib/features/auth/presentation/providers/about_type_provider.dart
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/providers/image_picker_provider.dart';
import 'about_type_notifier.dart';
import 'about_type_state.dart';

final aboutTypeProvider =
    StateNotifierProvider.autoDispose<AboutTypeNotifier, AboutTypeState>((ref) {
      final imagePickerService = ref.watch(imagePickerServiceProvider);
      return AboutTypeNotifier(imagePickerService);
    });
