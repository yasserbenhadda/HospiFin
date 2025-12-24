import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../data/services/forecast_service.dart';
import '../widgets/custom_header.dart';
import 'package:intl/intl.dart';

class PrevisionsScreen extends StatefulWidget {
  const PrevisionsScreen({super.key});

  @override
  State<PrevisionsScreen> createState() => _PrevisionsScreenState();
}

class _PrevisionsScreenState extends State<PrevisionsScreen> {
  final ForecastService _forecastService = ForecastService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);

  bool _isLoading = true;
  double _totalPredictedCost = 0;
  
  // Data for the 3 Categories matching Web App
  Map<String, dynamic> _medicalActsData = {};
  Map<String, dynamic> _consumablesData = {};
  Map<String, dynamic> _staysData = {};

  // Chart Data
  List<FlSpot> _spots = [];
  List<String> _xAxisLabels = [];
  double _minY = 0;
  double _maxY = 10000;
  
  int _selectedPeriod = 60; // Default to 60 days to match Web Screenshot

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _forecastService.getForecast(_selectedPeriod);
      
      // 1. Global Totals
      double predictedTotal = (data['globalPrediction'] as num?)?.toDouble() ?? 0.0;
      
      // 2. Categories Data
      _medicalActsData = data['medicalActs'] ?? {};
      _consumablesData = data['consumables'] ?? {};
      _staysData = data['stays'] ?? {};

      // 3. Global History for Chart
      final List<dynamic> history = data['globalHistory'] ?? [];
      
      List<FlSpot> spots = [];
      List<String> labels = [];
      
      double minVal = double.maxFinite;
      double maxVal = double.minPositive;

      // Show all points returned by backend for the selected period
      int count = history.length;
      
      for (int i = 0; i < count; i++) {
        final point = history[i];
        
        // Priority: 'real' > 'predicted' > 'cost'
        double val = 0.0;
        if (point.containsKey('real') && point['real'] != null) {
          val = (point['real'] as num).toDouble();
        } else if (point.containsKey('predicted') && point['predicted'] != null) {
          val = (point['predicted'] as num).toDouble();
        }

        if (val < minVal) minVal = val;
        if (val > maxVal) maxVal = val;
        
        spots.add(FlSpot(i.toDouble(), val));
        
        // Label
        String label = point['month'] ?? "";
        // Try parsing ISO date
        try {
          DateTime d = DateTime.parse(label); 
          label = "${d.day}/${d.month}";
        } catch (_) { }
        labels.add(label);
      }

      // Auto-scale
      if (minVal == double.maxFinite) {
        minVal = 0;
        maxVal = 1000;
      }
      
      // Add padding
      double range = maxVal - minVal;
      if (range == 0) range = 100;
      double chartMin = minVal - (range * 0.1);
      double chartMax = maxVal + (range * 0.1);
      
      setState(() {
        _totalPredictedCost = predictedTotal;
        _spots = spots;
        _xAxisLabels = labels;
        _minY = chartMin > 0 ? chartMin : 0;
        _maxY = chartMax;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading previsions: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  void _onPeriodChanged(int days) {
    if (_selectedPeriod == days) return;
    setState(() {
      _selectedPeriod = days;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Impossible de récupérer les prévisions.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$_errorMessage',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.red[300], fontSize: 12),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5F78),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: const CustomHeader(
        title: 'Prévisions financières',
        subtitle: 'Tableau de bord de gestion hospitalière',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Prévisions des coûts", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Anticipez les dépenses futures", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
            
            const SizedBox(height: 20),
            
            // Period Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _buildPeriodButton("30 jours", 30),
                  _buildPeriodButton("60 jours", 60),
                  _buildPeriodButton("90 jours", 90),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main Card (Total)
            _buildMainForecastCard(),
            const SizedBox(height: 20),

            // Chart
            _buildChartCard(),
            const SizedBox(height: 20),

            // Categories List
            Text("Prévisions par service", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            if (_medicalActsData.isEmpty && _consumablesData.isEmpty && _staysData.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Aucune donnée disponible", style: GoogleFonts.inter(color: Colors.grey)),
              ))
            else ...[
               _buildCategoryRow("Actes Médicaux", _medicalActsData),
               _buildCategoryRow("Consommables", _consumablesData),
               _buildCategoryRow("Séjours", _staysData),
            ],
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String text, int days) {
    bool isSelected = _selectedPeriod == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onPeriodChanged(days),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(text, 
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : Colors.black, 
              fontWeight: FontWeight.w600,
              fontSize: 12
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainForecastCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C5F78), Color(0xFF2C9F88)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fingerprint, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text("Prévision totale ($_selectedPeriod jours)", style: GoogleFonts.inter(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_currencyFormat.format(_totalPredictedCost), style: GoogleFonts.inter(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    if (_spots.isEmpty) {
      return Container(
         height: 200,
         width: double.infinity,
         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
         child: Center(child: Text("Aucune donnée graphique disponible", style: GoogleFonts.inter(color: Colors.grey)))
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Projection des coûts futurs", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Évolution prévue", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[100]!, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, 
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) => Text(
                        _formatYAxis(value),
                        style: const TextStyle(fontSize: 10, color: Colors.grey)
                      )
                    )
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _spots.length > 10 ? (_spots.length / 5).toDouble() : 1, // Dynamic interval
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < _xAxisLabels.length) {
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text(_xAxisLabels[index], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                           );
                        }
                        return const Text("");
                      }
                    )
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: math.max(0, _spots.length.toDouble() - 1),
                minY: _minY,
                maxY: _maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    curveSmoothness: 0.25,
                    color: const Color(0xFF2C5F78),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true, 
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2C5F78).withOpacity(0.2),
                          const Color(0xFF2C5F78).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                   touchTooltipData: LineTouchTooltipData(
                     getTooltipColor: (spot) => Colors.blueGrey,
                     getTooltipItems: (touchedSpots) {
                       return touchedSpots.map((spot) {
                         return LineTooltipItem(
                           _currencyFormat.format(spot.y),
                           const TextStyle(color: Colors.white),
                         );
                       }).toList();
                     }
                   )
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatYAxis(double value) {
    if (value >= 1000) return "${(value / 1000).toStringAsFixed(1)}k";
    return value.toInt().toString();
  }

  Widget _buildCategoryRow(String title, Map<String, dynamic> data) {
    // FIX: Calculate Real Total from history (Period specific) instead of 'currentTotal' (All-time)
    double real = 0.0;
    if (data['history'] != null) {
      for (var point in data['history']) {
        if (point['real'] != null) {
          real += (point['real'] as num).toDouble();
        }
      }
    }
    
    double predicted = (data['predictedTotal'] as num?)?.toDouble() ?? 0.0;
    
    double percentChange = 0;
    if (real > 0) {
      percentChange = ((predicted - real) / real) * 100;
    } else if (predicted > 0) {
      percentChange = 100;
    }
    
    // Financial logic: Negative % is savings (Good/Green), Positive % is Cost Increase (Bad/Red)
    bool isSaving = percentChange <= 0;
    Color percentColor = isSaving ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: percentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${percentChange > 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%",
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _buildStatItem("Total Réel ($_selectedPeriod j)", real),
               _buildStatItem("Prévu", predicted),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, double val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(_currencyFormat.format(val), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2C3E50))),
      ],
    );
  }
}
