import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';

// ---------------------------------------------------------------------------
// Config models
// ---------------------------------------------------------------------------

class SearchFieldConfig {
  final String label;
  final String apiKey;
  final String? hint;
  final IconData icon;
  final TextInputType keyboardType;

  const SearchFieldConfig({
    required this.label,
    required this.apiKey,
    this.hint,
    this.icon = Icons.search,
    this.keyboardType = TextInputType.text,
  });
}

class DropdownFilterConfig<T> {
  final String label;
  final String apiKey;
  final IconData icon;
  final List<DropdownOption<T>> options;

  const DropdownFilterConfig({
    required this.label,
    required this.apiKey,
    this.icon = Icons.arrow_drop_down_circle_outlined,
    required this.options,
  });
}

class DropdownOption<T> {
  final String label;
  final T value;
  const DropdownOption({required this.label, required this.value});
}

//Checking Compkit
class ToggleFilterConfig {
  final String label;
  final String apiKey;
  final IconData icon;

  const ToggleFilterConfig({
    required this.label,
    required this.apiKey,
    this.icon = Icons.toggle_on_outlined,
  });
}

// ---------------------------------------------------------------------------
// Result model
// ---------------------------------------------------------------------------

class SearchFilterResult {
  final Map<String, String> textValues;
  final Map<String, dynamic> dropdownValues;
  final Map<String, bool?> toggleValues;

  const SearchFilterResult({
    this.textValues = const {},
    this.dropdownValues = const {},
    this.toggleValues = const {},
  });

  bool get isEmpty =>
      textValues.values.every((v) => v.isEmpty) &&
      dropdownValues.isEmpty &&
      toggleValues.values.every((v) => v == null);

  bool get hasAny => !isEmpty;

  int get activeCount {
    int count = 0;
    count += textValues.values.where((v) => v.isNotEmpty).length;
    count += dropdownValues.length;
    count += toggleValues.values.where((v) => v != null).length;
    return count;
  }

  SearchFilterResult copyWith({
    Map<String, String>? textValues,
    Map<String, dynamic>? dropdownValues,
    Map<String, bool?>? toggleValues,
  }) => SearchFilterResult(
    textValues: textValues ?? this.textValues,
    dropdownValues: dropdownValues ?? this.dropdownValues,
    toggleValues: toggleValues ?? this.toggleValues,
  );

  static SearchFilterResult empty() => const SearchFilterResult(
    textValues: {},
    dropdownValues: {},
    toggleValues: {},
  );
}

// ---------------------------------------------------------------------------
// Inline search bar + filter button
// ---------------------------------------------------------------------------

class CommonSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback onFilterTap;
  final VoidCallback? onClearTap;
  final int activeFilterCount;

  const CommonSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    required this.onFilterTap,
    this.onClearTap,
    this.activeFilterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isFiltered = activeFilterCount > 0;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onFilterTap,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFiltered
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : const Color(0xFFE2E8F0),
                  width: isFiltered ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 17,
                    color: isFiltered
                        ? AppColors.primary
                        : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hintText,
                      style: TextStyle(
                        fontSize: 13,
                        color: isFiltered
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFCBD5E1),
                        fontWeight: isFiltered
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (isFiltered)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onClearTap,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onFilterTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isFiltered ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFiltered ? AppColors.primary : const Color(0xFFE2E8F0),
              ),
              boxShadow: isFiltered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 15,
                  color: isFiltered ? Colors.white : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 5),
                Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isFiltered ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
                if (isFiltered) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 17,
                    height: 17,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$activeFilterCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bottom sheet
// ---------------------------------------------------------------------------

class CommonFilterSheet extends StatefulWidget {
  final List<SearchFieldConfig> searchFields;
  final List<DropdownFilterConfig> dropdownFilters;
  final List<ToggleFilterConfig> toggleFilters;
  final SearchFilterResult current;

  const CommonFilterSheet({
    super.key,
    this.searchFields = const [],
    this.dropdownFilters = const [],
    this.toggleFilters = const [],
    required this.current,
  });

  @override
  State<CommonFilterSheet> createState() => _CommonFilterSheetState();
}

class _CommonFilterSheetState extends State<CommonFilterSheet> {
  late Map<String, TextEditingController> _textControllers;
  late Map<String, dynamic> _dropdownValues;
  late Map<String, bool?> _toggleValues;
  bool _searchFieldsVisible = true;

  @override
  void initState() {
    super.initState();
    _textControllers = {
      for (final f in widget.searchFields)
        f.apiKey: TextEditingController(
          text: widget.current.textValues[f.apiKey] ?? '',
        ),
    };
    _dropdownValues = Map.from(widget.current.dropdownValues);
    _toggleValues = {
      for (final t in widget.toggleFilters)
        t.apiKey: widget.current.toggleValues[t.apiKey],
    };
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _activeCount {
    int count = 0;
    count += _textControllers.values
        .where((c) => c.text.trim().isNotEmpty)
        .length;
    count += _dropdownValues.values.where((v) => v != null).length;
    count += _toggleValues.values.where((v) => v != null).length;
    return count;
  }

  void _doApply() {
    final textValues = <String, String>{};
    for (final f in widget.searchFields) {
      final v = _textControllers[f.apiKey]?.text.trim() ?? '';
      if (v.isNotEmpty) textValues[f.apiKey] = v;
    }
    final dropdownValues = <String, dynamic>{};
    for (final entry in _dropdownValues.entries) {
      if (entry.value != null) dropdownValues[entry.key] = entry.value;
    }
    Navigator.pop(
      context,
      SearchFilterResult(
        textValues: textValues,
        dropdownValues: dropdownValues,
        toggleValues: Map.from(_toggleValues),
      ),
    );
  }

  void _doClear() => setState(() {
    for (final c in _textControllers.values) {
      c.clear();
    }
    _dropdownValues = {};
    _toggleValues = {for (final t in widget.toggleFilters) t.apiKey: null};
  });

  @override
  Widget build(BuildContext context) {
    final count = _activeCount;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                const Text(
                  'Search & Filter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (count > 0)
                  TextButton(
                    onPressed: _doClear,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: const Color(0xFF94A3B8),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Layer 1 — text fields
                  if (widget.searchFields.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _SectionHeader(
                            label: 'Search by text',
                            icon: Icons.search_rounded,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _searchFieldsVisible = !_searchFieldsVisible,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _searchFieldsVisible
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedRotation(
                                  turns: _searchFieldsVisible ? 0 : 0.5,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    size: 14,
                                    color: _searchFieldsVisible
                                        ? AppColors.primary
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _searchFieldsVisible ? 'Hide' : 'Show',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _searchFieldsVisible
                                        ? AppColors.primary
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _searchFieldsVisible
                          ? Column(
                              children: [
                                const SizedBox(height: 10),
                                _buildSearchFieldsList(),
                                const SizedBox(height: 20),
                              ],
                            )
                          : const SizedBox(height: 12),
                    ),
                  ],
                  // Layer 2 — dropdowns
                  if (widget.dropdownFilters.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Filter by',
                      icon: Icons.filter_list_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildDropdownsList(),
                    const SizedBox(height: 20),
                  ],
                  // Layer 3 — toggles
                  if (widget.toggleFilters.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Properties',
                      icon: Icons.tune_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildTogglesRow(),
                  ],
                ],
              ),
            ),
          ),
          // Sticky Apply button — always visible at the bottom
          Container(
            color: const Color(0xFFF8FAFC),
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 +
                  MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _doApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  count > 0 ? 'Apply  •  $count active' : 'Apply Filters',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Layer 1: label above + full-width input card per field ───────────────

  Widget _buildSearchFieldsList() {
    final fields = widget.searchFields;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _buildFieldRow(fields[i]),
        ],
      ],
    );
  }

  Widget _buildFieldRow(SearchFieldConfig field) {
    final controller = _textControllers[field.apiKey]!;

    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, v, _) {
        final hasValue = v.text.trim().isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label above the field
            Text(
              field.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            // Input box
            TextField(
              controller: controller,
              keyboardType: field.keyboardType,
              style: TextStyle(
                fontSize: 15,
                color: hasValue ? AppColors.primary : const Color(0xFF0F172A),
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText:
                    field.hint ?? 'Search ${field.label.toLowerCase()}...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFCBD5E1),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  field.icon,
                  size: 17,
                  color: hasValue ? AppColors.primary : const Color(0xFFCBD5E1),
                ),
                suffixIcon: hasValue
                    ? GestureDetector(
                        onTap: () {
                          controller.clear();
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.all(9),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: hasValue
                        ? AppColors.primary
                        : const Color(0xFFE2E8F0),
                    width: hasValue ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        );
      },
    );
  }

  // ── Layer 2: dropdowns ─────────────────────────────────────────────────────

  Widget _buildDropdownsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.dropdownFilters.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _DropdownTile(
            config: widget.dropdownFilters[i],
            value: _dropdownValues[widget.dropdownFilters[i].apiKey],
            onChanged: (v) => setState(() {
              if (v == null) {
                _dropdownValues.remove(widget.dropdownFilters[i].apiKey);
              } else {
                _dropdownValues[widget.dropdownFilters[i].apiKey] = v;
              }
            }),
          ),
        ],
      ],
    );
  }

  // ── Layer 3: toggle row ────────────────────────────────────────────────────

  Widget _buildTogglesRow() {
    final filters = widget.toggleFilters;
    final rows = <Widget>[];
    for (int i = 0; i < filters.length; i += 3) {
      final slice = filters.sublist(i, (i + 3).clamp(0, filters.length));
      rows.add(
        Row(
          children: [
            for (int j = 0; j < slice.length; j++) ...[
              if (j > 0) const SizedBox(width: 10),
              Expanded(
                child: _ToggleDropdown(
                  config: slice[j],
                  value: _toggleValues[slice[j].apiKey],
                  onChanged: (v) =>
                      setState(() => _toggleValues[slice[j].apiKey] = v),
                ),
              ),
            ],
            for (int k = slice.length; k < 3; k++) ...[
              const SizedBox(width: 10),
              const Expanded(child: SizedBox()),
            ],
          ],
        ),
      );
      if (i + 3 < filters.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Layer 2 — dropdown tile
// ---------------------------------------------------------------------------

class _DropdownTile extends StatelessWidget {
  final DropdownFilterConfig config;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _DropdownTile({
    required this.config,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final selectedLabel = hasValue
        ? config.options
              .cast<DropdownOption?>()
              .firstWhere((o) => o?.value == value, orElse: () => null)
              ?.label
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Text(
          config.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: hasValue ? AppColors.primary : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        // Dropdown box
        DropdownButtonFormField<dynamic>(
          initialValue: value,
          isExpanded: true,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: hasValue ? AppColors.primary : const Color(0xFFCBD5E1),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              config.icon,
              size: 17,
              color: hasValue ? AppColors.primary : const Color(0xFFCBD5E1),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 11,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasValue ? AppColors.primary : const Color(0xFFE2E8F0),
                width: hasValue ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          hint: Text(
            selectedLabel ?? 'Select ${config.label.toLowerCase()}...',
            style: TextStyle(
              fontSize: 14,
              color: hasValue ? AppColors.primary : const Color(0xFFCBD5E1),
              fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          items: [
            DropdownMenuItem<dynamic>(
              value: null,
              child: Text(
                'Any (clear)',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ),
            ...config.options.map(
              (o) => DropdownMenuItem<dynamic>(
                value: o.value,
                child: Text(o.label, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Layer 3 — bool toggle (Switch)
// ---------------------------------------------------------------------------

class _ToggleDropdown extends StatelessWidget {
  final ToggleFilterConfig config;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const _ToggleDropdown({
    required this.config,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = value == true;

    return GestureDetector(
      onTap: () => onChanged(isOn ? null : true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isOn ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isOn ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isOn ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  config.icon,
                  size: 12,
                  color: isOn ? AppColors.primary : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    config.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isOn ? AppColors.primary : const Color(0xFF64748B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 36,
                height: 22,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch(
                    value: isOn,
                    onChanged: (v) => onChanged(v ? true : null),
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper to open the sheet
// ---------------------------------------------------------------------------

Future<SearchFilterResult?> showCommonFilterSheet(
  BuildContext context, {
  required List<SearchFieldConfig> searchFields,
  required List<DropdownFilterConfig> dropdownFilters,
  required List<ToggleFilterConfig> toggleFilters,
  required SearchFilterResult current,
}) => showModalBottomSheet<SearchFilterResult>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  useSafeArea: true,
  builder: (context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.92,
    ),
    child: CommonFilterSheet(
      searchFields: searchFields,
      dropdownFilters: dropdownFilters,
      toggleFilters: toggleFilters,
      current: current,
    ),
  ),
);
