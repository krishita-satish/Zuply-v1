import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/donation.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

/// Donor screen for creating a new food donation.
///
/// Includes all required fields: food item, quantity, food type,
/// spice level, pickup address, expiry time, and emergency toggle.
class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodItemCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final ApiService _api = ApiService();

  String _foodType = 'veg';
  int _spiceLevel = 1;
  DateTime _expiryTime = DateTime.now().add(const Duration(hours: 6));
  bool _isEmergency = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _foodItemCtrl.dispose();
    _quantityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ZuplyColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expiryTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      _expiryTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final donation = Donation(
        foodItem: _foodItemCtrl.text.trim(),
        quantity: int.parse(_quantityCtrl.text.trim()),
        foodType: _foodType,
        spiceLevel: _spiceLevel,
        pickupAddress: _addressCtrl.text.trim(),
        expiryTime: _expiryTime,
        isEmergency: _isEmergency,
      );

      await _api.createDonation(donation);

      if (mounted) {
        // Success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Donation created successfully!'),
              ],
            ),
            backgroundColor: ZuplyColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        _foodItemCtrl.clear();
        _quantityCtrl.clear();
        _addressCtrl.clear();
        setState(() {
          _foodType = 'veg';
          _spiceLevel = 1;
          _expiryTime = DateTime.now().add(const Duration(hours: 6));
          _isEmergency = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: ZuplyColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to create donation. Please try again.'),
            backgroundColor: ZuplyColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Donation',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Share surplus food with those in need',
                      style: TextStyle(fontSize: 14, color: ZuplyColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),

            // ── Form ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Food item
                      CustomTextField(
                        controller: _foodItemCtrl,
                        label: 'Food Item',
                        hint: 'e.g. Biryani, Dal Rice, Sandwiches',
                        prefixIcon: Icons.restaurant,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      // Quantity
                      CustomTextField(
                        controller: _quantityCtrl,
                        label: 'Quantity (servings)',
                        hint: 'e.g. 10',
                        prefixIcon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (int.tryParse(v.trim()) == null) return 'Enter a number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Food type toggle
                      Text(
                        'Food Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ZuplyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _foodTypeChip('veg', 'Vegetarian', ZuplyColors.veg),
                          const SizedBox(width: 12),
                          _foodTypeChip('non-veg', 'Non-Vegetarian', ZuplyColors.nonVeg),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Spice level slider
                      Text(
                        'Spice Level',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ZuplyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: ZuplyColors.textHint, size: 20),
                          Expanded(
                            child: Slider(
                              value: _spiceLevel.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              activeColor: ZuplyColors.secondary,
                              inactiveColor: ZuplyColors.secondary.withValues(alpha: 0.2),
                              label: '$_spiceLevel / 5',
                              onChanged: (v) => setState(() => _spiceLevel = v.round()),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ZuplyColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_spiceLevel / 5',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ZuplyColors.secondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Pickup address
                      CustomTextField(
                        controller: _addressCtrl,
                        label: 'Pickup Address',
                        hint: 'Full address for food pickup',
                        prefixIcon: Icons.location_on_outlined,
                        maxLines: 2,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),

                      // Expiry time picker
                      Text(
                        'Expiry Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ZuplyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickExpiryTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: ZuplyColors.divider),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: ZuplyColors.textHint, size: 22),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  DateFormat('MMM dd, yyyy – hh:mm a').format(_expiryTime),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              const Icon(Icons.edit_calendar, color: ZuplyColors.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Emergency toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isEmergency
                              ? ZuplyColors.emergency.withValues(alpha: 0.06)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isEmergency ? ZuplyColors.emergency : ZuplyColors.divider,
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Emergency Donation',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Mark as high-priority for immediate pickup',
                            style: TextStyle(fontSize: 12, color: ZuplyColors.textSecondary),
                          ),
                          value: _isEmergency,
                          activeColor: ZuplyColors.emergency,
                          onChanged: (v) => setState(() => _isEmergency = v),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitDonation,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Icon(Icons.volunteer_activism),
                          label: Text(
                            _isSubmitting ? 'Submitting...' : 'Submit Donation',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foodTypeChip(String value, String label, Color color) {
    final isSelected = _foodType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _foodType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : ZuplyColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: isSelected
                      ? null
                      : Border.all(color: ZuplyColors.divider),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : ZuplyColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
