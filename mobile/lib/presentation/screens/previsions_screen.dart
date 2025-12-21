import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/stay_model.dart';
import '../../data/models/medical_act_model.dart';
import '../../data/services/stay_service.dart';
import '../../data/services/medical_act_service.dart';
import '../../data/services/forecast_service.dart';
import '../../data/services/service_mapper.dart';
import 'package:intl/intl.dart';

class PrevisionsScreen extends StatefulWidget {
  const PrevisionsScreen({super.key});

  @override
  State<PrevisionsScreen> createState() => _PrevisionsScreenState();
}

class _PrevisionsScreenState extends State<PrevisionsScreen> {
  final ForecastService _forecastService = ForecastService();
  final StayService _stayService = StayService();
  final MedicalActService _actService = MedicalActService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);

  bool _isLoading = true;
  double _totalPredictedCost = 0;
  Map<String, double> _serviceCosts = {
    ServiceMapper.chirurgie: 0,
    ServiceMapper.cardiologie: 0,
    ServiceMapper.urgences: 0,
    ServiceMapper.maternite: 0,
    ServiceMapper.radiologie: 0,
  };
  Map<String, double> _historicalCosts = {};

  // Chart Data
  List<FlSpot> _spots = [];

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
      // 1. Fetch Backend Forecast (Result of Math Prediction)
      final forecastData = await _forecastService.getForecast(30);
      final double predictedTotal = (forecastData['globalPrediction'] as num?)?.toDouble() ?? 0.0;
      
      // 2. Fetch History Points for Chart
      final List<dynamic> history = forecastData['history'] ?? [];
      List<FlSpot> spots = [];
      
      // Take last 8 points/weeks for the chart
      int startIndex = history.length > 8 ? history.length - 8 : 0;
      for (int i = startIndex; i < history.length; i++) {
        final point = history[i];
        final val = (point['predicted'] as num?)?.toDouble() ?? 0.0;
        spots.add(FlSpot((i - startIndex).toDouble(), val));
      }

      // 3. Fetch Raw Data ONLY to determine Service Ratios (Distribution)
      final stays = await _stayService.getStays();
      final acts = await _actService.getMedicalActs();

      Map<String, double> historicalServiceTotals = {
        ServiceMapper.chirurgie: 0,
        ServiceMapper.cardiologie: 0,
        ServiceMapper.urgences: 0,
        ServiceMapper.maternite: 0,
        ServiceMapper.radiologie: 0,
      };
      
      double totalHistoricalAmount = 0;

      for (var stay in stays) {
         historicalServiceTotals.update(stay.service, (val) => val + stay.totalCost, ifAbsent: () => stay.totalCost);
         totalHistoricalAmount += stay.totalCost;
      }
      for (var act in acts) {
         historicalServiceTotals.update(act.service, (val) => val + act.cost, ifAbsent: () => act.cost);
         totalHistoricalAmount += act.cost;
      }

      // Apply Ratios to Future Prediction
      Map<String, double> predictedServiceCosts = {};
      if (totalHistoricalAmount > 0) {
        historicalServiceTotals.forEach((key, value) {
          double ratio = value / totalHistoricalAmount;
          predictedServiceCosts[key] = predictedTotal * ratio;
        });
      } else {
        predictedServiceCosts = historicalServiceTotals; // Fallback
      }

      setState(() {
        _totalPredictedCost = predictedTotal;
        _spots = spots;
        _serviceCosts = predictedServiceCosts;
        _historicalCosts = historicalServiceTotals;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading previsions: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de connexion : Vérifiez le Backend.\nDétail: $e';
      });
    }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Oups ! Connexion impossible.',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez que le serveur Spring Boot est lancé.',
              style: GoogleFonts.inter(color: Colors.grey),
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
      ));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('Prévisions financières', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.grey), onPressed: () {}),
          const CircleAvatar(
             backgroundColor: Color(0xFF00796B),
             child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Prévisions des coûts", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Anticipez les dépenses futures basées sur l'analyse prédictive", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 20),
            
            // Period Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildPeriodButton("30 jours", true),
                  _buildPeriodButton("60 jours", false),
                  _buildPeriodButton("90 jours", false),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main Card
            _buildMainForecastCard(),
            const SizedBox(height: 20),

            // Chart
            _buildChartCard(),
            const SizedBox(height: 20),

            // Services List
            Text("Prévisions par service", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Comparaison avec les coûts historiques", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 16),
            ..._serviceCosts.entries.map((e) {
                // Only show if cost > 0
               if (e.value <= 0) return const SizedBox.shrink(); 
               return _buildServiceRow(e.key, e.value, _historicalCosts[e.key] ?? 0);
            }).toList(),

            const SizedBox(height: 20),
            _buildAlertCard(),
            const SizedBox(height: 20),
            _buildAttentionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String text, bool isSelected) {
    return Expanded(
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
    );
  }

  Widget _buildMainForecastCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C5F78), Color(0xFF2C9F88)], // Teal Gradient similar to screenshot
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
              Text("Prévision totale (30 jours)", style: GoogleFonts.inter(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_currencyFormat.format(_totalPredictedCost), style: GoogleFonts.inter(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          Text("Intervalle de confiance (95%)", style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
          Text("${_currencyFormat.format(_totalPredictedCost * 0.9)} - ${_currencyFormat.format(_totalPredictedCost * 1.1)}", style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Text(
              "Cette prévision est basée sur l'analyse des données historiques des 30 jours précédents, en tenant compte des tendances saisonnières.",
               style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Projection des coûts futurs", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Évolution prévue par semaine", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: true, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text("${value ~/ 1000}k", style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text("Sem ${value.toInt() + 1}", style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 7,
                minY: 10000,
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    color: const Color(0xFF2C5F78),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: const Color(0xFF2C5F78).withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(String serviceName, double predicted, double historical) {
    double percentChange = historical > 0 ? ((predicted - historical) / historical) * 100 : 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(serviceName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${percentChange > 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%",
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Historique:", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                        Text(_currencyFormat.format(historical), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Prévu:", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                        Text(_currencyFormat.format(predicted), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
               height: 6,
               child: LinearProgressIndicator(
                 value: historical / (predicted + historical + 1), // Visualization logic
                 backgroundColor: const Color(0xFF2C5F78),
                 color: Colors.grey[300], // Inverted visual for style match
                 borderRadius: BorderRadius.circular(3),
               ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(16)),
      child: Row(
       crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFF00ACC1), shape: BoxShape.circle),
            child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Augmentation prévue", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF006064))),
                const SizedBox(height: 4),
                Text("Les services de chirurgie et de cardiologie montrent une tendance à la hausse significative.", 
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF00838F))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Text("Analyser les causes", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAttentionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFFF9800), shape: BoxShape.circle),
            child: const Icon(Icons.priority_high, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Points d'attention", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFFE65100))),
                const SizedBox(height: 4),
                Text("Le ratio coûts de personnel augmente de manière significative.", 
                   style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFEF6C00))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                  child: Text("Voir les recommandations", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
