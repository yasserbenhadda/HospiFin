import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/dashboard_service.dart';
import '../../data/services/forecast_service.dart'; // Added
import '../widgets/custom_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  final ForecastService _forecastService = ForecastService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _summaryData;
  Map<String, dynamic>? _forecastData;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _dashboardService.getSummary(),
        _forecastService.getForecast(30),
      ]);
      
      if (mounted) {
        setState(() {
          _summaryData = results[0];
          _forecastData = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeader(
        title: 'Tableau de bord',
        subtitle: "Vue d'ensemble",
        showBackButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildControls(),
              const SizedBox(height: 24),
              
              if (_isLoading)
                 const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
              else if (_error != null)
                 _buildErrorState(_error!)
              else ...[
                _buildKpiGrid(_summaryData!),
                const SizedBox(height: 24),
                _buildChartsSection(), // No arguments, will access state fields directly or I can pass them
                const SizedBox(height: 24),
                _buildRecentStaysList(_summaryData!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  Widget _buildChartsSection() {
    return Column(
      children: [
        // --- CHART 1: LINE CHART (Predicted Cost) ---
        // --- CHART 1: LINE CHART (Predicted Cost) ---
        _buildChartContainer(
          title: "Coût prédit",
          subtitle: "Évolution sur 30 jours",
          child: (_forecastData != null && _forecastData!['globalHistory'] != null)
            ? LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.border, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        final history = _forecastData!['globalHistory'] as List; // Updated key
                        if (value.toInt() >= 0 && value.toInt() < history.length && value.toInt() % 5 == 0) {
                          final dateStr = history[value.toInt()]['month'] ?? '';
                          try {
                            final date = DateTime.parse(dateStr);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            );
                          } catch (e) {
                             return const SizedBox.shrink();
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                   touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => Colors.blueGrey,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                           return LineTooltipItem(
                             '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0).format(spot.y)}',
                             const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                           );
                        }).toList();
                      }
                   ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: (_forecastData!['globalHistory'] as List).asMap().entries.map((e) { // Updated key
                      return FlSpot(e.key.toDouble(), (e.value['predicted'] ?? 0).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: AppColors.secondary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.secondary.withOpacity(0.1)),
                  ),
                ],
              ),
            )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Données de prévision indisponibles", style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      "Debug Keys: ${_forecastData?.keys.toList().toString()}",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
        ),
          
        const SizedBox(height: 24),

        // --- CHART 2: BAR CHART (Cost by Service) ---
        _buildChartContainer(
          title: "Coût par service",
          subtitle: "Répartition par département",
          child: (_summaryData != null && _summaryData!['costByService'] != null)
            ? BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (_summaryData!['costByService'] as List).fold<double>(0, (max, e) => (e['value'] ?? 0) > max ? (e['value'] ?? 0).toDouble() : max) * 1.2,
                barTouchData: BarTouchData(
                   touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                         return BarTooltipItem(
                           '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0).format(rod.toY)}',
                           const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                         );
                      }
                   )
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final data = _summaryData!['costByService'] as List;
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          final name = data[value.toInt()]['name'] ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: 60,
                              child: Text(
                                name, 
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.border, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                barGroups: (_summaryData!['costByService'] as List).asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: (e.value['value'] ?? 0).toDouble(),
                        color: const Color(0xFF1E3A8A), // Dark Blue
                        width: 16,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      )
                    ],
                  );
                }).toList(),
              ),
            )
            : const Center(child: Text("Données de service indisponibles", style: TextStyle(color: AppColors.textSecondary))),
        ),
        const SizedBox(height: 24),

        // --- CHART 3: PIE CHART (Cost Distribution) ---
        _buildChartContainer(
          title: "Répartition des coûts",
          subtitle: "Par catégorie",
          child: (_summaryData != null && _summaryData!['costByCategory'] != null && (_summaryData!['costByCategory'] as List).isNotEmpty) 
            ? PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: (_summaryData!['costByCategory'] as List).asMap().entries.map((e) {
                     final index = e.key;
                     final data = e.value;
                     final colors = [const Color(0xFF1E3A8A), const Color(0xFF14B8A6), const Color(0xFF60A5FA), const Color(0xFFF97316)];
                     return PieChartSectionData(
                       color: colors[index % colors.length],
                       value: (data['value'] ?? 0).toDouble(),
                       title: '${(data['value'] ?? 0).toInt()}€',
                       radius: 50,
                       titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                     );
                  }).toList(),
                ),
              )
            : const Center(child: Text("Données non disponibles", style: TextStyle(color: AppColors.textSecondary))),
        ),
      ],
    );
  }

  Widget _buildChartContainer({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), offset: Offset(0, 1), blurRadius: 2)],
      ),
      height: 320,
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
           Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
           const SizedBox(height: 20),
           Expanded(child: child),
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
