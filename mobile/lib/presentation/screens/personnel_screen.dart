import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/personnel_service.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  final PersonnelService _service = PersonnelService();
  List<dynamic> _allPersonnel = [];
  List<dynamic> _filteredPersonnel = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterPersonnel);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _service.getPersonnel();
      setState(() {
        _allPersonnel = items;
        _filteredPersonnel = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading personnel: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de connexion : Impossible de charger le personnel.\nDétail: $e';
      });
    }
  }

  void _filterPersonnel() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPersonnel = _allPersonnel.where((p) {
        final fName = p['firstName'] ?? '';
        final lName = p['lastName'] ?? '';
        final name = '$fName $lName'.toLowerCase();
        // Fallback for mock data that uses 'name'
        final oldName = (p['name'] ?? '').toString().toLowerCase();
        
        final role = (p['role'] ?? '').toLowerCase();
        return name.contains(query) || role.contains(query) || oldName.contains(query);
      }).toList();
    });
  }
  
  String _formatId(dynamic id) {
     return 'S${id.toString().padLeft(3, '0')}'; // S for Staff
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger les données',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (if possible to pop)
                  if (Navigator.of(context).canPop())
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: IconButton(
                         icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                         onPressed: () => Navigator.of(context).pop(),
                         padding: EdgeInsets.zero,
                         constraints: const BoxConstraints(),
                         style: IconButton.styleFrom(
                           backgroundColor: Colors.white,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFE2E8F0))),
                           padding: const EdgeInsets.all(8)
                         ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestion du personnel',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_allPersonnel.length} membres enregistrés',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showPersonnelDialog(),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('Nouveau', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // --- Controls (Search + Filters) ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    hintText: 'Rechercher par nom ou rôle...',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   // Dropdown Simulation
                   Expanded(child: _buildDropdown('Service')),
                   const SizedBox(width: 12),
                   _buildIconButton(Icons.filter_list),
                   const SizedBox(width: 12),
                   _buildIconButton(Icons.download_rounded),
                ],
              ),
              const SizedBox(height: 24),

              // --- List ---
              if (_filteredPersonnel.isEmpty)
                 Center(child: Text("Aucun membre trouvé", style: GoogleFonts.inter(color: Colors.grey)))
              else
                 ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredPersonnel.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _buildPersonnelCard(_filteredPersonnel[index]),
                 ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: const Color(0xFF64748B))),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFF64748B), size: 20),
    );
  }

  Widget _buildPersonnelCard(Map<String, dynamic> item) {
    
    // Handle name differences (firstName/lastName vs name)
    String name = item['name'] ?? '';
    if (item['firstName'] != null && item['lastName'] != null) {
      name = '${item['firstName']} ${item['lastName']}';
    }
    final id = _formatId(item['id']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
           // Top Row: ID and Name
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text('ID', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
                    const SizedBox(height: 2),
                    Text(id, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A))),
                 ],
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                      Text('NOM COMPLET', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
                      const SizedBox(height: 2),
                      Text(
                        name, 
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                      ),
                   ],
                 ),
               ),
             ],
           ),
           const Divider(height: 24, color: Color(0xFFF1F5F9)),
           
           // Fields Grid
           _buildFieldRow('RÔLE', item['role'] ?? 'N/A', 'SERVICE', item['service'] ?? 'N/A', isPill: true),
           const SizedBox(height: 16),
           _buildFieldRow('EMAIL', item['email'] ?? 'N/A', 'TÉLÉPHONE', item['phone'] ?? 'N/A'),
           const SizedBox(height: 16),
           _buildFieldRow('SALAIRE', '${item['costPerDay'] ?? 0} €/jour', '', ''), 
           
           const SizedBox(height: 24),
           
           // Actions
           Row(
             children: [
               Expanded(
                 child: OutlinedButton.icon(
                   onPressed: () => _showPersonnelDialog(item: item),
                   icon: const Icon(Icons.edit_outlined, size: 16),
                   label: const Text('Modifier'),
                   style: OutlinedButton.styleFrom(
                     foregroundColor: const Color(0xFF334155),
                     side: const BorderSide(color: Color(0xFFCBD5E1)),
                     padding: const EdgeInsets.symmetric(vertical: 14),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   ),
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: OutlinedButton.icon(
                   onPressed: () => _confirmDelete(item),
                   icon: const Icon(Icons.delete_outline, size: 16),
                   label: const Text('Supprimer'),
                   style: OutlinedButton.styleFrom(
                     foregroundColor: const Color(0xFFEF4444),
                     side: const BorderSide(color: Color(0xFFFECACA)),
                     padding: const EdgeInsets.symmetric(vertical: 14),
                     backgroundColor: const Color(0xFFFEF2F2),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   ),
                 ),
               ),
             ],
           )
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le membre ?'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce membre ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _service.deletePersonnel(item['id']); 
                _loadData(); 
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membre supprimé')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showPersonnelDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    
    // Logic to split name if firstName/lastName are missing (backend only sends name)
    String fName = item?['firstName'] ?? '';
    String lName = item?['lastName'] ?? '';
    if (isEdit && fName.isEmpty && lName.isEmpty && item?['name'] != null) {
      final parts = item!['name'].toString().split(' ');
      if (parts.isNotEmpty) {
        fName = parts.first;
        if (parts.length > 1) {
          lName = parts.sublist(1).join(' ');
        }
      }
    }

    final fNameController = TextEditingController(text: fName);
    final lNameController = TextEditingController(text: lName);
    final roleController = TextEditingController(text: item?['role'] ?? '');
    final serviceController = TextEditingController(text: item?['service'] ?? '');
    final emailController = TextEditingController(text: item?['email'] ?? '');
    final phoneController = TextEditingController(text: item?['phone'] ?? '');
    final salaryController = TextEditingController(text: item?['costPerDay']?.toString() ?? '');

    showDialog(
      context: context,
      barrierColor: const Color(0xFF0F172A).withOpacity(0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 // Header
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(
                       isEdit ? 'Modifier le membre' : 'Nouveau membre',
                       style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                     ),
                     IconButton(
                       onPressed: () => Navigator.of(ctx).pop(),
                       icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                       splashRadius: 20,
                     )
                   ],
                 ),
                 const SizedBox(height: 24),
                 
                 // Form Fields
                 _buildDialogTextField(label: 'Prénom', controller: fNameController),
                 const SizedBox(height: 16),
                 _buildDialogTextField(label: 'Nom', controller: lNameController),
                 const SizedBox(height: 16),
                 _buildDialogTextField(label: 'Rôle', controller: roleController),
                 const SizedBox(height: 16),
                 _buildDialogTextField(label: 'Service', controller: serviceController),
                 const SizedBox(height: 16),
                 _buildDialogTextField(label: 'Email', controller: emailController),
                 const SizedBox(height: 16),
                 _buildDialogTextField(label: 'Téléphone', controller: phoneController),
                 const SizedBox(height: 16),
                 _buildDialogTextField(label: 'Salaire (€)', controller: salaryController),
                 
                 const SizedBox(height: 32),
                 
                 // Actions
                 Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        child: Text('Annuler', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final data = {
                            'name': '${fNameController.text} ${lNameController.text}'.trim(), // COMBINE HERE
                            'role': roleController.text,
                            'service': serviceController.text,
                            'email': emailController.text,
                            'phone': phoneController.text,
                            'costPerDay': double.tryParse(salaryController.text) ?? 0.0,
                          };
                          Navigator.of(ctx).pop();
                          try {
                            if (isEdit) {
                              await _service.updatePersonnel(item['id'], data);
                            } else {
                              await _service.createPersonnel(data);
                            }
                            _loadData();
                            if (mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Text(isEdit ? 'Membre modifié avec succès' : 'Nouveau membre ajouté'),
                                   backgroundColor: const Color(0xFF10B981),
                                   behavior: SnackBarBehavior.floating,
                                 ),
                               );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: const Color(0xFFEF4444),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Enregistrer', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      ),
                   ],
                 )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(color: const Color(0xFF0F172A)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldRow(String label1, String val1, String label2, String val2, {bool isPill = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label1, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Text(val1, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF334155))),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label2, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            if (isPill)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(val2, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
              )
            else
              Text(val2, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF334155))),
          ],
        )
      ],
    );
  }
}
