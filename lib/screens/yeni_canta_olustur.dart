import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bag.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../theme/theme_colors.dart';

class YeniCantaOlustur extends StatefulWidget {
  const YeniCantaOlustur({super.key});

  @override
  State<YeniCantaOlustur> createState() => _YeniCantaOlusturState();

  // Static method to show as modal
  static Future<void> showModal(BuildContext context) async {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const YeniCantaOlustur(),
    );
  }
}

class _YeniCantaOlusturState extends State<YeniCantaOlustur> {
  late TextEditingController _bagNameController;
  late TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bagNameController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _bagNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, loc, child) {
        final bool isButtonEnabled =
            _bagNameController.text.trim().isNotEmpty && !_isSaving;

        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: const BoxDecoration(
            color: ThemeColors.bg1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button and title
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: ThemeColors.textWhite,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      loc.t('bag.create.title'),
                      style: const TextStyle(
                        color: ThemeColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 28),
                  ],
                ),

                const SizedBox(height: 40),

                // Bag name section
                Text(
                  loc.t('bag.create.name'),
                  style: const TextStyle(
                    color: ThemeColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Bag name input - Exact PNG styling with no borders
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _bagNameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: loc.t('bag.create.name_placeholder'),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Notes section
                Text(
                  loc.t('bag.create.notes'),
                  style: const TextStyle(
                    color: ThemeColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Notes input - Exact PNG styling with no borders
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _notesController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: loc.t('bag.create.notes_placeholder'),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          height: 1.4,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),

                const Spacer(),

                // Create button - Exact PNG styling with gradient
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isButtonEnabled
                          ? const [Color(0xFF8B5CF6), Color(0xFFBB6BD9)]
                          : const [Color(0xFF454545), Color(0xFF565656)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: isButtonEnabled ? () => _handleCreate(loc) : null,
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                loc.t('bag.create.button'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                // Safe area padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCreate(LocalizationService loc) {
    final String name = _bagNameController.text.trim();
    final String notes = _notesController.text.trim();

    if (name.isEmpty || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bag = Bag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      notes: notes.isEmpty ? null : notes,
      isEmergencyBag: true,
    );

    context.read<DataService>().addBag(bag);

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = false;
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            loc.t('bag.create.success', {'name': bag.name}),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: ThemeColors.pastelGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

    Navigator.pop(context, bag);
  }
}
