import 'package:flutter/material.dart';
import '../models/donation.dart';
import '../theme/app_theme.dart';

/// A richly-styled card displaying a single donation's details.
///
/// Shows food item, type badge (veg/non-veg), quantity, expiry countdown,
/// status chip, and optional AI score indicator.
class DonationCard extends StatelessWidget {
  final Donation donation;
  final VoidCallback? onTap;
  final VoidCallback? onRequest;

  const DonationCard({
    super.key,
    required this.donation,
    this.onTap,
    this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: title + badges ──
              Row(
                children: [
                  // Food type dot indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: donation.foodType == 'veg'
                          ? ZuplyColors.veg
                          : ZuplyColors.nonVeg,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      donation.foodItem,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (donation.isEmergency)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ZuplyColors.emergency.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.priority_high, size: 14, color: ZuplyColors.emergency),
                          const SizedBox(width: 2),
                          Text(
                            'URGENT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ZuplyColors.emergency,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Info chips row ──
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _infoChip(Icons.inventory_2_outlined, 'Qty: ${donation.quantity}'),
                  _infoChip(Icons.access_time, donation.timeRemaining),
                  _infoChip(Icons.local_fire_department,
                      'Spice: ${donation.spiceLevel}/5'),
                  _infoChip(
                    Icons.circle,
                    donation.foodType.toUpperCase(),
                    color: donation.foodType == 'veg'
                        ? ZuplyColors.veg
                        : ZuplyColors.nonVeg,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Address ──
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: ZuplyColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      donation.pickupAddress,
                      style: TextStyle(
                        fontSize: 13,
                        color: ZuplyColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Bottom row: AI score + status + action ──
              Row(
                children: [
                  // AI Score
                  if (donation.aiScore != null) ...[
                    _buildAiScore(donation.aiScore!),
                    const SizedBox(width: 12),
                  ],
                  // Status chip
                  _statusChip(donation.status),
                  const Spacer(),
                  // Request button (for recipient view)
                  if (onRequest != null)
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: onRequest,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Request'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ZuplyColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? ZuplyColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? ZuplyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'pending':
        bg = ZuplyColors.secondary.withValues(alpha: 0.12);
        fg = ZuplyColors.secondary;
        break;
      case 'accepted':
        bg = ZuplyColors.primary.withValues(alpha: 0.12);
        fg = ZuplyColors.primary;
        break;
      case 'delivered':
        bg = ZuplyColors.scoreHigh.withValues(alpha: 0.12);
        fg = ZuplyColors.scoreHigh;
        break;
      default:
        bg = ZuplyColors.textHint.withValues(alpha: 0.12);
        fg = ZuplyColors.textHint;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _buildAiScore(double score) {
    final color = score >= 7
        ? ZuplyColors.scoreHigh
        : score >= 4
            ? ZuplyColors.scoreMed
            : ZuplyColors.scoreLow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'AI: ${score.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
