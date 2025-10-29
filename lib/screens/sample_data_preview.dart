import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../theme/theme_colors.dart';

class SampleDataPreview extends StatelessWidget {
  const SampleDataPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final loc = LocalizationService.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('settings.sample_data_preview', {'count': data.totalProductCount.toString()})),
        backgroundColor: ThemeColors.bg3,
      ),
      backgroundColor: ThemeColors.bg1,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Card(
              color: ThemeColors.bgCard,
              child: ListTile(
                title: Text('Depolar', style: const TextStyle(color: ThemeColors.textWhite)),
                subtitle: Text('${data.depots.length}'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: ThemeColors.bgCard,
              child: ListTile(
                title: Text('Çantalar', style: const TextStyle(color: ThemeColors.textWhite)),
                subtitle: Text('${data.bags.length}'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: ThemeColors.bgCard,
              child: ListTile(
                title: Text('Ürünler', style: const TextStyle(color: ThemeColors.textWhite)),
                subtitle: Text('${data.products.length}'),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Ürünler', style: TextStyle(color: ThemeColors.textGrey)),
            const SizedBox(height: 8),
            ...data.products.map((p) => Card(
                  color: ThemeColors.bgCard,
                  child: ListTile(
          leading: p.imagePath != null
            ? (p.imagePath!.startsWith('data:image')
              ? Image.memory(
                Uri.parse(p.imagePath!).data!.contentAsBytes(),
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                )
              : Image.asset(p.imagePath!, width: 44, height: 44, fit: BoxFit.cover))
            : null,
                    title: Text(p.name, style: const TextStyle(color: ThemeColors.textWhite)),
                    subtitle: Text('${p.stock} adet • ${p.daysRemaining} gün', style: const TextStyle(color: ThemeColors.textGrey)),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
