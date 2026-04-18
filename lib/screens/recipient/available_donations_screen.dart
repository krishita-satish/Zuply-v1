import 'package:flutter/material.dart';
import '../../models/donation.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/donation_card.dart';

/// Recipient screen showing available food donations with filtering.
class AvailableDonationsScreen extends StatefulWidget {
  const AvailableDonationsScreen({super.key});

  @override
  State<AvailableDonationsScreen> createState() => _AvailableDonationsScreenState();
}

class _AvailableDonationsScreenState extends State<AvailableDonationsScreen> {
  final ApiService _api = ApiService();
  List<Donation> _allDonations = [];
  List<Donation> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _filterType = 'all'; // 'all', 'veg', 'non-veg'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _allDonations = await _api.getDonations();
      _applyFilters();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load donations';
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _applyFilters() {
    _filtered = _allDonations.where((d) {
      // Status filter: only show pending/available
      if (d.status != 'pending') return false;
      // Food type filter
      if (_filterType != 'all' && d.foodType != _filterType) return false;
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return d.foodItem.toLowerCase().contains(q) ||
            d.pickupAddress.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    // Sort: emergency first, then by expiry (soonest first)
    _filtered.sort((a, b) {
      if (a.isEmergency && !b.isEmergency) return -1;
      if (!a.isEmergency && b.isEmergency) return 1;
      return a.expiryTime.compareTo(b.expiryTime);
    });
  }

  Future<void> _requestDonation(Donation donation) async {
    try {
      await _api.requestDonation(donation.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Food request sent!'),
              ],
            ),
            backgroundColor: ZuplyColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _loadDonations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to request: $e'),
            backgroundColor: ZuplyColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Donations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              onChanged: (v) {
                setState(() {
                  _searchQuery = v;
                  _applyFilters();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by food or location...',
                prefixIcon: const Icon(Icons.search, color: ZuplyColors.textHint),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // ── Filter chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _filterChip('all', 'All'),
                const SizedBox(width: 8),
                _filterChip('veg', '🟢 Veg'),
                const SizedBox(width: 8),
                _filterChip('non-veg', '🔴 Non-Veg'),
              ],
            ),
          ),

          // ── List ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: ZuplyColors.primary),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off, size: 48, color: ZuplyColors.textHint),
                            const SizedBox(height: 12),
                            Text(_error!, style: TextStyle(color: ZuplyColors.textSecondary)),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: _loadDonations,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off, size: 56, color: ZuplyColors.textHint),
                                const SizedBox(height: 12),
                                const Text(
                                  'No matching donations',
                                  style: TextStyle(fontSize: 16, color: ZuplyColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: ZuplyColors.primary,
                            onRefresh: _loadDonations,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _filtered.length,
                              itemBuilder: (context, index) {
                                final donation = _filtered[index];
                                return DonationCard(
                                  donation: donation,
                                  onRequest: () => _requestDonation(donation),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final isSelected = _filterType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = value;
          _applyFilters();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? ZuplyColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ZuplyColors.primary : ZuplyColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : ZuplyColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
