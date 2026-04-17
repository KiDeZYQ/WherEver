import 'package:flutter/material.dart';
import '../models/subscription_level.dart';
import '../services/subscription_service.dart';

/// Dialog showing subscription tier comparison and upgrade option
class SubscriptionDialog extends StatelessWidget {
  final SubscriptionLevel currentLevel;
  final VoidCallback? onUpgradePressed;

  const SubscriptionDialog({
    required this.currentLevel,
    this.onUpgradePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tiers = SubscriptionService().getSubscriptionTiers();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose Your Plan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...tiers.map((tier) => _buildTierCard(context, tier)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, SubscriptionTierInfo tier) {
    final isCurrentTier = tier.level == currentLevel;
    final isPremium = tier.level == SubscriptionLevel.premium;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isPremium ? Colors.amber.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPremium
            ? BorderSide(color: Colors.amber.shade700, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  tier.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (isCurrentTier) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Current',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
                if (isPremium) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Recommended',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tier.price,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isPremium ? Colors.amber.shade700 : null,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...tier.features.map((f) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        size: 16,
                        color: isPremium ? Colors.amber.shade700 : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(f, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                )),
            if (!isCurrentTier && isPremium) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onUpgradePressed?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Upgrade to Premium'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Show upgrade required message
Future<void> showUpgradeRequiredDialog(
  BuildContext context, {
  required String featureName,
  String? message,
}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          const Text('Upgrade Required'),
        ],
      ),
      content: Text(
        message ?? '$featureName is available for Premium users only.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Navigate to subscription page
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Upgrade'),
        ),
      ],
    ),
  );
}
