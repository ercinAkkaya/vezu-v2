class SubscriptionPlanLimits {
  const SubscriptionPlanLimits({
    required this.planId,
    required this.maxClothes,
    required this.maxCombinationsPerMonth,
  });

  final String planId;
  final int maxClothes;
  final int maxCombinationsPerMonth;

  static const free = SubscriptionPlanLimits(
    planId: 'free',
    maxClothes: 15,
    maxCombinationsPerMonth: 3,
  );

  static const premium = SubscriptionPlanLimits(
    planId: 'premium',
    maxClothes: 30,
    maxCombinationsPerMonth: 15,
  );

  static const pro = SubscriptionPlanLimits(
    planId: 'pro',
    maxClothes: 50,
    maxCombinationsPerMonth: 20,
  );

  static const proYearly = SubscriptionPlanLimits(
    planId: 'pro_yearly',
    maxClothes: 70,
    maxCombinationsPerMonth: 30,
  );

  static SubscriptionPlanLimits? fromPlanId(String? planId) {
    switch (planId) {
      case 'free':
        return free;
      case 'premium':
        return premium;
      case 'pro':
        return pro;
      case 'pro_yearly':
        return proYearly;
      default:
        return free; // Default to free if unknown
    }
  }

  static const Map<String, SubscriptionPlanLimits> allPlans = {
    'free': free,
    'premium': premium,
    'pro': pro,
    'pro_yearly': proYearly,
  };
}

