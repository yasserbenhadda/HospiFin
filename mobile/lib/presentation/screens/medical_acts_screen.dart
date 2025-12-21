import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/medical_act_model.dart';
import '../../data/services/medical_act_service.dart';

class MedicalActsScreen extends StatefulWidget {
  const MedicalActsScreen({super.key});

  @override
  State<MedicalActsScreen> createState() => _MedicalActsScreenState();
}

class _MedicalActsScreenState extends State<MedicalActsScreen> {
  final MedicalActService _actService = MedicalActService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  List<MedicalAct> _acts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActs();
  }

  Future<void> _loadActs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final acts = await _actService.getMedicalActs();
      setState(() {
        _acts = acts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading medical acts: $e');
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
                onPressed: _loadActs,
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
        title: Text('Actes médicaux', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                    Text("Actes médicaux", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("${_acts.length} actes enregistrés", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Nouvel acte"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
               children: [
                 TextField(
                   decoration: InputDecoration(
                     prefixIcon: const Icon(Icons.search, color: Colors.grey),
                     hintText: "Rechercher par type, patient ou praticien...",
                     filled: true,
                     fillColor: Colors.white,
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                     contentPadding: const EdgeInsets.symmetric(vertical: 0),
                   ),
                 ),
                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Expanded(child: _buildFilterDropdown("Type d'acte")),
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
                : (_acts.isEmpty
                   ? const Center(child: Text("Aucun acte médical trouvé"))
                   : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _acts.length,
                    itemBuilder: (context, index) {
                      return _buildActCard(_acts[index], index + 1);
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

  Widget _buildActCard(MedicalAct act, int displayId) {
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
          _buildInfoRow("ID", "A${act.id.toString().padLeft(3, '0')}", isBold: false),
          _buildInfoRow("TYPE D'ACTE", act.type, isBold: false, alignRight: true),
          _buildInfoRow("DATE", _dateFormat.format(act.date), isBold: true),
          _buildInfoRow("PATIENT", act.patientName, isBold: false, alignRight: true),
          _buildInfoRow("PRATICIEN", act.practitioner, isBold: false, alignRight: true),
          _buildInfoRow("COÛT", _currencyFormat.format(act.cost), isBold: true),
          
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 16, color: Colors.black87),
                  label: const Text("Voir", style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
              const SizedBox(width: 8),
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

  Widget _buildInfoRow(String label, String value, {bool isBold = false, bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, 
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 12, 
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal, 
                color: Colors.black
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
