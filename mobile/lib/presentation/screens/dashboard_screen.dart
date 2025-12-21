import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _dashboardData = _dashboardService.getSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                
                FutureBuilder<Map<String, dynamic>>(
                  future: _dashboardData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    }

                    final data = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKpiGrid(data),
                        const SizedBox(height: 24),
                        _buildChartsSection(data),
                        const SizedBox(height: 24),
                        _buildRecentStaysList(data),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tableau de bord ...",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -1,
                fontFamily: 'Inter', 
              ),
            ),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                const CircleAvatar(
                  backgroundColor: AppColors.secondary, 
                  radius: 18,
                  child: Icon(Icons.person_outline, color: Colors.white, size: 20),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          "Vue d'ensemble",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Période du 1 au 30 novembre 2025",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
             _buildDropdownButton("30 jours"),
             const SizedBox(width: 12),
             _buildDropdownButton("Tous les service"),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Slightly gray bg
        borderRadius: BorderRadius.circular(12),
        // No border in screenshot, flat gray look
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Erreur de chargement', style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12)),
          const SizedBox(height: 8),
          const Text('Vérifiez que le backend tourne sur le port 8080.', style: TextStyle(color: Color(0xFF991B1B), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(Map<String, dynamic> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: 1, // Stack them vertically like the screenshot (Cards are wide)
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          childAspectRatio: 2.5, // Wide cards
          children: [
            _buildKpiCard(
              'Coût réel total',
              '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0).format(data['totalRealCost'] ?? 0)}',
              Icons.attach_money,
              const Color(0xFFEFF6FF),
              const Color(0xFF2563EB), // Blue Icon
              data['totalRealCostTrend'] ?? 0.0,
            ),
            _buildKpiCard(
              'Coût prédit total',
              '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0).format(data['totalPredictedCost'] ?? 0)}',
              Icons.trending_up,
              const Color(0xFFECFDF5),
              const Color(0xFF10B981), // Green Icon
               data['totalPredictedCostTrend'] ?? 0.0,
            ),
            _buildKpiCard(
              'Coût moyen par séjour',
              '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0).format(data['avgCostPerStay'] ?? 0)}',
              Icons.people_outline,
               const Color(0xFFEFF6FF),
              const Color(0xFF2563EB), // Blue Icon
              data['avgCostPerStayTrend'] ?? 0.0,
            ),
            _buildKpiCard(
              'Ratio coût personnel',
              '${(data['personnelCostRatio'] ?? 0).toStringAsFixed(0)}%',
              Icons.percent,
              const Color(0xFFFFF7ED),
              const Color(0xFFEA580C), // Orange Icon
               data['personnelCostRatioTrend'] ?? 0.0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color bgIcon, Color colorIcon, double trend) {
    final isPositive = trend >= 0;
    return Container(
      padding: const EdgeInsets.all(20), // More padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // More rounded
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgIcon,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorIcon, size: 22),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                 color: isPositive ? AppColors.secondary : AppColors.error, // Green for UP on Costs is actually BAD usually, but screenshot shows Green for UP on Profit/etc. Assuming standard financial logic: Green = Good. 
                 // Wait, screenshot shows "Cost Real" UP is Green? Let's look closer. 
                 // Screenshot: "Coût réel total 45k" (Green arrow UP 8.5%). 
                 // Usually Cost Up = Bad (Red). 
                 // But user wants "Same design". Screenshot shows Green Arrow Up. 
                 // I will follow the screenshot styling. Screenshot shows Green text/icon for positive percentages.
              ),
              const SizedBox(width: 4),
              Text(
                '${trend.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isPositive ? AppColors.secondary : AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
               const SizedBox(width: 4),
               const Text("vs période précédente", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(Map<String, dynamic> data) {
    // Placeholder for charts to keep it correct - in real implementation we map 'forecastData'
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), offset: Offset(0, 1), blurRadius: 2)],
      ),
      height: 300,
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text("Coût prédit (30 jours)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
           const SizedBox(height: 20),
           Expanded(
             child: LineChart(
               LineChartData(
                 gridData: FlGridData(
                   show: true,
                   drawVerticalLine: false,
                   getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.border, strokeWidth: 1),
                 ),
                 titlesData: FlTitlesData(
                   leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   bottomTitles: AxisTitles(
                     sideTitles: SideTitles(
                       showTitles: true,
                       interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          );
                        },
                     ),
                   ),
                 ),
                 borderData: FlBorderData(show: false),
                 lineBarsData: [
                   LineChartBarData(
                     spots: const [FlSpot(0, 20), FlSpot(5, 40), FlSpot(10, 30), FlSpot(20, 50), FlSpot(30, 45)], // Mocked for visuals
                     isCurved: true,
                     color: AppColors.secondary,
                     barWidth: 3,
                     dotData: const FlDotData(show: false),
                     belowBarData: BarAreaData(show: true, color: AppColors.secondary.withOpacity(0.1)),
                   ),
                 ],
               ),
             ),
           ),
         ],
      ),
    );
  }

  Widget _buildRecentStaysList(Map<String, dynamic> data) {
    final List<dynamic> recentStays = data['recentStays'] ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), offset: Offset(0, 1), blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text("Séjours récents", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                   Text("Dernières activités", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text("Voir tout"))
            ],
          ),
          const SizedBox(height: 16),
          if (recentStays.isEmpty) const Text("Aucun séjour récent."),
          ...recentStays.map((stay) => Column(
            children: [
              ListTile(
                 contentPadding: EdgeInsets.zero,
                 leading: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: AppColors.background,
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: AppColors.border),
                   ),
                   child: const Icon(Icons.event_note, color: AppColors.textSecondary, size: 20),
                 ),
                 title: Text(stay['patientName'] ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                 subtitle: Text(stay['department'] ?? 'Service', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                 trailing: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                     Text('${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0).format(stay['cost'] ?? 0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                       decoration: BoxDecoration(
                         color: stay['status'] == 'En cours' ? AppColors.primary : Colors.white,
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: stay['status'] == 'En cours' ? AppColors.primary : AppColors.border),
                       ),
                       child: Text(
                         stay['status'] ?? 'Statut', 
                         style: TextStyle(fontSize: 10, color: stay['status'] == 'En cours' ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold),
                       ),
                     ),
                   ],
                 ),
              ),
              const Divider(color: AppColors.background),
            ],
          )),
        ],
      ),
    );
  }
}
