import 'package:flutter/material.dart';

extension NavigationExtension on BuildContext {
  void push(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed(routeName, arguments: arguments);

  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  void popUntil(String routeName) =>
      Navigator.of(this).popUntil(ModalRoute.withName(routeName));

  void pushReplacement(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);

  void pushAndRemoveAll(String routeName, {Object? arguments}) => Navigator.of(
    this,
  ).pushNamedAndRemoveUntil(routeName, (route) => false, arguments: arguments);
}
