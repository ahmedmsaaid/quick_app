import 'package:flutter/material.dart';

extension NavigationExtension on BuildContext {
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);

  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  void popUntil(String routeName) =>
      Navigator.of(this).popUntil(ModalRoute.withName(routeName));

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
          String routeName,
          {TO? result,
          Object? arguments}) =>
      Navigator.of(this).pushReplacementNamed<T, TO>(routeName,
          result: result, arguments: arguments);

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(String routeName,
          {Object? arguments}) =>
      Navigator.of(this).pushNamedAndRemoveUntil<T>(
          routeName, (route) => false,
          arguments: arguments);
}
