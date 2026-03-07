import 'package:flutter/foundation.dart';

class PremiumService extends ChangeNotifier {
  static final PremiumService _i = PremiumService._();
  factory PremiumService() => _i;
  PremiumService._();

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  void upgrade() {
    _isPremium = true;
    notifyListeners();
  }

  // Feature Flags
  bool get hasAIAssistant => _isPremium;
  bool get hasAdvancedReminders => _isPremium;
  bool get hasUnlimitedEvents => _isPremium;
  bool get hasDocumentStorage => _isPremium;
  bool get showAds => !_isPremium;
}
