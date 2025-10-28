import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/app_bottom_navigation.dart';

enum _DateFieldType { expiry, reminder }

class YeniUrunEkle extends StatefulWidget {
  const YeniUrunEkle({
    super.key,
    this.initialImagePath,
    this.initialImageBytes,
    this.initialProduct,
  });

  final String? initialImagePath;
  final Uint8List? initialImageBytes;
  final Product? initialProduct;

  @override
  State<YeniUrunEkle> createState() => _YeniUrunEkleState();
}

class _YeniUrunEkleState extends State<YeniUrunEkle> {
  static const String _addCategoryValue = '__add_category__';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey<FormFieldState<String>> _categoryFieldKey =
    GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _locationFieldKey =
    GlobalKey<FormFieldState<String>>();

  late TextEditingController _productNameController;
  late TextEditingController _notesController;
  late TextEditingController _locationController;
  late TextEditingController _expiryDateController;
  late TextEditingController _reminderDateController;

  String? _selectedCategoryId;
  DateTime? _expiryDate;
  DateTime? _reminderDate;
  String? _imagePath;
  Uint8List? _imageBytes;
  bool _isSaving = false;
  String? _selectedLocationId;
  StorageLocationType? _selectedLocationType;
  late final Product? _editingProduct;

  bool get _isEditingProduct => _editingProduct != null;

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController();
    _notesController = TextEditingController();
    _locationController = TextEditingController();
    _expiryDateController = TextEditingController();
    _reminderDateController = TextEditingController();
    _imagePath = widget.initialImagePath;
    _imageBytes = widget.initialImageBytes;
    _editingProduct = widget.initialProduct;

    final Product? editing = _editingProduct;

    if (editing != null) {
      _productNameController.text = editing.name;
      _notesController.text = editing.notes ?? '';
      _locationController.text = editing.location ?? '';
      _expiryDate = editing.expiryDate;
      _reminderDate = editing.reminderDate;
      _expiryDateController.text = _formatDate(editing.expiryDate);
      _reminderDateController.text = _formatDate(editing.reminderDate);
  _selectedCategoryId = editing.categoryId;
      _selectedLocationId = editing.storageId;
      _selectedLocationType = editing.storageType;
      _imagePath = editing.imagePath ?? _imagePath;
      _imageBytes = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_selectedCategoryId != null) {
          _categoryFieldKey.currentState?.didChange(_selectedCategoryId);
        }
        if (_selectedLocationId != null) {
          _locationFieldKey.currentState?.didChange(_selectedLocationId);
        }
      });
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _expiryDateController.dispose();
    _reminderDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocalizationService, DataService>(
      builder: (context, loc, data, child) {
        final List<Category> categories = List<Category>.from(data.allCategories)
          ..sort(
            (a, b) => _categoryLabel(a, loc)
                .toLowerCase()
                .compareTo(_categoryLabel(b, loc).toLowerCase()),
          );

        final List<_LocationOption> bagOptions = data.bags
            .map(
              (bag) => _LocationOption(
                id: bag.id,
                type: StorageLocationType.bag,
                label: bag.name,
                detail: loc.t(
                  'newProduct.storage.sheet.itemCount',
                  {'count': bag.productIds.length.toString()},
                ),
                icon: Icons.backpack_outlined,
              ),
            )
            .toList();

        final List<_LocationOption> depotOptions = data.depots
            .map(
              (depot) => _LocationOption(
                id: depot.id,
                type: StorageLocationType.depot,
                label: depot.name,
                detail: loc.t(
                  'newProduct.storage.sheet.itemCount',
                  {'count': depot.productIds.length.toString()},
                ),
                icon: Icons.inventory_2_outlined,
              ),
            )
            .toList();

        _syncLocationSelection(bagOptions, depotOptions);

        if (categories.isNotEmpty &&
            (_selectedCategoryId == null ||
                !categories.any((cat) => cat.id == _selectedCategoryId))) {
          final fallback = categories.first.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _categoryFieldKey.currentState?.didChange(fallback);
            setState(() => _selectedCategoryId = fallback);
          });
        }

        return Scaffold(
          backgroundColor: ThemeColors.bg2,
          body: SafeArea(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: loc.t('common.back'),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: ThemeColors.textWhite,
                            size: 22,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.t(
                              _isEditingProduct
                                  ? 'newProduct.edit.title'
                                  : 'newProduct.pageTitle',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: ThemeColors.textWhite,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _LabeledField(
                      label: loc.t('newProduct.name.label'),
                      child: TextFormField(
                        controller: _productNameController,
                        style: const TextStyle(color: ThemeColors.textWhite),
                        decoration: _buildInputDecoration(
                          hintText: loc.t('newProduct.name.hint'),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            _validateRequiredField(value, loc),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _LabeledField(
                      label: loc.t('newProduct.category.label'),
                      child: DropdownButtonFormField<String>(
                        key: _categoryFieldKey,
                        initialValue: _selectedCategoryId,
                        dropdownColor: ThemeColors.bgCardDark,
                        style: const TextStyle(color: ThemeColors.textWhite),
                        decoration: _buildInputDecoration(),
                        iconEnabledColor: ThemeColors.pastelGreen,
                        items: [
                          ...categories.map(
                            (category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(_categoryLabel(category, loc)),
                            ),
                          ),
                          DropdownMenuItem(
                            value: _addCategoryValue,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: ThemeColors.pastelGreen,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  loc.t('categories.addNew'),
                                  style: const TextStyle(
                                    color: ThemeColors.pastelGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        validator: (value) =>
                            value == null ? loc.t('form.error.required') : null,
                        onChanged: (value) async {
                          if (value == null) return;
                          if (value == _addCategoryValue) {
                            final Category? created =
                                await _promptAddCategory(context, loc, data);
                            if (created != null) {
                              _categoryFieldKey.currentState
                                  ?.didChange(created.id);
                              setState(() => _selectedCategoryId = created.id);
                            }
                          } else {
                            _categoryFieldKey.currentState?.didChange(value);
                            setState(() => _selectedCategoryId = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _LabeledField(
                      label: loc.t('newProduct.expiry.label'),
                      child: TextFormField(
                        controller: _expiryDateController,
                        readOnly: true,
                        showCursor: false,
                        decoration: _buildInputDecoration(
                          hintText: loc.t('newProduct.expiry.placeholder'),
                          suffixIcon: Icons.calendar_today,
                        ),
                        onTap: () => _selectDate(context, loc, _DateFieldType.expiry),
                        validator: (_) {
                          if (_expiryDate == null) {
                            return loc.t('form.error.required');
                          }
                          if (_expiryDate!.isBefore(_startOfToday())) {
                            return loc.t('form.error.datePast');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _LabeledField(
                      label: loc.t('newProduct.reminder.label'),
                      child: TextFormField(
                        controller: _reminderDateController,
                        readOnly: true,
                        showCursor: false,
                        decoration: _buildInputDecoration(
                          hintText: loc.t('newProduct.reminder.placeholder'),
                          suffixIcon: Icons.alarm,
                        ),
                        onTap: () =>
                            _selectDate(context, loc, _DateFieldType.reminder),
                        validator: (_) {
                          if (_reminderDate == null) {
                            return loc.t('form.error.required');
                          }
                          if (_reminderDate!.isBefore(_startOfToday())) {
                            return loc.t('form.error.datePast');
                          }
                          if (_expiryDate != null &&
                              _reminderDate!.isAfter(_expiryDate!)) {
                            return loc.t('form.error.reminderAfterExpiry');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _LabeledField(
                      label: loc.t('newProduct.storage.label'),
                      child: FormField<String>(
                        key: _locationFieldKey,
                        initialValue: _selectedLocationId,
                        validator: (_) {
                          final bool hasOptions =
                              bagOptions.isNotEmpty || depotOptions.isNotEmpty;
                          if (!hasOptions) {
                            return null;
                          }
                          if (_selectedLocationId == null ||
                              _selectedLocationType == null) {
                            return loc.t('newProduct.storage.error');
                          }
                          return null;
                        },
                        builder: (field) {
                          final bool hasValue = _selectedLocationId != null &&
                              _selectedLocationType != null;
                          final String labelText =
                              _selectedLocationLabel(loc, data);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: (bagOptions.isNotEmpty ||
                                        depotOptions.isNotEmpty)
                                    ? () => _openLocationSheet(
                                          context,
                                          loc,
                                          data,
                                          bagOptions,
                                          depotOptions,
                                        )
                                    : null,
                                child: _PickerTile(
                                  label: labelText,
                                  isPlaceholder: !hasValue,
                                  enabled: bagOptions.isNotEmpty ||
                                      depotOptions.isNotEmpty,
                                ),
                              ),
                              if (bagOptions.isEmpty &&
                                  depotOptions.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    loc.t('newProduct.storage.sheet.empty'),
                                    style: const TextStyle(
                                      color: ThemeColors.textGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (field.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    field.errorText ?? '',
                                    style: const TextStyle(
                                      color: ThemeColors.pastelRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _LabeledField(
                      label: loc.t('location.note'),
                      child: TextFormField(
                        controller: _locationController,
                        style: const TextStyle(color: ThemeColors.textWhite),
                        decoration: _buildInputDecoration(
                          hintText: loc.t('newProduct.location.hint'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _LabeledField(
                      label: loc.t('newProduct.notes.label'),
                      child: TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        style: const TextStyle(color: ThemeColors.textWhite),
                        decoration: _buildInputDecoration(
                          hintText: loc.t('newProduct.notes.hint'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _LabeledField(
                      label: loc.t('newProduct.image.label'),
                      child: _buildImagePicker(context, loc),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSaving
                            ? null
                            : () => _saveProduct(context, loc, data),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeColors.textBlack,
                                  ),
                                ),
                              )
                            : Text(
                                loc.t(
                                  _isEditingProduct
                                      ? 'common.update'
                                      : 'save',
                                ),
                                style: const TextStyle(
                                  color: ThemeColors.textBlack,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar:
              const AppBottomNavigation(current: AppNavItem.products),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration({
    String? hintText,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: ThemeColors.textGrey),
      filled: true,
      fillColor: ThemeColors.bgCardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(
        color: ThemeColors.pastelRed,
        fontSize: 12,
      ),
      suffixIcon: suffixIcon == null
          ? null
          : Icon(suffixIcon, color: ThemeColors.pastelGreen, size: 20),
    );
  }

  String _categoryLabel(Category category, LocalizationService loc) {
    if (category.translationKey != null) {
      return loc.t(category.translationKey!);
    }
    return category.name;
  }

  String? _validateRequiredField(String? value, LocalizationService loc) {
    if (value == null || value.trim().isEmpty) {
      return loc.t('form.error.required');
    }
    return null;
  }

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _selectDate(
    BuildContext context,
    LocalizationService loc,
    _DateFieldType type,
  ) async {
    FocusScope.of(context).unfocus();
    final DateTime initial = type == _DateFieldType.expiry
        ? (_expiryDate ?? DateTime.now())
        : (_reminderDate ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ThemeColors.primaryGreen,
              surface: ThemeColors.bg3,
              onSurface: ThemeColors.textWhite,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: ThemeColors.bg2,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (type == _DateFieldType.expiry) {
        _expiryDate = picked;
        _expiryDateController.text = _formatDate(picked);
        if (_reminderDate != null && _reminderDate!.isAfter(picked)) {
          _reminderDate = null;
          _reminderDateController.clear();
        }
      } else {
        _reminderDate = picked;
        _reminderDateController.text = _formatDate(picked);
      }
    });
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day.$month.$year';
  }

  void _syncLocationSelection(
    List<_LocationOption> bagOptions,
    List<_LocationOption> depotOptions,
  ) {
    final List<_LocationOption> allOptions = [
      ...bagOptions,
      ...depotOptions,
    ];

    if (allOptions.isEmpty) {
      if (_selectedLocationId != null || _selectedLocationType != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _selectedLocationId = null;
            _selectedLocationType = null;
          });
          _locationFieldKey.currentState?.didChange(null);
        });
      }
      return;
    }

    final bool selectionStillValid = allOptions.any(
      (option) =>
          option.id == _selectedLocationId &&
          option.type == _selectedLocationType,
    );

    if (!selectionStillValid) {
      final _LocationOption first = allOptions.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedLocationId = first.id;
          _selectedLocationType = first.type;
        });
        _locationFieldKey.currentState?.didChange(first.id);
      });
    }
  }

  String _selectedLocationLabel(
    LocalizationService loc,
    DataService data,
  ) {
    if (_selectedLocationId == null || _selectedLocationType == null) {
      return loc.t('newProduct.storage.placeholder');
    }

    switch (_selectedLocationType!) {
      case StorageLocationType.bag:
        final bag = data.getBagById(_selectedLocationId!);
        if (bag == null) {
          return loc.t('newProduct.storage.placeholder');
        }
        return loc.t('newProduct.storage.selected', {
          'type': loc.t('newProduct.storage.type.bag'),
          'name': bag.name,
        });
      case StorageLocationType.depot:
        final depot = data.getDepotById(_selectedLocationId!);
        if (depot == null) {
          return loc.t('newProduct.storage.placeholder');
        }
        return loc.t('newProduct.storage.selected', {
          'type': loc.t('newProduct.storage.type.depot'),
          'name': depot.name,
        });
    }
  }

  void _openLocationSheet(
    BuildContext context,
    LocalizationService loc,
    DataService data,
    List<_LocationOption> bagOptions,
    List<_LocationOption> depotOptions,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ThemeColors.bg3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final List<Widget> items = <Widget>[];

        void addSection(String title, List<_LocationOption> options) {
          if (options.isEmpty) return;
          items.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                title,
                style: const TextStyle(
                  color: ThemeColors.textGrey,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          );

          for (final option in options) {
            items.add(
              _LocationListTile(
                option: option,
                isSelected: _isOptionSelected(option),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedLocationId = option.id;
                    _selectedLocationType = option.type;
                  });
                  _locationFieldKey.currentState?.didChange(option.id);
                },
              ),
            );
          }
        }

        addSection(loc.t('newProduct.storage.sheet.bags'), bagOptions);
        addSection(loc.t('newProduct.storage.sheet.depots'), depotOptions);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          loc.t('newProduct.storage.sheet.title'),
                          style: const TextStyle(
                            color: ThemeColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: ThemeColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Text(
                      loc.t('newProduct.storage.sheet.empty'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ThemeColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.55,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) => items[index],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isOptionSelected(_LocationOption option) {
    return option.id == _selectedLocationId &&
        option.type == _selectedLocationType;
  }

  Widget _buildImagePicker(BuildContext context, LocalizationService loc) {
    final bool hasImage = _imageBytes != null ||
        (_imagePath != null && File(_imagePath!).existsSync());

    return InkWell(
      onTap: () => _showImageOptions(context, loc),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ThemeColors.pastelGreen.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment:
              hasImage ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            if (_imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  _imageBytes!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else if (_imagePath != null && File(_imagePath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(
                Icons.add_a_photo_outlined,
                color: ThemeColors.pastelGreen,
                size: 48,
              ),
            const SizedBox(height: 16),
            Text(
              hasImage
                  ? loc.t('newProduct.image.captured')
                  : loc.t('newProduct.image.helper'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (hasImage && _imagePath != null && _imagePath!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _imagePath!.split(RegExp(r'[\\/]')).last,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ThemeColors.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showImageOptions(
    BuildContext context,
    LocalizationService loc,
  ) async {
    FocusScope.of(context).unfocus();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: ThemeColors.bg3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.t('newProduct.image.actions.title'),
                        style: const TextStyle(
                          color: ThemeColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: ThemeColors.textGrey),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: ThemeColors.pastelGreen),
                title: Text(
                  loc.t('newProduct.image.actions.camera'),
                  style: const TextStyle(color: ThemeColors.textWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, loc);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: ThemeColors.pastelGreen),
                title: Text(
                  loc.t('newProduct.image.actions.gallery'),
                  style: const TextStyle(color: ThemeColors.textWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, loc);
                },
              ),
              if (_imageBytes != null ||
                  (_imagePath != null && _imagePath!.isNotEmpty))
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: ThemeColors.pastelRed),
                  title: Text(
                    loc.t('newProduct.image.actions.remove'),
                    style: const TextStyle(color: ThemeColors.pastelRed),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, LocalizationService loc) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;

      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imagePath = file.path;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('photoCapture.error')),
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imagePath = null;
    });
  }

  Future<Category?> _promptAddCategory(
    BuildContext context,
    LocalizationService loc,
    DataService data,
  ) async {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<Category>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeColors.bg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            loc.t('newProduct.category.custom.title'),
            style: const TextStyle(color: ThemeColors.textWhite),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: ThemeColors.textWhite),
              decoration: _buildInputDecoration(
                hintText: loc.t('newProduct.category.custom.hint'),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return loc.t('newProduct.category.custom.error.length');
                }
                final exists = data.allCategories.any(
                  (category) =>
                      category.name.toLowerCase() == value.trim().toLowerCase(),
                );
                if (exists) {
                  return loc.t('newProduct.category.custom.error.duplicate');
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.t('common.cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final String name = controller.text.trim();
                final category = Category(
                  id: name.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
                  name: name,
                  isCustom: true,
                );
                data.addCustomCategory(category);
                Navigator.pop(context, category);
              },
              child: Text(loc.t('newProduct.category.custom.create')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProduct(
    BuildContext context,
    LocalizationService loc,
    DataService data,
  ) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final bool isEditing = _isEditingProduct;
    final String? categoryId = _selectedCategoryId;
    if (categoryId == null) {
      setState(() => _isSaving = false);
      return;
    }
    final String productId = isEditing
        ? _editingProduct!.id
        : DateTime.now().millisecondsSinceEpoch.toString();

    final product = Product(
      id: productId,
      name: _productNameController.text.trim(),
      categoryId: categoryId,
      expiryDate: _expiryDate!,
      reminderDate: _reminderDate!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      imagePath: _imagePath,
      storageId: _selectedLocationId,
      storageType: _selectedLocationType,
      stock: _editingProduct?.stock ?? 1,
      isChecked: _editingProduct?.isChecked ?? false,
      createdAt: _editingProduct?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      data.updateProduct(product);
    } else {
      data.addProduct(product);
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    Navigator.of(context).pop(product.id);
  }

}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ThemeColors.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _LocationOption {
  const _LocationOption({
    required this.id,
    required this.type,
    required this.label,
    this.detail,
    required this.icon,
  });

  final String id;
  final StorageLocationType type;
  final String label;
  final String? detail;
  final IconData icon;
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.isPlaceholder,
    required this.enabled,
  });

  final String label;
  final bool isPlaceholder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isPlaceholder
        ? ThemeColors.textGrey
        : ThemeColors.textWhite;
    final Color borderColor = enabled
        ? ThemeColors.pastelGreen.withValues(alpha: 0.45)
        : ThemeColors.textGrey.withValues(alpha: 0.3);
    final Color iconColor = enabled
        ? ThemeColors.pastelGreen
        : ThemeColors.textGrey.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ThemeColors.bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: iconColor,
          ),
        ],
      ),
    );
  }
}

class _LocationListTile extends StatelessWidget {
  const _LocationListTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _LocationOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isSelected
            ? ThemeColors.bgCard.withValues(alpha: 0.6)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  option.icon,
                  color: isSelected
                      ? ThemeColors.pastelGreen
                      : ThemeColors.textGrey.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: const TextStyle(
                          color: ThemeColors.textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (option.detail != null && option.detail!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            option.detail!,
                            style: const TextStyle(
                              color: ThemeColors.textGrey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: isSelected ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(
                    Icons.check_circle,
                    color: ThemeColors.pastelGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
