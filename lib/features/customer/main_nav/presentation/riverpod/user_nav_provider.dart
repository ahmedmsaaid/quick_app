import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

/// Provider for managing selected index in UserNavScreen (Bottom Navigation Bar)
/// 0: Home, 1: Wallet, 2: Orders, 3: Profile
final userNavIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for managing initial tab in OrdersScreen
/// 0: Current Orders, 1: Completed Orders
final ordersInitialTabProvider = StateProvider<int>((ref) => 0);
