import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/consumable_service.dart';

class ConsumablesScreen extends StatefulWidget {
  const ConsumablesScreen({super.key});

  @override
  State<ConsumablesScreen> createState() => _ConsumablesScreenState();
}

class _ConsumablesScreenState extends State<ConsumablesScreen> {
  final ConsumableService _service = ConsumableService();
  late Future<List<dynamic>> _dataFull;

  @override
  void initState() {
    super.initState();
    _dataFull = _service.getConsumables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consommables'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFull,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2, color: AppColors.warning),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Consommable',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Patient: ${item['patient']}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Qté: ${item['quantity']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
