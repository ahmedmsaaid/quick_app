enum RoleTypeEnum {
  restaurant, // 0
  market,     // 1
  customer,   // 2
  captain,    // 3
  admin;      // 4

  static RoleTypeEnum fromJson(int index) {
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    return RoleTypeEnum.customer;
  }
}
