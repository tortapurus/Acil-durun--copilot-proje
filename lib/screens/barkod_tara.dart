import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/localization_service.dart';
import '../theme/theme_colors.dart';

class BarkodTaraEkrani extends StatefulWidget {
  const BarkodTaraEkrani({super.key});

  @override
  State<BarkodTaraEkrani> createState() => _BarkodTaraEkraniState();
}

class _BarkodTaraEkraniState extends State<BarkodTaraEkrani> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _capturePhoto());
  }

  Future<void> _capturePhoto() async {
    if (_isProcessing || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (!mounted) {
        return;
      }

      if (image == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(
        '/yeni-urun',
        arguments: {
          'imagePath': image.path,
          'imageBytes': bytes,
        },
      );
    } on Exception {
      if (!mounted) {
        return;
      }

      final localization = context.read<LocalizationService>();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(localization.t('photoCapture.error')),
          ),
        );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, loc, _) {
        return Scaffold(
          backgroundColor: ThemeColors.bg1,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(
                Icons.close,
                color: ThemeColors.textWhite,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              loc.t('photoCapture.title'),
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ThemeColors.bg3,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ThemeColors.pastelGreen.withValues(alpha: 0.35),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: ThemeColors.pastelGreen.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          color: ThemeColors.pastelGreen,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.t('photoCapture.helper'),
                        style: const TextStyle(
                          color: ThemeColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loc.t('photoCapture.description'),
                        style: const TextStyle(
                          color: ThemeColors.textGrey,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_isProcessing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ThemeColors.pastelGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            loc.t('photoCapture.loading'),
                            style: const TextStyle(
                              color: ThemeColors.textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isProcessing ? null : _capturePhoto,
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: ThemeColors.textBlack,
                    ),
                    label: Text(
                      loc.t('photoCapture.button'),
                      style: const TextStyle(
                        color: ThemeColors.textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
