import 'dart:io';

void main() {
  print('🚀 Starting project restructurer...');

  final mapping = {
    'lib/features/captain': 'lib/features/delivery/captain',
    'lib/features/wallet': 'lib/features/delivery/wallet',
    'lib/features/home': 'lib/features/customer/home',
    'lib/features/cart': 'lib/features/customer/cart',
    'lib/features/checkout': 'lib/features/customer/checkout',
    'lib/features/orders': 'lib/features/customer/orders',
    'lib/features/profile': 'lib/features/customer/profile',
    'lib/features/vendor_list': 'lib/features/customer/vendor_list',
    'lib/features/vendor_details': 'lib/features/customer/vendor_details',
    'lib/features/stream': 'lib/features/customer/stream',
    'lib/features/community': 'lib/features/customer/community',
    'lib/features/auth': 'lib/features/shared/auth',
    'lib/features/splash': 'lib/features/shared/splash',
    'lib/features/on_boarding': 'lib/features/shared/on_boarding',
    'lib/features/notifications': 'lib/features/shared/notifications',
    'lib/features/chats': 'lib/features/shared/chats',
    'lib/features/choose_lang&type': 'lib/features/shared/choose_lang_and_type',
  };

  // 1. Delete generated .g.dart files in lib/features
  print('🗑️ Deleting generated code files...');
  final featuresDir = Directory('lib/features');
  if (featuresDir.existsSync()) {
    featuresDir.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith('.g.dart')) {
        entity.deleteSync();
      }
    });
  }

  // 2. Pre-process nav screens
  print('✈️ Moving main navigation screens to delivery & customer...');
  Directory('lib/features/customer/main_nav/presentation/screens').createSync(recursive: true);
  Directory('lib/features/delivery/main_nav/presentation/screens').createSync(recursive: true);

  final userNav = File('lib/features/main_nav/presentation/screens/user_nav_screen.dart');
  if (userNav.existsSync()) {
    userNav.copySync('lib/features/customer/main_nav/presentation/screens/user_nav_screen.dart');
  }

  final captainNav = File('lib/features/main_nav/presentation/screens/captain_nav_screen.dart');
  if (captainNav.existsSync()) {
    captainNav.copySync('lib/features/delivery/main_nav/presentation/screens/captain_nav_screen.dart');
  }

  // Delete main_nav directory entirely
  final oldMainNav = Directory('lib/features/main_nav');
  if (oldMainNav.existsSync()) {
    oldMainNav.deleteSync(recursive: true);
  }

  // 3. Move modules from old locations to new locations
  print('📁 Moving feature modules...');
  mapping.forEach((oldPath, newPath) {
    final oldDir = Directory(oldPath);
    if (oldDir.existsSync()) {
      _moveDirectory(oldDir, Directory(newPath));
    }
  });

  // 4. Pluralize screen folder to screens inside choose_lang_and_type and on_boarding
  final langScreen = Directory('lib/features/shared/choose_lang_and_type/presentation/screen');
  final langScreens = Directory('lib/features/shared/choose_lang_and_type/presentation/screens');
  if (langScreen.existsSync()) {
    _moveDirectory(langScreen, langScreens);
  }

  final onBoardingScreen = Directory('lib/features/shared/on_boarding/screen');
  final onBoardingScreens = Directory('lib/features/shared/on_boarding/screens');
  if (onBoardingScreen.existsSync()) {
    _moveDirectory(onBoardingScreen, onBoardingScreens);
  }

  // 5. Update imports in all Dart files under lib/
  print('✍️ Updating import statements in files...');
  final libDir = Directory('lib');
  if (libDir.existsSync()) {
    libDir.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith('.dart')) {
        _updateImports(entity);
      }
    });
  }

  // Clean up old empty folders
  print('🧹 Clean up old folders...');
  mapping.keys.forEach((oldPath) {
    final dir = Directory(oldPath);
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  print('🎉 Project structure reorganized successfully!');
}

void _moveDirectory(Directory source, Directory destination) {
  if (!destination.existsSync()) {
    destination.createSync(recursive: true);
  }
  source.listSync(recursive: false).forEach((entity) {
    final name = entity.path.split(Platform.pathSeparator).last;
    if (entity is Directory) {
      _moveDirectory(entity, Directory('${destination.path}/$name'));
    } else if (entity is File) {
      entity.copySync('${destination.path}/$name');
    }
  });
  source.deleteSync(recursive: true);
}

void _updateImports(File file) {
  String content = file.readAsStringSync();

  // Convert relative imports of features into package imports first (like in app_router)
  content = content.replaceAllMapped(
    RegExp("import (['\"])\\.\\./\\.\\./features/"),
    (match) => "import ${match.group(1)}package:base_app/features/",
  );
  content = content.replaceAllMapped(
    RegExp("import (['\"])\\.\\./features/"),
    (match) => "import ${match.group(1)}package:base_app/features/",
  );

  // Apply absolute import path mappings
  content = content.replaceAll(
    "package:base_app/features/captain/",
    "package:base_app/features/delivery/captain/",
  );
  content = content.replaceAll(
    "package:base_app/features/wallet/",
    "package:base_app/features/delivery/wallet/",
  );
  content = content.replaceAll(
    "package:base_app/features/home/",
    "package:base_app/features/customer/home/",
  );
  content = content.replaceAll(
    "package:base_app/features/cart/",
    "package:base_app/features/customer/cart/",
  );
  content = content.replaceAll(
    "package:base_app/features/checkout/",
    "package:base_app/features/customer/checkout/",
  );
  content = content.replaceAll(
    "package:base_app/features/orders/",
    "package:base_app/features/customer/orders/",
  );
  content = content.replaceAll(
    "package:base_app/features/profile/",
    "package:base_app/features/customer/profile/",
  );
  content = content.replaceAll(
    "package:base_app/features/vendor_list/",
    "package:base_app/features/customer/vendor_list/",
  );
  content = content.replaceAll(
    "package:base_app/features/vendor_details/",
    "package:base_app/features/customer/vendor_details/",
  );
  content = content.replaceAll(
    "package:base_app/features/stream/",
    "package:base_app/features/customer/stream/",
  );
  content = content.replaceAll(
    "package:base_app/features/community/",
    "package:base_app/features/customer/community/",
  );
  content = content.replaceAll(
    "package:base_app/features/auth/",
    "package:base_app/features/shared/auth/",
  );
  content = content.replaceAll(
    "package:base_app/features/splash/",
    "package:base_app/features/shared/splash/",
  );
  content = content.replaceAll(
    "package:base_app/features/on_boarding/screen/",
    "package:base_app/features/shared/on_boarding/screens/",
  );
  content = content.replaceAll(
    "package:base_app/features/on_boarding/",
    "package:base_app/features/shared/on_boarding/",
  );
  content = content.replaceAll(
    "package:base_app/features/notifications/",
    "package:base_app/features/shared/notifications/",
  );
  content = content.replaceAll(
    "package:base_app/features/chats/",
    "package:base_app/features/shared/chats/",
  );
  content = content.replaceAll(
    "package:base_app/features/choose_lang&type/presentation/screen/",
    "package:base_app/features/shared/choose_lang_and_type/presentation/screens/",
  );
  content = content.replaceAll(
    "package:base_app/features/choose_lang&type/",
    "package:base_app/features/shared/choose_lang_and_type/",
  );
  content = content.replaceAll(
    "package:base_app/features/main_nav/presentation/screens/user_nav_screen.dart",
    "package:base_app/features/customer/main_nav/presentation/screens/user_nav_screen.dart",
  );
  content = content.replaceAll(
    "package:base_app/features/main_nav/presentation/screens/captain_nav_screen.dart",
    "package:base_app/features/delivery/main_nav/presentation/screens/captain_nav_screen.dart",
  );

  // Update part directives
  content = content.replaceAllMapped(
    RegExp(r"part '(.+)\.g\.dart';"),
    (match) => "part '${match.group(1)}.g.dart';",
  );

  file.writeAsStringSync(content);
}
