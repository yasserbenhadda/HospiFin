import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/stay_model.dart';
import '../../data/services/stay_service.dart';

class StaysScreen extends StatefulWidget {
  const StaysScreen({super.key});

  @override
  State<StaysScreen> createState() => _StaysScreenState();
}

class _StaysScreenState extends State<StaysScreen> {
  final StayService _stayService = StayService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  List<HospitalStay> _stays = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStays();
  }

  Future<void> _loadStays() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final stays = await _stayService.getStays();
      setState(() {
        _stays = stays;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stays: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur"), backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
              ElevatedButton(
                onPressed: _loadStays,
                child: const Text("Réessayer"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('Séjours hospitaliers', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Gestion des séjours", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("${_stays.length} séjours enregistrés", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Nouveau séjour"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white, // Text Color
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
               children: [
                 TextField(
                   decoration: InputDecoration(
                     prefixIcon: const Icon(Icons.search, color: Colors.grey),
                     hintText: "Rechercher par patient, ID ou service...",
                     filled: true,
                     fillColor: Colors.white,
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                     contentPadding: const EdgeInsets.symmetric(vertical: 0),
                   ),
                 ),
                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Expanded(child: _buildFilterDropdown("Service")),
                     const SizedBox(width: 8),
                     Expanded(child: _buildFilterDropdown("Statut")),
                     const SizedBox(width: 8),
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                       child: const Icon(Icons.filter_list, color: Colors.black54),
                     ),
                     const SizedBox(width: 8),
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                       child: const Icon(Icons.download, color: Colors.black54),
                     ),
                   ],
                 )
               ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : (_stays.isEmpty 
                    ? const Center(child: Text("Aucun séjour trouvé")) 
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _stays.length,
                        itemBuilder: (context, index) {
                          return _buildStayCard(_stays[index], index + 1);
                        },
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.black54)),
          const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),
        ],
      ),
    );
  }

  Widget _buildStayCard(HospitalStay stay, int displayId) {
    // Determine color based on status
    Color statusColor = Colors.grey;
    Color statusBg = Colors.grey.shade100;
    
    if (stay.status == 'En cours') {
      statusColor = Colors.white;
      statusBg = Colors.black;
    } else if (stay.status == 'Terminé') {
      statusColor = Colors.black54;
      statusBg = Colors.grey.shade200;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow("ID", "S${stay.id.toString().padLeft(3, '0')}", isBold: false),
          _buildInfoRow("PATIENT", stay.patientName, isBold: true),
          _buildInfoRow("SERVICE", stay.service, isBold: true),
          _buildInfoRow("DATE DÉBUT", _dateFormat.format(stay.startDate), isBold: true),
          _buildInfoRow("DATE FIN", _dateFormat.format(stay.endDate), isBold: true),
          _buildInfoRow("COÛT TOTAL", _currencyFormat.format(stay.totalCost), isBold: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("STATUT", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(stay.status, style: GoogleFonts.inter(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF1E3A8A)),
                  label: const Text("Modifier", style: TextStyle(color: Color(0xFF1E3A8A))),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                   style: OutlinedButton.styleFrom(
                     side: const BorderSide(color: Color(0xFFFFF0F0)),
                     backgroundColor: const Color(0xFFFFF8F8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal, color: Colors.black)),
        ],
      ),
    );
  }
}
