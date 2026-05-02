import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

class DropDownModel {
  final String id;
  final String name;
  final String icon;

  DropDownModel({required this.id, required this.name, required this.icon});
}

class CustomDropDown extends StatefulWidget {
  const CustomDropDown({
    super.key,
    required this.units,
    this.title,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
    this.validator,
    this.validatorEnabled = true,
  });

  final List<DropDownModel> units;
  final String? title;
  final String? initialValue;
  final Function(DropDownModel)? onChanged;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool validatorEnabled;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown>
    with SingleTickerProviderStateMixin {
  DropDownModel? _selectedUnit;
  late List<DropDownModel> _filteredUnits;
  late TextEditingController _searchController;
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredUnits = widget.units;

    // ✅ الحل الصحيح للـ initial value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedUnit = _getInitialSelection();
      if (mounted) setState(() {});
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  /// ✅ Helper method لحل مشكلة nullable type
  DropDownModel? _getInitialSelection() {
    if (widget.units.isEmpty) return null;

    if (widget.initialValue != null) {
      try {
        return widget.units.firstWhere(
          (unit) => unit.id == widget.initialValue!,
          orElse: () => widget.units.first, // ✅ دايماً AuthDropDownModel
        );
      } catch (e) {
        return widget.units.first;
      }
    }

    return widget.units.first;
  }

  @override
  void didUpdateWidget(covariant CustomDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.units != widget.units) {
      _filteredUnits = widget.units;
      _selectedUnit = _getInitialSelection();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _filterUnits(String query) {
    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        _filteredUnits = widget.units;
      } else {
        _filteredUnits = widget.units
            .where(
              (unit) => unit.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });

    _updateOverlay();
  }

  void _toggleDropdown() {
    if (widget.enabled) {
      HapticFeedback.lightImpact();
      if (_isDropdownOpen) {
        _closeDropdown();
      } else {
        _openDropdown();
      }
    }
  }

  void _openDropdown() {
    if (!mounted) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    setState(() => _isDropdownOpen = true);
  }

  void _closeDropdown() {
    if (!mounted) return;
    _searchController.clear();
    _filterUnits('');
    _animationController.reverse().then((_) => _removeOverlay());
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isDropdownOpen = false);
    }
  }

  void _updateOverlay() {
    if (_isDropdownOpen && _overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _selectItem(DropDownModel unit) {
    if (!mounted || unit == _selectedUnit) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _selectedUnit = unit;
    });

    widget.onChanged?.call(unit);
    _closeDropdown();
  }

  String? _validate() {
    if (!widget.validatorEnabled || widget.validator == null) return null;
    return widget.validator!(_selectedUnit?.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 2),
              child: Text(
                widget.title!,
                style: AppTextStyles.text12w500(color: colors.textSecondary),
              ),
            ),

          // Main Dropdown Container
          GestureDetector(
            key: _dropdownKey,
            onTap: widget.enabled ? _toggleDropdown : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _isDropdownOpen
                    ? colors.primary.withOpacity(0.08)
                    : colors.surface,
                border: Border.all(
                  color: _isDropdownOpen ? colors.primary : colors.border,
                  width: _isDropdownOpen ? 2 : 1,
                ),
                boxShadow: _isDropdownOpen
                    ? [
                        BoxShadow(
                          color: colors.shadow,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Icon/Image
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedUnit != null
                            ? colors.primary.withOpacity(0.3)
                            : colors.border,
                        width: 1.5,
                      ),
                      color: _selectedUnit == null ? colors.surface : null,
                    ),
                    child: _selectedUnit == null
                        ? Icon(
                            Icons.account_circle_outlined,
                            color: colors.textSecondary,
                            size: 20,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              _selectedUnit!.icon,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.account_circle_outlined,
                                    color: colors.textSecondary,
                                    size: 20,
                                  ),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: colors.surface,
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: colors.textHint,
                                        size: 20,
                                      ),
                                    );
                                  },
                            ),
                          ),
                  ),

                  const SizedBox(width: 12),

                  // Text
                  Expanded(
                    child: Text(
                      _selectedUnit?.name ??
                          (widget.title ?? AppStrings.select.tr()),
                      style: _selectedUnit != null
                          ? AppTextStyles.text14w600()
                          : AppTextStyles.text14w500(
                              color: colors.textSecondary,
                            ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Arrow
                  AnimatedRotation(
                    turns: _isDropdownOpen ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _isDropdownOpen
                          ? colors.primary
                          : colors.textSecondary,
                      size: 22,
                    ),
                  ),

                  if (!widget.enabled) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.lock_outline_rounded,
                      color: colors.textDisabled,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Error Message
          if (_validate() != null && _validate()!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                _validate()!,
                style: AppTextStyles.text12w400(color: colors.error),
              ),
            ),
        ],
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    if (!mounted || _dropdownKey.currentContext == null) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 8,
        width: size.width,
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: size.width,
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                color: AppColors(context).surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors(context).border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors(context).shadow,
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Field
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors(context).divider,
                          width: 1,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _filterUnits,
                      style: AppTextStyles.text14w500(),
                      decoration: InputDecoration(
                        hintText: AppStrings.search.tr(),
                        hintStyle: AppTextStyles.text14w500(
                          color: AppColors(context).textHint,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors(context).textSecondary,
                          size: 20,
                        ),
                        suffixIcon: _filteredUnits.length < widget.units.length
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: AppColors(context).textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterUnits('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors(context).border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors(context).border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors(context).primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors(context).surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),

                  // Items List
                  Flexible(
                    child: _filteredUnits.isEmpty
                        ? Container(
                            height: 120,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  color: AppColors(context).textHint,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppStrings.noResults.tr(),
                                  style: AppTextStyles.text14w500(
                                    color: AppColors(context).textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _filteredUnits.length,
                            physics: const ClampingScrollPhysics(),
                            separatorBuilder: (_, __) => Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              color: AppColors(context).divider,
                            ),
                            itemBuilder: (context, index) {
                              final unit = _filteredUnits[index];
                              final isSelected = _selectedUnit?.id == unit.id;

                              return InkWell(
                                onTap: () => _selectItem(unit),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors(
                                            context,
                                          ).primary.withOpacity(0.1)
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      // Item Icon
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors(context).primary
                                                : AppColors(context).border,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          child: Image.network(
                                            unit.icon,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Icon(
                                                  Icons.account_circle_outlined,
                                                  color: AppColors(
                                                    context,
                                                  ).textSecondary,
                                                  size: 22,
                                                ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      // Item Text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              unit.name,
                                              style: AppTextStyles.text16w500(
                                                color: isSelected
                                                    ? AppColors(context).primary
                                                    : AppColors(
                                                        context,
                                                      ).textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Selection Indicator
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors(context).primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check_rounded,
                                            color: AppColors.white,
                                            size: 18,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
