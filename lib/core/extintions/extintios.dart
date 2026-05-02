import 'package:easy_localization/easy_localization.dart';

 import '../exports/exports.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

extension BullBoolExtension on bool? {
  /* null false , false false */
  bool get orFalse => this == null ? false : this!;
  bool get orTrue => this == null ? true : this!;
  int get fromBoolToInt => this == true ? 1 : 0;
  bool get isTrue => this == true;
  bool get isFalse => this == false;
}

extension BoolExtension on bool {
  /* null false , false false */
  bool get isFalse => this == false;
  bool get isTrue => this == true;
  Widget isTrueGetWidget(Widget widget) =>
      isTrue ? widget : const SizedBox.shrink();
  Widget? isTrueGetWidgetOrAnotherWidget(Widget widget1, Widget widget2) =>
      isTrue ? widget1 : widget2;
}

extension CutomMethodsOnNullObject on Object? {
  bool get isNull => this == null;
  bool get isNotNull => this != null;
  bool get isNotNullAndIsFalse => this != null && this == false;
  bool get isNotNullAndIsTrue => this != null && this == true;
  bool get isNullOrIsFalse =>
      this == null || this == false; // Fixed: was "this == true"
  bool get isNotNullOrFalse =>
      this != null || this == false; // Fixed: was "this != true"
  bool get isNotFalse => this != false;
  bool get isNotTrue => this != true;
  bool get isTrue => (this as bool?).orFalse == true;
  bool get isFalse => (this as bool?).orFalse == false;

  // Fixed: Added proper type checking for different object types
  bool get isNullOrEmpty {
    if (this == null) return true;
    if (this is String) return (this as String).isEmpty;
    if (this is List) return (this as List).isEmpty;
    if (this is Map) return (this as Map).isEmpty;
    return false;
  }

  Widget isNotNullGetWidget(Widget? widget) =>
      isNotNull ? widget! : const SizedBox.shrink();

  // Fixed: Return type should match the actual return value
  String get validate {
    if (isNullOrEmpty) {
      return '';
    } else {
      return toString(); // Fixed: Convert to string properly
    }
  }

  // Fixed: Parse string to int for Duration constructor
  Duration get milliseconds {
    if (this == null) return const Duration(milliseconds: 0);
    if (this is int) return Duration(milliseconds: this as int);
    if (this is String) {
      final parsed = int.tryParse(this as String) ?? 0;
      return Duration(milliseconds: parsed);
    }
    return const Duration(milliseconds: 0);
  }
}

extension LocalizationExtension on String {
  String get trans => this.tr();
}

get getContext => navigatorKey.currentState?.context;

Map<String, dynamic>? getArguments(BuildContext context) =>
    (ModalRoute.of(context))?.settings.arguments as Map<String, dynamic>?;

NavigatorState? get getCurrentState => navigatorKey.currentState;

// static AppLocalizations get lan => Localizations.of<AppLocalizations>(getContext, AppLocalizations)!;

/// if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
// get getContext => navigatorKey.currentContext;

/// Navigate to a new route with various options
Future<T?> pushRoute<T>(
  String route, {
  bool isNewTask = false,
  bool isToReplace = false,
  String? exceptRoute,
  Map<String, dynamic>? arguments,
}) async {
  if (isNewTask) {
    /*(route) => route.isCurrent && route.settings.name == "newRouteName"
        ? false
        : true)*/
    return Navigator.pushNamedAndRemoveUntil<T>(
      getContext,
      route,
      exceptRoute.isNotNull
          ? ModalRoute.withName(exceptRoute!)
          : (route) => false,
      arguments: arguments,
    );
  } else if (isToReplace) {
    return Navigator.pushReplacementNamed(
      getContext,
      route,
      arguments: arguments,
    );
  } else {
    return Navigator.pushNamed<T>(getContext, route, arguments: arguments);
  }
}

/// Dispose current screens or close current dialog
void pop<T>([T? object]) {
  if (Navigator.canPop(getContext)) Navigator.pop<T>(getContext, object);
}

/// Navigate to a route with context
push({
  required BuildContext context,
  required String route,
  Map<String, dynamic>? argument,
}) => Navigator.pushNamed(context, route, arguments: argument);

/// Push a screen widget directly
Future<T?> pushScreen<T>({
  required BuildContext context,
  required Widget screen,
  Map<String, dynamic>? argument,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => screen,
    settings: RouteSettings(arguments: argument),
  ),
);

/// Push and remove all previous routes
pushAndRemove({required BuildContext context, required String route}) =>
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);

/// Get current route name
String? get getCurrentRouteName => ModalRoute.of(getContext)?.settings.name;
